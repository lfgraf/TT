import SwiftUI
import Speech
import AVFoundation

// Handles speech recognition (converting spoken words to text)
class SpeechRecognitionManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    // The speech recognizer that processes audio
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    // The current recognition request
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    // The current recognition task
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // The audio engine that captures microphone input
    private let audioEngine = AVAudioEngine()
    
    // Published properties that the UI can observe
    @Published var isListening = false
    @Published var recognizedText = ""
    @Published var errorMessage: String?
    
    override init() {
        super.init()
        speechRecognizer?.delegate = self
    }
    
    // Request permission to use speech recognition
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self.errorMessage = nil
                case .denied:
                    self.errorMessage = "Speech recognition access denied by user."
                case .restricted, .notDetermined:
                    self.errorMessage = "Speech recognition not available on this device."
                @unknown default:
                    self.errorMessage = "Unknown error with speech recognition authorization."
                }
            }
        }
    }
    
    // Start listening for speech input
    func startListening() {
        // Clear previous task if any
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Set up audio session for recording
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Could not configure audio session: \(error.localizedDescription)"
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest,
              let speechRecognizer = speechRecognizer,
              speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition not available"
            return
        }
        
        // Configure microphone input
        let inputNode = audioEngine.inputNode
        
        // Set up the recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                // Update the recognized text as results come in
                self.recognizedText = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            // Handle completion or errors
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.isListening = false
            }
        }
        
        // Start recording
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isListening = true
        } catch {
            errorMessage = "Could not start audio engine: \(error.localizedDescription)"
            isListening = false
        }
    }
    
    // Stop listening for speech input
    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isListening = false
    }
}

// Handles speech synthesis (converting text to spoken words)
class SpeechSynthesizer: NSObject, ObservableObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    // The speech synthesizer that generates spoken audio
    private let synthesizer = AVSpeechSynthesizer()
    
    // Published property that tracks if the synthesizer is currently speaking
    @Published var isSpeaking = false
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // Speak the provided text with the specified voice
    func speak(text: String, with voiceIdentifier: String = "com.apple.voice.compact.en-US.Samantha") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier)
        
        // Adjust speech parameters to sound more natural
        utterance.rate = 0.5       // Speaking speed (0.0 to 1.0)
        utterance.pitchMultiplier = 1.0  // Voice pitch
        utterance.volume = 1.0     // Volume level
        
        synthesizer.speak(utterance)
        isSpeaking = true
    }
    
    // Stop any ongoing speech
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    // Called when speech finishes
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}
