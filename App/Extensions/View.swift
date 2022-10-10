//
//  View.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-10.
//

import Foundation
import SwiftUI

extension View {
    
    
    func debugBackground(_ color: Color) -> some View{
        #if DEBUG
        return background(color)
        #endif
        
        return background(Color(.clear))
    }
}
