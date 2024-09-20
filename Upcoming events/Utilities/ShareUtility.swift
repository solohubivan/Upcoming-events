//
//  ShareUtility.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 20.09.2024.
//

import UIKit

class ShareUtility {
    
    func createShareViewController(contentToShare: String, sourceView: UIView) -> UIActivityViewController {
        let shareViewController = UIActivityViewController(activityItems: [contentToShare], applicationActivities: nil)

        if let popoverController = shareViewController.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        }

        return shareViewController
    }
}
