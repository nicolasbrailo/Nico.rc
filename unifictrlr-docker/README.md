Docker container for Unifi controller

To run

1. `make build`
2. (Build process seems to randomly fail on apt-key, but clean && retry works)
3. `make coldstart`

Settings and logs will be saved to ./ctrlrcfg and ./ctrlrlogs

