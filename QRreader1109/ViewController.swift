//
//  ViewController.swift
//  QRreader1109
//
//  Created by yutaka takagaki on 2018/11/10.
//  Copyright © 2018年 yutaka takagaki. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var textfield: UITextField!
    
    // セッションインスタンンス
    let captureSession = AVCaptureSession()
    var videoLayer: AVCaptureVideoPreviewLayer?
    
    var qrView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // QRコードをマークするView
        qrView = UIView()
        qrView.layer.borderWidth = 4
        qrView.layer.borderColor = UIColor.red.cgColor
        qrView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        view.addSubview(qrView)
        
        let discoverrySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                 mediaType: .video,
                                                                 position: .back)
        
        let devices = discoverrySession.devices
        
        if let backCamera = devices.first {
            do {
                // Input(backCamera)
                let videoInput = try AVCaptureDeviceInput.init(device: backCamera)
                captureSession.addInput(videoInput)
                
                // Output (METAData)
                let metadataOutput = AVCaptureMetadataOutput()
                captureSession.addOutput(metadataOutput)
                
                //QR delegate
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
                
                // preView
                videoLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
                videoLayer?.frame = previewView.bounds
                videoLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                previewView.layer.addSublayer(videoLayer!)
                
                // go session
                DispatchQueue.global(qos: .userInitiated).async {
                    self.captureSession.startRunning()
                }
                
                
            } catch {
                print("Error occured while creating video device input: \(error)")
            }
        }
        

    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection){
        // 複数のメタデータの検出
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject]{
            // QR code確認
            if metadata.type == AVMetadataObject.ObjectType.qr {
                // position
                let barCode = videoLayer?.transformedMetadataObject(for: metadata) as! AVMetadataMachineReadableCodeObject
                qrView!.frame = barCode.bounds
                if metadata.stringValue != nil{
                    // data in textField
                    textfield.text = metadata.stringValue!
                }
            }
            
        }
        
    }
}



