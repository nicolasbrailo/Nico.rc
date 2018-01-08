
def cache_to_disk(fname):
    import json
    try:
        cache = json.load(open(fname, 'r'))
    except (IOError, ValueError):
        cache = {}

    def decorate(f):
        def cached_f(x):
            if cache.has_key(x):
                return cache[x]
            else:
                cache[x] = f(x)
                json.dump(cache, open(fname, 'w')) 
                return cache[x]

        return cached_f
    return decorate


def simulate_human():
    from time import sleep
    import random
    n = random.randint(10,50)/10.0
    print "I'm a human, waiting for {} seconds!".format(n)
    sleep(n)

def wget(url):
    import urllib2
    return urllib2.urlopen(url).read()

def post_to(url, data):
    import requests
    r = requests.post(url, data)
    return (r.text, r.status_code, r.reason)

def get_auth_tok(txt):
    start = txt.find('authenticity_token')
    start = txt.find('value', start) + len('value="')
    end = txt.find('"', start)
    return txt[start:end]

def mk_session(url, login_post):
    import requests
    s = requests.Session() 
    s.post(url, login_post)
    return s

def mfp_hack_get_columns(txt):
    td_i, td_f = -1, 0
    while td_i != 0:
        td_end_tok = '</td>'
        td_i = txt.find('>', txt.find('td', td_f)) + 1
        td_f = txt.find(td_end_tok, td_i)
        yield txt[td_i:td_f]
        td_f += len(td_end_tok)

def mfp_hack_value(txt):
    try:
        return int(txt.replace(',', ''))
    except ValueError:
        if txt.find('macro-value') != -1:
            val_i = txt.find('>', txt.find('macro-value')) + 1
            val_f = txt.find('<', val_i)
            return mfp_hack_value(txt[val_i:val_f])

        return None

def mfp_extract_interesting_cols(v):
    return {'calories': v[1], 'carbs': v[2], 'protein': v[3], 'fat': v[4]}

def mfp_scrape_daylog(html):
    tok = '<tr class="total">'
    total_start = html.find(tok) + len(tok)
    total_end = html.find('</tr>', total_start)
    totals = mfp_extract_interesting_cols(
                [mfp_hack_value(x) for x in mfp_hack_get_columns(html[total_start:total_end])])

    tok = '<tr class="total alt">'
    goal_start = html.find(tok, total_end) + len(tok)
    goal_end = html.find('</tr>', goal_start)
    goals = mfp_extract_interesting_cols(
                [mfp_hack_value(x) for x in mfp_hack_get_columns(html[goal_start:goal_end])])

    tok = '<tr class="total remaining">'
    remaining_start = html.find(tok, goal_end) + len(tok)
    remaining_end = html.find('</tr>', remaining_start)
    remainings = mfp_extract_interesting_cols(
                    [mfp_hack_value(x) for x in mfp_hack_get_columns(html[remaining_start:remaining_end])])

    tok = '<td class="extra" colspan="7">'
    extra_start = html.find(tok, remaining_end)
    tok = 'earned '
    extra_start = html.find(tok, extra_start) + len(tok)
    extra_end = html.find(' ', extra_start)
    excercise = html[extra_start:extra_end]

    return {
            'totals': totals,
            'goals': goals,
            'remainings': remainings,
            'excercise': excercise,
        }

def get_dates_range(days_back):
    from datetime import datetime, timedelta
    return [datetime.today()-timedelta(days=x) for x in range(1,days_back)]

def mfp_build_datelog_url(date):
    return 'http://www.myfitnesspal.com/food/diary?date=' + date.strftime('%Y-%m-%d')

@cache_to_disk('mfp_log_cache')
def mfp_get_datelog(url):
    simulate_human()
    return mfp_scrape_daylog(session.get(url).text)

def get_args():
    import argparse
    import getpass

    args = argparse.ArgumentParser('Print stats from MFP')
    args.add_argument('--user',type=str, default=None, help='MFP user.', required=True)
    args.add_argument('--password',type=str, default=None, help='MFP pass.')
    args.add_argument('--days', type=int, help='Number of history days to fetch', default=7*5)
    args = args.parse_args()

    if not args.password:
        args.password = getpass.getpass('MFP Password for {}: '.format(args.user)).strip()

    return args

def mfp_login(user, password):
    url = 'https://www.myfitnesspal.com/account/login'
    login_post = {
        'authenticity_token': get_auth_tok(wget('http://www.myfitnesspal.com')),
        'username': user,
        'password': password,
        'remember_me': 1,
    }

    simulate_human()
    session = mk_session(url, login_post)
    return session


args = get_args()
session = mfp_login(args.user, args.password)

archive = {}
for date in get_dates_range(args.days):
    url = mfp_build_datelog_url(date) 
    archive[date] = mfp_get_datelog(url)


week_stats = {}
for day in archive:
    week_of_year = day.isocalendar()[1]

    try:
        week_stats[week_of_year]['n'] += 1
        try:
            week_stats[week_of_year]['excercise'] += int(archive[day]['excercise'])
        except ValueError:
            pass

        week_stats[week_of_year]['totals']['carbs'] += archive[day]['totals']['carbs']
        week_stats[week_of_year]['totals']['calories'] += archive[day]['totals']['calories']
        week_stats[week_of_year]['totals']['protein'] += archive[day]['totals']['protein']
        week_stats[week_of_year]['totals']['fat'] += archive[day]['totals']['fat']
        week_stats[week_of_year]['remainings']['carbs'] += archive[day]['remainings']['carbs']
        week_stats[week_of_year]['remainings']['calories'] += archive[day]['remainings']['calories']
        week_stats[week_of_year]['remainings']['protein'] += archive[day]['remainings']['protein']
        week_stats[week_of_year]['remainings']['fat'] += archive[day]['remainings']['fat']
        week_stats[week_of_year]['goals']['carbs'] += archive[day]['goals']['carbs']
        week_stats[week_of_year]['goals']['calories'] += archive[day]['goals']['calories']
        week_stats[week_of_year]['goals']['protein'] += archive[day]['goals']['protein']
        week_stats[week_of_year]['goals']['fat'] += archive[day]['goals']['fat']

    except KeyError:
        week_stats[week_of_year] = archive[day]
        week_stats[week_of_year]['n'] = 1
        try:
            week_stats[week_of_year]['excercise'] = int(archive[day]['excercise'])
        except ValueError:
            week_stats[week_of_year]['excercise'] = 0

for week in week_stats:
    msg = """Week {} stats: avg {} cal/day, {} cals {} goal. {} grams wb {} expected."""
    n = week_stats[week]['n']
    total_cals = week_stats[week]['totals']['calories']
    goal_cals = week_stats[week]['goals']['calories']
    delta = abs(goal_cals-total_cals)
    weight_d = delta / 7.700 # Cals per g of body fat, according to google
    print(msg.format(week,
                     total_cals/n,
                     delta,
                     ('over' if (total_cals>goal_cals) else 'under'),
                     weight_d,
                     ('gain' if (total_cals>goal_cals) else 'loss'),))

