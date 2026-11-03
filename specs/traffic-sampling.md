# Traffic sampling

netop measures how many bytes each process downloads and uploads every 5 seconds, and which kind of network carried them, so the rest of the app can show live rates and keep history.

## Requirements
- Per-process byte counts come from `/usr/bin/nettop` (run as a subprocess, no root). Access to it sits behind a `TrafficSource` protocol so a different source can replace it later.
- While recording, netop takes one sample every 5 seconds. A sample is, per process: bytes downloaded and bytes uploaded since the previous sample.
- A process seen for the first time contributes only traffic after it was first seen, never its lifetime total.
- A process is identified by PID and process name together. If a counter goes down (PID reused, counters reset), that process is treated as new: no negative values and no huge jump.
- Processes with zero bytes in a sample are left out of that sample.
- Loopback traffic (localhost) is not counted.
- Every sample is tagged with one network bucket: **Wi-Fi**, **Ethernet** or **Other**. The bucket is the interface type of the primary network path at the moment the sample is taken (`NWPathMonitor`): Wi-Fi → Wi-Fi, wired Ethernet → Ethernet, everything else (VPN, USB tethering, Thunderbolt bridge, cellular, no path) → Other.
- The network path monitor sits behind a protocol with a fake for tests.
- Pausing recording stops sampling completely. Resuming starts fresh: traffic during the pause is not counted.
- If `nettop` fails or exits, netop restarts it and keeps going. A failed sample is skipped, not counted as zero for everything or as a burst afterwards.
- Current rate of a process = its bytes in the latest sample divided by the sample interval.

## Constraints
- Parsing of `nettop` output is pure logic in NetopCore and is tested with recorded fixture text, never by running `nettop`.
- The clock is injected; tests never wait real time.
- Sampling must not noticeably load the Mac: one long-running or one short-lived `nettop` process per sample, never several.

## Acceptance criteria
1. Given two consecutive fixture outputs for the same process, the sample contains exactly the difference in bytes in and out.
2. A process that first appears in the second output contributes 0 to the first sample, and only later deltas afterwards.
3. When a process's counter is lower than before, the sample contains no negative value and the process is treated as new.
4. Processes with no traffic in a sample are absent from it.
5. Malformed or truncated `nettop` lines are skipped without crashing, and the rest of the sample is kept.
6. With the fake path reporting Wi-Fi, Ethernet, cellular, other and "no path", samples are tagged Wi-Fi, Ethernet, Other, Other and Other.
7. After pause and resume, the first sample after resuming does not include traffic from the paused time.
8. A rate of 10,000 bytes in one 5-second sample is reported as 2,000 bytes per second.

## Out of scope
- Hotspot / expensive-network detection, Wi-Fi network names (SSID).
- Per-connection data (remote hosts, ports).
- The private NetworkStatistics framework.
- Blocking or limiting traffic.
