//
//  PianoBarApp.swift
//  PianoBar
//
//  Created by Yusei Nishiyama on 2025-10-13.
//

import SwiftUI
import AppKit

@main
struct PianoBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var midiManager: MIDIManager!
    var audioEngine: AudioEngine!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "pianokeys", accessibilityDescription: "PianoBar")
        }

        // Initialize audio and MIDI
        audioEngine = AudioEngine()
        midiManager = MIDIManager()

        // Connect MIDI events to audio
        midiManager.noteHandler = { [weak self] note, velocity, isOn in
            self?.audioEngine.playNote(note, velocity: velocity, on: isOn)
        }

        // Create menu
        let menu = NSMenu()

        // Simple status text
        let status = midiManager.isConnected ? "Connected" : "No MIDI Device"
        menu.addItem(NSMenuItem(title: "MIDI: \(status)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit PianoBar", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }
}