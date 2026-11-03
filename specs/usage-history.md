# Usage history

netop keeps per-app usage on disk so people can see how much each app used today, over the last 7 days and over the last 30 days, also after restarts.

## Requirements
- Each sample is added into **hourly buckets**: one record per local clock hour × app identity × network bucket, holding bytes downloaded and bytes uploaded.
- An hour is the local clock hour the sample was taken in (start of the hour per the current calendar and time zone).
- History is stored in a SQLite database at `~/Library/Application Support/netop/usage.sqlite`, using the `SQLite3` module that ships with macOS. The folder is created if missing.
- The store remembers each app identity's display name and bundle path (if any) so the window can show names and icons for apps that aren't running.
- Each sample is written as it arrives. Quitting or a crash loses at most the latest sample.
- Records older than 90 days are deleted on launch and then once an hour.
- Queries return per-app totals (downloaded, uploaded, total) for a period and a network filter:
  - Periods: **Today** (since local midnight), **Last 7 days** (today plus the 6 previous calendar days), **Last 30 days** (today plus the 29 previous calendar days).
  - Network filter: **All networks**, **Wi-Fi**, **Ethernet**, **Other**.
- A query for "today's total" across all apps and networks is available for the menu bar.
- If the database can't be opened or is corrupt, netop moves the broken file aside (renamed with a timestamp), starts a new empty database and keeps running.
- The storage location and clock are injected; tests use a temporary folder and a fake clock.

## Constraints
- No third-party dependencies (system `SQLite3` only).
- The database schema has a version number so a later version can migrate it.

## Acceptance criteria
1. Two samples for the same app, network and hour are stored as one record with the summed bytes.
2. Samples in different hours, or on different networks, produce separate records.
3. After closing and reopening the store, previously recorded totals are unchanged.
4. With a fake clock, a record 91 days old is deleted by pruning and a record 89 days old is kept.
5. "Today" includes a sample from 00:30 local time and excludes one from 23:30 the day before (time zone pinned in the test).
6. "Last 7 days" includes a sample from 6 calendar days ago and excludes one from 7 calendar days ago.
7. The Wi-Fi filter returns only Wi-Fi bytes; All networks returns the sum over all buckets.
8. An app with traffic on two networks appears once in an All networks query, with the bytes summed.
9. Opening a store whose file contains garbage leaves the old file renamed next to it and returns an empty, working store.

## Out of scope
- Per-minute or per-sample history, history longer than 90 days.
- Clear history, CSV export, iCloud sync.
- Charts.
