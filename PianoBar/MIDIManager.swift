import CoreMIDI
import Foundation

// Global variable to hold reference and callback
var globalMIDIManager: MIDIManager?

class MIDIManager {
    private var midiClient = MIDIClientRef()
    private var inputPort = MIDIPortRef()
    var noteHandler: ((UInt8, UInt8, Bool) -> Void)?  // note, velocity, isOn
    private(set) var isConnected = false
    var deviceChangeHandler: (() -> Void)?  // Called when devices change

    init() {
        globalMIDIManager = self
        setupMIDI()
    }

    deinit {
        if inputPort != 0 {
            MIDIPortDispose(inputPort)
        }
        if midiClient != 0 {
            MIDIClientDispose(midiClient)
        }
    }

    private func setupMIDI() {
        // Notification callback for MIDI setup changes
        let notifyCallback: MIDINotifyProc = { (notification, connRefCon) in
            let message = notification.pointee
            if message.messageID == .msgSetupChanged {
                // MIDI setup changed - reconnect
                DispatchQueue.main.async {
                    globalMIDIManager?.reconnectMIDI()
                }
            }
        }

        // Create MIDI client with notification callback
        let clientStatus = MIDIClientCreate("PianoBar" as CFString, notifyCallback, nil, &midiClient)
        guard clientStatus == noErr else {
            print("Failed to create MIDI client: \(clientStatus)")
            return
        }

        // Create input port with simple callback
        let callback: MIDIReadProc = { (packetList, srcConnRefCon, connRefCon) in
            globalMIDIManager?.handleMIDIPackets(packetList)
        }

        let portStatus = MIDIInputPortCreate(midiClient, "PianoBar Input" as CFString, callback, nil, &inputPort)
        guard portStatus == noErr else {
            print("Failed to create MIDI port: \(portStatus)")
            return
        }

        // Connect to all MIDI sources
        connectToAllSources()
    }

    private func connectToAllSources() {
        let sourceCount = MIDIGetNumberOfSources()
        isConnected = sourceCount > 0
        for i in 0..<sourceCount {
            let source = MIDIGetSource(i)
            MIDIPortConnectSource(inputPort, source, nil)
        }
    }

    private func reconnectMIDI() {
        // Simply reconnect to all current sources
        connectToAllSources()
        let sourceCount = MIDIGetNumberOfSources()
        print("MIDI devices changed: \(sourceCount) device(s) connected")

        // Notify UI to update
        deviceChangeHandler?()
    }

    private func handleMIDIPackets(_ packetList: UnsafePointer<MIDIPacketList>) {
        let packets = packetList.pointee
        var packet = packets.packet

        for _ in 0..<packets.numPackets {
            let length = Int(packet.length)

            // Only process valid Note On/Off messages (exactly 3 bytes)
            if length == 3 {
                withUnsafeBytes(of: packet.data) { bytes in
                    let statusByte = bytes[0]
                    let status = statusByte & 0xF0

                    // Only process Note On (0x90) and Note Off (0x80)
                    if status == 0x90 || status == 0x80 {
                        let note = bytes[1]
                        let velocity = bytes[2]

                        // Validate note and velocity are in valid MIDI range
                        if note <= 127 && velocity <= 127 {
                            DispatchQueue.main.async { [weak self] in
                                if status == 0x90 && velocity > 0 {
                                    self?.noteHandler?(note, velocity, true)
                                } else if status == 0x80 || (status == 0x90 && velocity == 0) {
                                    self?.noteHandler?(note, velocity, false)
                                }
                            }
                        }
                    }
                }
            }

            packet = MIDIPacketNext(&packet).pointee
        }
    }
}