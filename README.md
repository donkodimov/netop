# netop

A per-app network monitor for macOS. See which apps use your network, how much, and over which kind of connection (Wi-Fi, Ethernet or other).

**Status:** early development. v1 only monitors; blocking/firewall features come later (see `docs/roadmap.md`).

Inspired by Little Snitch, TripMode and [LuLu](https://github.com/objective-see/LuLu).

## Build

Requires macOS 14+ and Xcode (Swift 6).

```sh
make test   # run the test suite
make app    # build build/Netop.app
make run    # build and launch it
```

`prototype/netop.sh` is the original shell prototype (hotspot top-talkers via `nettop`).

## License

GPL-3.0. See `LICENSE`.
