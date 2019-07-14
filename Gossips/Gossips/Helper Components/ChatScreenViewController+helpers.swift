//
//  ChatScreenViewController.swift
//  FireBase Demo
//
//  Created by mahmoud mohamed on 7/8/19.
//  Copyright © 2019 Robusta. All rights reserved.
//

import UIKit
import AVFoundation

class ChatScreenViewController: UIViewController,AVAudioRecorderDelegate,AVAudioPlayerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    var audioRecorder:AVAudioRecorder!
    var audioSession:AVAudioSession!
    var audioPlayer:AVAudioPlayer!
    var playing:Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        playing = false
        // Do any additional setup after loading the view.
    }
    
    func getVoiceNoteURL()->URL{
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        url.appendPathComponent("new.wav")
        return url
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        let dirPath=NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let fileName="new.wav"
        let path=[dirPath,fileName]
        let filePath=NSURL.fileURL(withPathComponents: path)
        let audioSession=AVAudioSession.sharedInstance()
        try! audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try! audioRecorder=AVAudioRecorder(url: filePath!, settings: [:])
        try! audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        audioRecorder.delegate=self
        audioRecorder.isMeteringEnabled=true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
    }
    
    func playAudio(){
        do{
            self.playing = true
            audioPlayer = try AVAudioPlayer(contentsOf: getVoiceNoteURL())
            audioPlayer.delegate = self
            audioPlayer.volume = 1.0
            audioPlayer.play()
        }
        catch{
            print("Error: ",error.localizedDescription)
        }
    }
    

    @IBAction func playButtonTapped(_ sender: Any) {
        playAudio()
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        if playing{
            audioPlayer.stop()
            self.playing = false
        }
        else{
            audioRecorder.stop()
        }
    }
    
    @IBAction func insertPhoto(_ sender: Any) {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.allowsEditing = false
        self.present(imagePickerVC,animated: true)
    }
}

extension ChatScreenViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.imageView.image = info[.originalImage] as? UIImage
        picker.dismiss(animated: true,completion: nil)
    }
}
