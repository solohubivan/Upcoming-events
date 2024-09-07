//
//  UIView+hitTest.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 31.08.2024.
//

import UIKit

class TouchPassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        if hitView == self {
            return nil
        }
        return hitView
    }
}
