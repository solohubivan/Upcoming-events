//
//  UIView+FindViewController.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 20.09.2024.
//

import UIKit

extension UIView {
    func findViewController() -> UIViewController? {
        var nextResponder: UIResponder? = self
        while let responder = nextResponder {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            nextResponder = responder.next
        }
        return nil
    }
}
