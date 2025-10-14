import CoreMIDI
import Foundation

// Global variable to hold reference and callback
var globalMIDIManager: MIDIManager?

class MIDIManager {
    private var midiClient = MIDIClientRef()
    private var inputPort = MIDIPortRef()
    var noteHandler: ((UInt8, UInt8, Bool) -> Void)?  // note, velocity, isOn

    init() {
        globalMIDIManager = self
        setupMIDI()
    }

    private func setupMIDI() {
        // Create MIDI client
        MIDIClientCreate("PianoBar" as CFString, nil, nil, &midiClient)

        // Create input port with simple callback
        let callback: MIDIReadProc = { (packetList, srcConnRefCon, connRefCon) in
            globalMIDIManager?.handleMIDIPackets(packetList)
        }

        MIDIInputPortCreate(midiClient, "PianoBar Input" as CFString, callback, nil, &inputPort)

        // Connect to all MIDI sources
        connectToAllSources()
    }

    private func connectToAllSources() {
        let sourceCount = MIDIGetNumberOfSources()
        for i in 0..<sourceCount {
            let source = MIDIGetSource(i)
            MIDIPortConnectSource(inputPort, source, nil)
        }
    }

    private func handleMIDIPackets(_ packetList: UnsafePointer<MIDIPacketList>) {
        let packets = packetList.pointee
        var packet = packets.packet

        for _ in 0..<packets.numPackets {
            // Safely extract bytes from packet data
            let length = Int(packet.length)
            if length >= 3 {
                // Direct byte access without Mirror
                withUnsafeBytes(of: packet.data) { bytes in
                    let status = bytes[0] & 0xF0
                    let note = bytes[1]
                    let velocity = bytes[2]

                    // Handle Note On (0x90) and Note Off (0x80)
                    DispatchQueue.main.async { [weak self] in
                        if status == 0x90 && velocity > 0 {
                            self?.noteHandler?(note, velocity, true)
                        } else if status == 0x80 || (status == 0x90 && velocity == 0) {
                            self?.noteHandler?(note, velocity, false)
                        }
                    }
                }
            }

            packet = MIDIPacketNext(&packet).pointee
        }
    }
}