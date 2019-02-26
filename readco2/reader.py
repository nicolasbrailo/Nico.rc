# Most code stolen from 
# * https://hackaday.io/project/5301-reverse-engineering-a-low-cost-usb-co-monitor/log/17909-all-your-base-are-belong-to-us
# * https://blog.wooga.com/woogas-office-weather-wow-67e24a5338

from collections import namedtuple
import random
import matplotlib.pyplot as plt
import time, sys, fcntl, time, threading

class UsbReader(object):
    def __init__(self, path, key):
        self.fp = open(path, "a+b",  0)
        HIDIOCSFEATURE_9 = 0xC0094806
        set_report = "\x00" + "".join(chr(e) for e in key)
        fcntl.ioctl(self.fp, HIDIOCSFEATURE_9, set_report)

    def read_next(self):
        return list(ord(e) for e in self.fp.read(8))

class CO2Reader(object):
    @staticmethod
    def _decrypt(key,  data):
        cstate = [0x48,  0x74,  0x65,  0x6D,  0x70,  0x39,  0x39,  0x65]
        shuffle = [2, 4, 0, 7, 1, 6, 5, 3]
        
        phase1 = [0] * 8
        for i, o in enumerate(shuffle):
            phase1[o] = data[i]
        
        phase2 = [0] * 8
        for i in range(8):
            phase2[i] = phase1[i] ^ key[i]
        
        phase3 = [0] * 8
        for i in range(8):
            phase3[i] = ( (phase2[i] >> 3) | (phase2[ (i-1+8)%8 ] << 5) ) & 0xff
        
        ctmp = [0] * 8
        for i in range(8):
            ctmp[i] = ( (cstate[i] >> 4) | (cstate[i]<<4) ) & 0xff
        
        out = [0] * 8
        for i in range(8):
            out[i] = (0x100 + phase3[i] - ctmp[i]) & 0xff
        
        return out

    def __init__(self, usb_reader, key):
        self._usb_reader = usb_reader
        self._key = key
        self._running = True

        self.co2 = None
        self.temp = None
        self.rel_humidity = None
        self.last_updated = None

        self._bg = threading.Thread(target=self._bg_update_readings)
        self._bg.start()

    def stop(self):
        self._running = False
        self._bg.join()

    def _get_next_op(self):
        decrypted = CO2Reader._decrypt(self._key, self._usb_reader.read_next())
        if decrypted[4] != 0x0d or (sum(decrypted[:3]) & 0xff) != decrypted[3]:
            raise "Checksum error"

        op = decrypted[0]
        val = decrypted[1] << 8 | decrypted[2]
        return op, val

    def _bg_update_readings(self):
        while self._running:
            op, val = self._get_next_op()
            updated = True
            if op == 0x50:
                self.co2 = val
            if op == 0x42:
                self.temp = val/16.0-273.15
            if op == 0x44:
                self.rel_humidity = val/100.0
            else:
                updated = False

            if updated:
                self.last_updated = time.time()

class MockReader(namedtuple('MockReader', 'co2 temp rel_humidity last_updated')):
    def stop(self):
        pass

class TimeSeries(object):
    class Series(object):
        def __init__(self):
            self.series = []
            self.max = None
            self.min = None
        
        def add(self, val):
            self.series.append(val)
            if self.max is None or val > self.max:
                self.max = val
            if self.min is None or val < self.min:
                self.min = val

    def __init__(self, *kv):
        self.series_map = {}
        for k in kv:
            self.series_map[k] = TimeSeries.Series()

    def add(self, **kv):
        for key in kv:
            self.series_map[key].add(kv[key])

    def report(self):
        import matplotlib.pyplot as plt
        fig, series_plot = plt.subplots()
        series_plot.set_xlabel('time (s)')
        colors = ['blue', 'red', 'green', 'cyan', 'magenta', 'yellow', 'black', 'white']
        color_i = 0

        for series_name in self.series_map:
            # print("Max: {} Min: {}".format(
            #     self.series_map[series_name].max, self.series_map[series_name].min))
            series_plot.set_ylabel(series_name, color=colors[color_i])
            series_plot.plot(self.series_map[series_name].series, color=colors[color_i])
            series_plot.tick_params(axis='y', labelcolor=colors[color_i])
            series_plot = series_plot.twinx()
            color_i = (color_i + 1) % len(colors)

        fig.tight_layout()  # otherwise the right y-label is slightly clipped
        plt.show()


if __name__ == "__main__":
    PRINT_FREQUENCY_SECONDS = 1
    # Arbitrary key
    key = [0xc4, 0xc6, 0xc0, 0x92, 0x40, 0x23, 0xdc, 0x96]
    history = TimeSeries('temp', 'co2')
    reader = CO2Reader(UsbReader(sys.argv[1], key), key)
    #reader = MockReader(2000 * random.random(), 30 * random.random(), None, None)
    try:
        while True:
            time.sleep(PRINT_FREQUENCY_SECONDS)
            #reader = MockReader(2000 * random.random(), 30 * random.random(), None, None)
            history.add(co2=reader.co2, temp=reader.temp)
            print("{}: t={}, co2={}, rh={}, updated={}".format(
                time.time(), reader.temp, reader.co2, reader.rel_humidity, reader.last_updated))
    except KeyboardInterrupt:
        history.report()
        reader.stop()


