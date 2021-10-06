//
//  XMarkButton.swift
//  CryptoApp
//
//  Created by Thor on 06/10/2021.
//

import SwiftUI

struct XMarkButton: View {
    
//    @Environment(\.presentationMode) var presentationMode
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "xmark")
                .font(.headline)
        })
    }
}

struct XMarkButton_Previews: PreviewProvider {
    static var previews: some View {
        XMarkButton()
    }
}
