DarnToc 1.2.1 is mostly about large clips, LUTs and problem reports. Thanks to everyone who sent feedback.

### Opening clips
- **No more frozen window.** Clips now open in the background with an "Opening…" indicator, so the app stays responsive. Previously a slow drive could make DarnToc stop responding until the clip finished opening.
- **iCloud Drive.** If a clip is stored in iCloud and isn't downloaded to your Mac yet, DarnToc starts the download and shows its progress. (Before, it simply waited with no sign of what was happening.) For large RAW clips, a folder outside iCloud Drive or an external drive is still the better home.
- **No endless waiting.** If a clip still hasn't opened after 20 seconds with no visible progress, DarnToc says so and lets you keep waiting or stop and send a report.

### LUT preview
- Clips with a LUT built in (or applied from a `.sidecar` file) now get a **LUT** switch in place of Rec.709. Turn it off to see the log image underneath, as you would in Resolve.
- **Fixed:** on those clips the Rec.709 preview applied the LUT on top of the Rec.709 conversion, so the look was doubled.
- As before, this only changes the preview. Exported trims keep the clip's LUT setting, so you can still turn it off in Resolve.

### Problem reports
- **Help → Send Error Report…** creates an email to the developer with DarnToc's diagnostic log attached, plus any recent macOS crash report for DarnToc. You see the email before anything is sent.
- If DarnToc crashed or was force-quit, it offers to send a report the next time it opens.
- The log is kept on your Mac at `~/Library/Logs/DarnToc` (**Help → Show Log in Finder**). It records clip file names, folder paths, drive type, your Mac's model and macOS version, and how long each step took. It never contains video, and nothing is sent unless you choose to.

### Fixes
- Opening a clip from Finder (**Open With → DarnToc**) no longer leaves an extra, empty window.
- The start screen showed the Blackmagic RAW SDK version as "0.0". It now shows the real version (6.0).

All new text is translated into Welsh, Japanese and Spanish.

### Requirements
macOS 14 or later, on Apple silicon or Intel (universal, no Rosetta).

### Install
Download **DarnToc-1.2.1.dmg** below, open it, and drag DarnToc to Applications, replacing the old copy. The app is signed with a Developer ID and notarised by Apple.

---
DarnToc is not affiliated with or endorsed by Blackmagic Design. Blackmagic RAW is a trademark of Blackmagic Design Pty. Ltd.
