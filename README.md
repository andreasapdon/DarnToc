# DarnToc for Blackmagic RAW

Opens a Blackmagic RAW clip, lets you scrub and set in/out points, and exports a lossless trimmed `.braw`. Export uses the SDK's own `IBlackmagicRawClip::CreateJobTrim`.

Requires macOS 14+ and the Blackmagic RAW SDK 6.0 at `/Applications/Blackmagic RAW/Blackmagic RAW SDK` (path set in `Package.swift`).

## Build the app

```sh
cd ~/Developer/BRAWTrimmer
./make-app.sh --install
```

This creates `/Applications/DarnToc.app`, with the Blackmagic RAW framework embedded and ad-hoc signed for this Mac. Because it registers as a .braw viewer, Finder offers DarnToc under **Open With**. Blackmagic RAW Player stays the default unless you change that in Get Info.

During development: `open Package.swift` in Xcode and Run (⌘R), or `swift run`.

## Keys

| Key | Action |
|---|---|
| ⌘O | Open clip (or drag one onto the window) |
| Space | Play / pause (within in–out) |
| ← / → | Step one frame |
| ↑ / ↓ | Jump to In / Out |
| I / O | Set In / Out at playhead |
| M | Mute / unmute |
| ⌘E | Export the current In–Out range |
| A | Add the current In–Out range to the export queue |
| ⇧⌘E | Show / hide the export queue |

In and Out are both inclusive.

## Export queue

Saves In–Out ranges from any number of clips, remembered between launches. **Export to Folder…** writes each range that hasn't been exported yet, named by its label. Existing files are never overwritten: a number is added to the name instead. Every export writes `name.partial.braw` first, then reopens the file and checks its frame count before renaming it. A failed or cancelled export never leaves a file that looks like a finished clip.

## Layout

- `Sources/BRAWBridge`: Objective-C++ wrapper (`BRAWClip`) around the COM API. It handles open, metadata, frame decode to `CGImage`, and SDK trim with progress and cancel. `BRAWDispatch.cpp` compiles Blackmagic's runtime loader straight from the SDK folder.
- `Sources/BRAWTrimmer`: SwiftUI app (model + view).

## Notes

- The preview decodes on the CPU at 1/4 resolution by default. Frames are coalesced, so scrubbing never queues a backlog, and playback drops frames rather than lagging.
- The preview uses the clip's own colour settings, so Film-gamma clips look flat. Trimming doesn't touch the image data either way.
- When the app is run outside an `.app` bundle, the framework loads from the installed SDK. When it's packaged as a proper `.app`, embed `BlackmagicRawAPI.framework` in `Contents/Frameworks` and it gets picked up first.
