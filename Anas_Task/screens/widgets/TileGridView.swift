//
//  TileGridView.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//

import SwiftUI

struct TileGridView: View {
    let content: [Content]
    init(content: [Content]) {
        self.content = content
    }
    private let columns = [
        GridItem(.flexible(minimum: 100, maximum: 200), spacing: 8),
        GridItem(.flexible(minimum: 100, maximum: 200), spacing: 8)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(content, id: \.articleID) { item in
                TileGridItem(content: item)
            }
        }
        .padding(.horizontal)
    }
}
