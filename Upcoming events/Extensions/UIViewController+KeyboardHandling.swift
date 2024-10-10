//
//  UIViewController+KeyboardHandling.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 11.08.2024.
//

import UIKit

extension UIViewController {

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
