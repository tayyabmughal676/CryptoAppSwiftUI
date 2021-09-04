//
//  UIApplication.swift
//  CryptoApp
//
//  Created by Thor on 04/09/2021.
//

import Foundation
import SwiftUI

extension UIApplication{
    func endEditing(){
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


