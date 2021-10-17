//
//  HapticManager.swift
//  CryptoApp
//
//  Created by Thor on 17/10/2021.
//

import Foundation
import UIKit

class HapticManager{
    static private let generator = UINotificationFeedbackGenerator()
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType){
        generator.notificationOccurred(type)
    }
}
