//
//  HapticsManager.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-19.
//

import Foundation
import UIKit

class HapticsManager {
    
    static private let generator = UINotificationFeedbackGenerator()
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        generator.notificationOccurred(type)
    }
}
