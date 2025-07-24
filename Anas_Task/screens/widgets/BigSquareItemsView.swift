//
//  DefaultGridView.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//

import SwiftUI

struct BigSquareItemsView<ContentType: DisplayableContent>: View {
    let content: [ContentType]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(content, id: \.uniqueID) { item in
                    BigSquareItem(content: item)
                }
            }
            .padding(.horizontal)
        }
    }
}
