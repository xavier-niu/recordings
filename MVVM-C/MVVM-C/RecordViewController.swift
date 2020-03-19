//
//  RecordViewController.swift
//  MVVM-C
//
//  Created by XavierNiu on 2020/1/21.
//  Copyright © 2020 Xavier Niu. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

protocol RecordViewControllerDelegate: class {
    func finishedRecording(_ recordVC: RecordViewController)
}

class RecordViewController: UIViewController, AVAudioRecorderDelegate {
    
    let viewModel = RecordViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    
    weak var delegate: RecordViewControllerDelegate!
    var audioRecorder: Recorder?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.timeLabelText.bind(to: timeLabel.rx.text).disposed(by: disposeBag)
        viewModel.dismiss = { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // get audio recording by current file url
        // where does recording be updated?
        audioRecorder = viewModel.folder?.store?.fileURL(for: viewModel.recording).flatMap { url in
            Recorder(url: url) { [unowned self] time in
                self.viewModel.recorderStateChanged(time: time)
            }
        }
        
        if audioRecorder == nil {
            delegate.finishedRecording(self)
        }
    }

    @IBAction func stop(_ sender: Any) {
        audioRecorder?.stop()
        modalTextAlert(title: .saveRecording, accept: .save, placeholder: .nameForRecording) { string in
            self.viewModel.recordingStopped(title: string)
            self.delegate.finishedRecording(self)
        }
    }
    
}

fileprivate extension String {
    static let saveRecording = NSLocalizedString("Save recording", comment: "Heading for audio recording save dialog")
    static let save = NSLocalizedString("Save", comment: "Confirm button text for audio recoding save dialog")
    static let nameForRecording = NSLocalizedString("Name for recording", comment: "Placeholder for audio recording name text field")
}
