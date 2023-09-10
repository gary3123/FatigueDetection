//
//  MainViewController.swift
//  CoreMLTest
//
//  Created by imac-3570 on 2023/7/15.
//

import UIKit
import AVFoundation
import CoreML
import ARKit

class MainViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var videoView: UIView!
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    //MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let captureSession = AVCaptureSession()
        let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        var input: AVCaptureDeviceInput?
        
        do {
            input = try AVCaptureDeviceInput(device: captureDevice!)
        } catch {
            print(error.localizedDescription)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        let outputData = AVCaptureVideoDataOutput()
        
        outputData.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(outputData)
        previewLayer.frame = videoView.frame
        videoView.layer.addSublayer(previewLayer)
        
        captureSession.addInput(input!)
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
        
    }
}

//MARK: - extension
extension MainViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        do {
            let modelConfigration = MLModelConfiguration()
            let model = try Fatigue_Detection_90_(configuration: modelConfigration)
            let input = Fatigue_Detection_90_Input(image: pixelBuffer!)
            let output = try model.prediction(input: input)
            if output.classLabelProbs.first!.value > 0.8 {
                print("使用者疲憊")
            } else {
                print("使用者不疲憊")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}



