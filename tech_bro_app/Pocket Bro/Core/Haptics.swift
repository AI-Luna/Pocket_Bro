//
//  Haptics.swift
//  Pocket Bro
//

import UIKit

enum Haptics {
    /// Light tap — for selecting items in a list/grid
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    /// Medium impact — for confirming an action (e.g. Next button, executing an action)
    static func confirm() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
