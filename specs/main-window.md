# Main window

The main window shows how much each app has used the network over a chosen period, optionally limited to one kind of network.

## Requirements
- The window opens from `Open netop` in the menu. It has a toolbar with a **period picker** and a **network filter**, and a table below.
- Period picker: `Today` (default), `Last 7 days`, `Last 30 days`.
- Network filter: `All networks` (default), `Wi-Fi`, `Ethernet`, `Other`.
- Table columns: **App** (icon + display name), **Downloaded**, **Uploaded**, **Total**. Sizes use `ByteCount` formatting.
- Every column is sortable by clicking its header. The default sort is Total, largest first. App sorts by display name, case-insensitive.
- Apps with zero bytes for the chosen period and network are not shown.
- App icons come from the stored bundle path; background processes, and apps whose bundle no longer exists, get a generic icon.
- The table refreshes on each new sample while the window is open.
- When the table would be empty: `No traffic recorded for this period`.
- Period, filter and sort are not remembered across restarts.
- Rows, totals and sort order are computed in NetopCore from history queries; the view only displays them.

## Constraints
- SwiftUI `Table`; macOS 14 APIs only.
- UI copy in plain English, sentence case.

## Acceptance criteria
1. The window model for `Today` + `All networks` lists every app with traffic today, sorted by total, largest first.
2. Switching the network filter to `Wi-Fi` shows only Wi-Fi bytes and hides apps that have none on Wi-Fi.
3. Sorting by App orders `alpha`, `Beta`, `gamma` regardless of case.
4. Sorting by Downloaded, Uploaded or Total orders by that number, largest first. Clicking the same header again reverses the order.
5. An app with zero bytes in the chosen period is absent.
6. With no history in the period, the model reports the empty state.
7. (Manual, `make run`) Icons appear for apps, a generic icon for background processes, and the table updates within a few seconds while traffic flows.

## Out of scope
- Charts, a live-rate view, per-connection details.
- Clear history, CSV export, search.
