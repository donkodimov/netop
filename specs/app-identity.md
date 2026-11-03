# App identity

netop shows traffic per app, not per raw process, so people recognise what they see: helper processes count toward the app they belong to, and background processes show under their own name.

## Requirements
- Each process in a sample is mapped to an **app identity** using its executable path (looked up by PID while the process runs).
- If the executable path lies inside one or more `.app` bundles, the identity is the **outermost** `.app` bundle. So `Google Chrome Helper (Renderer)`, whose executable is inside `Google Chrome.app/Contents/Frameworks/…/Google Chrome Helper.app`, counts as Google Chrome.
- An app identity is keyed by the bundle identifier. If the bundle has no identifier, it is keyed by the bundle path.
- The display name of an app is the bundle's `CFBundleDisplayName`, else `CFBundleName`, else the bundle file name without `.app`.
- Processes outside any `.app` bundle (for example `mDNSResponder`, `nsurlsessiond`, `softwareupdated`, command-line tools) each get their own identity keyed and named by process name, with a generic icon. They are shown like apps, not hidden and not merged.
- If the executable path can't be found (the process already exited, or access is denied), the process name reported by the traffic source is used, as for a background process.
- The `nettop` process name suffix `.<pid>` is never part of a display name.
- Lookups are cached per PID for the life of the process, so a busy process isn't looked up every sample.
- Looking up executable paths and reading bundle info sits behind a protocol with a fake for tests.
- The app icon is loaded in the app shell (`NSWorkspace`) from the bundle path that NetopCore provides; NetopCore never imports AppKit.

## Acceptance criteria
1. A process whose executable is `/Applications/Foo.app/Contents/MacOS/Foo` maps to Foo's bundle identifier with Foo's display name.
2. A helper at `/Applications/Foo.app/Contents/Frameworks/Foo Helper.app/Contents/MacOS/Foo Helper` maps to the same identity as Foo.
3. Two processes of the same app in the same sample are added into one row.
4. A process at `/usr/sbin/mDNSResponder` maps to an identity named `mDNSResponder`.
5. A process whose path lookup fails maps to its reported process name, without the `.<pid>` suffix.
6. A bundle with neither display name nor bundle name is shown by its file name without `.app`.
7. A PID that is looked up once is not looked up again while it stays in later samples (checked with the fake).

## Out of scope
- Attributing system daemon traffic to the app that asked for it (e.g. `nsurlsessiond` downloading for an app).
- Grouping all Apple system processes into one row.
- Hiding or filtering background processes.
