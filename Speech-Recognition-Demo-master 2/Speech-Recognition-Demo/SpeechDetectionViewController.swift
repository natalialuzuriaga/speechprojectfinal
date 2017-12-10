//
//  SpeechDetectionViewController.swift
//  Speech-Recognition-Demo
//
//  Created by urmum on 3/3/17.
//  Copyright © 2017 Team. All rights reserved.
//

import UIKit
import Speech

class SpeechDetectionViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var wordToSay: UILabel!
    @IBOutlet weak var pronounciationLabel: UILabel!
    var wordChosen = "test"
    var pronounceChosen = "test"
    var randomNum = 0
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setWord()
        self.requestSpeechAuthorization()
    }
    
    func setWord(){
        //selects random word from arrays and displays it in labels
        randomNum = randomValue(lowestVal: 0, highestVal: 4)
        wordChosen = randomWord(num: randomNum)
        pronounceChosen = setPronounce(num: randomNum)
        wordToSay.text = wordChosen
        pronounciationLabel.text = pronounceChosen
    }
    
//MARK: IBActions and Cancel
    @IBAction func touchDown(_ sender: AnyObject) {
        self.recordAndRecognizeSpeech()
        startButton.backgroundColor = UIColor.red
    }
    
    @IBAction func touchUpInside(_ sender: AnyObject) {
        request.endAudio() // Added line to mark end of recording
        audioEngine.stop()
        
        if let node = audioEngine.inputNode {
            node.removeTap(onBus: 0)
        }
        recognitionTask?.cancel()
        
        startButton.backgroundColor = UIColor.gray
    }

    
    func cancelRecording() {
        audioEngine.stop()
        if let node = audioEngine.inputNode {
            node.removeTap(onBus: 0)
        }
        recognitionTask?.cancel()
    }
    
//MARK: - Recognize Speech

    func recordAndRecognizeSpeech() {
        guard let node = audioEngine.inputNode else { return }
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if result != nil { // check to see if result is empty (i.e. no speech found)
                if let result = result {
                    let bestString = result.bestTranscription.formattedString
                    self.detectedTextLabel.text = bestString
                    
                    var lastString: String = ""
                    for segment in result.bestTranscription.segments {
                        let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                        lastString = bestString.substring(from: indexTo)
                    }
                    self.checkForColorsSaid(resultString: lastString)
                    
                } else if let error = error {
                    self.sendAlert(message: "There has been a speech recognition error")
                    print(error)
                }
            }
            
        })
    }
    
//MARK: - Check Authorization Status

func requestSpeechAuthorization() {
    SFSpeechRecognizer.requestAuthorization { authStatus in
        OperationQueue.main.addOperation {
            switch authStatus {
            case .authorized:
                self.startButton.isEnabled = true
            case .denied:
                self.startButton.isEnabled = false
                self.detectedTextLabel.text = "User denied access to speech recognition"
            case .restricted:
                self.startButton.isEnabled = false
                self.detectedTextLabel.text = "Speech recognition restricted on this device"
            case .notDetermined:
                self.startButton.isEnabled = false
                self.detectedTextLabel.text = "Speech recognition not yet authorized"
            }
        }
    }
}
    
//MARK: - UI / Set view color.
    
    func checkForColorsSaid(resultString: String) {
        switch resultString {
        case wordChosen:
            colorView.backgroundColor = UIColor.green
            sleep(1)
            self.setWord()
            print("k")
        default: colorView.backgroundColor = UIColor.red
            
        }
    }
    
    func randomWord(num: Int) -> String{
        //parameter is the random value -> will set to a random word
        var wordList = ["Dog", "Cat", "Fish", "Gorilla", "Chinchilla"]
        return wordList[num]
    
    }
    
    func setPronounce(num:Int) -> String{
        //parameter is the random value -> will set word
        var pronounceList = ["/dôɡ/", "/kat/", "/fiSH/", "/ɡəˈrilə/", "/CHinˈCHilə/"]
        return pronounceList[num]
    }
    
//MARK: - Alert
    
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func randomValue(lowestVal: Int, highestVal: Int) -> Int {
        //SELECTS A RANDOM VALUE WITH GIVEN RANGE
        let result = Int(arc4random_uniform(UInt32(highestVal - lowestVal + 1))) + lowestVal
        return result
    }
}
