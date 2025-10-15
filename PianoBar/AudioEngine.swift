import AVFoundation

class AudioEngine {
    private let engine = AVAudioEngine()
    private let sampler = AVAudioUnitSampler()
    private(set) var isReady = false

    init() {
        setupAudio()

        // Listen for audio device changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleConfigurationChange),
            name: .AVAudioEngineConfigurationChange,
            object: engine
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        engine.stop()
    }

    private func setupAudio() {
        // Only attach if not already attached
        if !engine.attachedNodes.contains(sampler) {
            engine.attach(sampler)
            engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        }

        do {
            try engine.start()

            // Load the default sound bank (General MIDI)
            try sampler.loadSoundBankInstrument(
                at: Bundle.main.url(forResource: "gs_instruments", withExtension: "dls") ??
                    URL(fileURLWithPath: "/System/Library/Components/CoreAudio.component/Contents/Resources/gs_instruments.dls"),
                program: 0,  // Piano is program 0 in General MIDI
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB)
            )
            isReady = true
        } catch {
            print("Failed to setup audio engine: \(error)")
        }
    }

    @objc private func handleConfigurationChange(notification: Notification) {
        print("Audio output changed, restarting...")
        // The engine stops automatically on configuration change
        // Just re-run the setup which will restart everything properly
        isReady = false
        setupAudio()
    }

    func playNote(_ note: UInt8, velocity: UInt8, on: Bool) {
        guard isReady else { return }
        if on {
            sampler.startNote(note, withVelocity: velocity, onChannel: 0)
        } else {
            sampler.stopNote(note, onChannel: 0)
        }
    }
}