import AVFoundation

class AudioEngine {
    private let engine = AVAudioEngine()
    private let sampler = AVAudioUnitSampler()

    init() {
        setupAudio()
    }

    private func setupAudio() {
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)

        do {
            try engine.start()

            // Load the default sound bank (General MIDI)
            // This gives us the built-in piano and other instruments
            try sampler.loadSoundBankInstrument(
                at: Bundle.main.url(forResource: "gs_instruments", withExtension: "dls") ??
                    URL(fileURLWithPath: "/System/Library/Components/CoreAudio.component/Contents/Resources/gs_instruments.dls"),
                program: 0,  // Piano is program 0 in General MIDI
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB)
            )
        } catch {
            print("Failed to setup audio engine: \(error)")
        }
    }

    func playNote(_ note: UInt8, velocity: UInt8, on: Bool) {
        if on {
            sampler.startNote(note, withVelocity: velocity, onChannel: 0)
        } else {
            sampler.stopNote(note, onChannel: 0)
        }
    }
}