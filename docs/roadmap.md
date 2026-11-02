# Roadmap (not build targets)

Ideas for after v1. Nothing here is built by the loop until it moves into `specs/`.

## Phase 2: control (needs the paid Apple Developer Program)
- Network Extension content filter (`NEFilterDataProvider`, system extension) to allow/deny connections per app.
- "App X wants to connect to host Y" prompt (pause the flow, resume with the user's verdict).
- Rules: per app, per host/domain, per port; temporary vs. permanent.
- Blocklists (subscribable host lists).
- Hotspot mode: block chosen apps automatically while tethered.
- Developer ID signing + notarization so other people can install it normally.

## Later monitoring ideas
- Connection list per app with remote hostnames.
- World map of remote endpoints (offline GeoIP database, e.g. DB-IP Lite, CC BY 4.0).

## References
- LuLu (GPL-3.0) — open-source per-app firewall using the same Network Extension approach: https://github.com/objective-see/LuLu
- REA — reverse-engineering MCP, used to study `nettop`/NetworkStatistics: https://github.com/morluto/rea
