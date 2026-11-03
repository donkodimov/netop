# Menu bar

netop lives in the menu bar so people can glance at which apps are using the network right now, and pause recording or open the main window.

## Requirements
- netop is a menu bar app (no Dock icon) with a plain network icon. The icon never shows numbers.
- Clicking the icon opens a menu with, in this order:
  1. Up to **5 apps** with the highest current rate (download + upload) from the latest sample. Each row shows the app name, download rate and upload rate, e.g. `Safari  ↓ 1.2 MB/s  ↑ 40 kB/s`. Rates use `ByteCount` formatting followed by `/s`.
  2. If no app had traffic in the latest sample: `No network activity`. While paused: `Recording paused` instead of the app list.
  3. `Today: <total>`: total downloaded + uploaded today across all apps and networks, from history.
  4. `Open netop` (⌘O): opens the main window and brings it to the front.
  5. `Pause recording` / `Resume recording`: toggles sampling (see traffic-sampling spec).
  6. `Open at login`: a checkmark item, off by default.
  7. `Quit netop` (⌘Q).
- The live rows update while the menu is open, on each new sample.
- netop starts recording at every launch. Paused state is not remembered across restarts.
- `Open at login` uses `SMAppService.mainApp` behind a protocol with a fake for tests. The checkmark shows the real registration state. If registering fails, the item stays unchecked.
- The choice of rows, their order and their text is computed in NetopCore; the view only displays it.

## Constraints
- UI copy in plain English, sentence case; the app name is written "netop".
- No entitlements needed.

## Acceptance criteria
1. With 7 apps in the latest sample, the menu model lists the 5 with the highest download + upload rate, highest first.
2. A sample of 6,000,000 bytes in and 200,000 bytes out over 5 seconds gives a row with `↓ 1.2 MB/s` and `↑ 40 kB/s` (locale pinned to en_US).
3. With an empty latest sample, the menu model shows `No network activity`.
4. While paused, the menu model shows `Recording paused` and the toggle reads `Resume recording`.
5. The `Today` line equals the history store's today total.
6. Turning `Open at login` on calls the fake's register; when the fake throws, the item reads as off.
7. (Manual, `make run`) The icon appears in the menu bar, no Dock icon appears, and `Open netop` brings the window to the front.

## Out of scope
- Rates or graphs drawn in the menu bar itself.
- Alerts and notifications.
- A settings window.
