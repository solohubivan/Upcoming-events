//
//  UILabel+CustomFont.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 11.08.2024.
//

import UIKit

extension UILabel {
    func setCustomFont(name: String, size: CGFloat, textStyle: UIFont.TextStyle) {
        if let customFont = UIFont(name: name, size: size) {
            self.font = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: customFont)
            self.adjustsFontForContentSizeCategory = true
        }
    }
}
