//
//  QRScannerVC.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 24.09.2024.
//

import UIKit
import AVFoundation

class QRScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupScanner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    // MARK: - Public methods
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }

            let event = parseEventFromQRCodeString(stringValue)

            if let event = event {

                let eventsManager = EventsManager()
                eventsManager.addReceivedEvent(event)
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            dismiss(animated: true)
        }
    }
    
    // MARK: - Private methods
    
    private func setupScanner() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
    
    private func parseEventFromQRCodeString(_ qrCodeString: String) -> EventModel? {
        let components = qrCodeString.components(separatedBy: "\n")
        
        guard components.count >= 3 else { return nil }
        
        let title = components[0].replacingOccurrences(of: "Event: ", with: "")
        let startDateString = components[1].replacingOccurrences(of: "Start: ", with: "")
        let endDateString = components[2].replacingOccurrences(of: "End: ", with: "")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        if let startDate = dateFormatter.date(from: startDateString),
           let endDate = dateFormatter.date(from: endDateString) {
            return EventModel(title: title, startDate: startDate, endDate: endDate)
        }
        
        return nil
    }
}
