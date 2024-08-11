//
//  UIViewController+KeyboardHandling.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 11.08.2024.
//

import UIKit

extension UIViewController {
    
    func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = .zero
    }
}
