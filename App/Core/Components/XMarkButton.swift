//
//  XMarkButton.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-17.
//

import SwiftUI

struct XMarkButton: View {
    
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark")
        }
    }
}

struct XMarkButton_Previews: PreviewProvider {
    static var previews: some View {
        XMarkButton(action: {})
    }
}
