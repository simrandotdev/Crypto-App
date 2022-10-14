//
//  SearchBarView.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-14.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var searchText: String
    @FocusState var searchFieldActive: Bool
    
    var body: some View {
        
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(
                    searchText.isEmpty ? .theme.secondaryText : .theme.accent
                )
            TextField("Search by name or Symbol", text: $searchText)
                .foregroundColor(.theme.accent)
                .autocorrectionDisabled()
                .focused($searchFieldActive)
            Spacer()
            
            if !searchText.isEmpty {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.theme.secondaryText)
                    .onTapGesture {
                        searchText = ""
                        searchFieldActive = false
                    }
            }
        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.theme.background)
                .shadow(
                    color: Color.theme.accent.opacity(0.15),
                    radius: 10,
                    x: 0, y: 0
                )
        )
        
    }
}

struct SearchBarView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            SearchBarView(searchText: .constant("Hello"))
                .previewLayout(.sizeThatFits)
            
            SearchBarView(searchText: .constant(""))
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}
