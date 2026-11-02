# AGENTS.md

This file is loaded at the start of every agent session. Keep it operational and under 60 lines. Put progress notes in IMPLEMENTATION_PLAN.md, not here.

## Project
netop: per-app network monitor for macOS 14+. Swift 6 (strict concurrency), SwiftUI, SwiftPM only, zero third-party dependencies. v1 monitors only: no blocking, no entitlements, no root. GPL-3.0.

## Layout
- `Sources/NetopCore/` — all logic. Pure Swift + Foundation/Network; no SwiftUI or AppKit.
- `Sources/Netop/` — SwiftUI app shell: menu bar (`MenuBarExtra`) + main window. Wiring and views only.
- `Tests/NetopCoreTests/` — tests for NetopCore (Swift Testing).
- `Support/Info.plist` — app bundle plist (`LSUIElement`: menu bar app, no Dock icon).
- `scripts/bundle.sh` — builds ad-hoc-signed `build/Netop.app`.
- `specs/` — what to build. `docs/` — future ideas, NOT build targets.
- `prototype/netop.sh` — original shell prototype; reference only.

## Setup
```sh
xcode-select -p   # needs Xcode with Swift 6; no other dependencies
```

## Validation — run ALL before every commit
```sh
make check   # = swift build && swift test && scripts/bundle.sh
```

## Codebase patterns
- Logic belongs in NetopCore so `swift test` covers it. Views in `Sources/Netop/` only display NetopCore state and forward user actions.
- Everything that touches the OS (traffic counters, network path, clock, file system, notifications) sits behind a protocol in NetopCore, with the real implementation and a fake for tests. Tests never depend on real traffic, the current date, the real home directory or network access.
- Tests use Swift Testing (`import Testing`, `@Test`, `#expect`), not XCTest. Pin locale/time zone in tests that format.
- Byte sizes: `ByteCount` (`Sources/NetopCore/ByteCount.swift`); format with `.formatted()`.
- UI copy: plain English, sentence case; the app name is written "netop".

## Never
- Push, deploy, tag, or create releases.
- Add a Network Extension, system extension, privileged helper, launch daemon, kext, or anything that needs entitlements or a paid Apple Developer account. That's a later phase (`docs/roadmap.md`).
- Use `sudo`, require root, or turn off SIP.
- Add third-party dependencies, an `.xcodeproj`, or an `.xcworkspace`.
- Edit `specs/*.md`, `LICENSE`, `prototype/`, or `.ralph/`.
- Read, print or commit secrets or `.env` files.

## Operational notes
<!-- Learned while working. Keep each note to one line, and delete it when it stops being true. -->
- `UNUserNotificationCenter` crashes outside a .app bundle: test through the protocol fake; try the real thing via `make run`.
- UI can't be checked headlessly; acceptance criteria about the UI are checked by a human with `make run`.
