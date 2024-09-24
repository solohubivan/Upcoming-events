//
//  GenerateQRViewController.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 24.09.2024.
//

import UIKit
import CoreImage.CIFilterBuiltins

class ShowQRViewController: UIViewController {
    
    private var qrImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Public methods
    
    public func makeQRCodeForString(text: String) {
        guard let qrImage = generateQRCode(from: text) else { return }
        qrImageView.image = qrImage
    }
    
    // MARK: - Private methods
    
    private func generateQRCode(from string: String) -> UIImage? {
        guard !string.isEmpty else { return nil }
        let data = string.data(using: .utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
            
        if let qrCodeImage = filter.outputImage {
            let transformedImage = qrCodeImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            return UIImage(ciImage: transformedImage)
        } else {
            return nil
        }
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .white
        setupQRImageView()
    }
    
    private func setupQRImageView() {
        qrImageView.contentMode = .scaleAspectFit
        
        view.addSubview(qrImageView)
        qrImageView.addConstraints(to_view: view, [
            .centerX(anchor: view.centerXAnchor, constant: 0),
            .centerY(anchor: view.centerYAnchor, constant: 0),
            .width(constant: 250),
            .height(constant: 250)
        ])
    }
}
