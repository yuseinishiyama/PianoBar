# PianoBar 🎹

**Turn any MIDI keyboard into an instant piano**

A minimal macOS menu bar app that makes your MIDI keyboard always playable. No setup, no DAW, just plug in and play.

## Features

- 🎵 **Instant Sound** - Connects automatically to any MIDI keyboard
- 🎹 **Zero Configuration** - Just launch and play
- 🔇 **Stays Out of Your Way** - Lives quietly in your menu bar
- 🚀 **Lightweight** - Minimal memory and CPU usage

## Installation

### Download Pre-built App (Easiest)

1. Download the latest `PianoBar.app.zip` from [Releases](https://github.com/yuseinishiyama/PianoBar/releases)
2. Unzip the file
3. Drag `PianoBar.app` to your Applications folder
4. **Remove quarantine** (required for unsigned apps):
   ```bash
   xattr -cr /Applications/PianoBar.app
   ```
5. Open PianoBar from Applications
6. PianoBar will appear in your menu bar

### Build from Source

```bash
git clone https://github.com/yuseinishiyama/PianoBar.git
cd PianoBar
xcodebuild -configuration Release
# App will be in build/Release/PianoBar.app
```

## Requirements

- macOS 11.0 or later
- MIDI keyboard/controller

## Usage

1. Connect your MIDI keyboard (before or after launching - hot-plug supported!)
2. Launch PianoBar
3. Play!

To quit: Click the menu bar icon → Quit PianoBar

## Why PianoBar?

Sometimes you just want to play your MIDI keyboard on your desk. No DAW loading, no sound browsing, no project files. PianoBar gives your MIDI keyboard a voice instantly, making it as simple to play as an acoustic piano.
