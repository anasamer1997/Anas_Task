//
//  TileGridView.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//

import SwiftUI

struct TwoItemsGrid<ContentType: DisplayableContent>: View {
    let content: [ContentType]
    init(content: [ContentType]) {
        self.content = content
    }
    private let rows = [
        GridItem(.fixed(120)),
        GridItem(.fixed(120))
    ]
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows) {
                ForEach(content, id: \.uniqueID) { item in
                    ItemGridView(item: item)
                    .frame(width: 350, height: 120) // Full width
                    .cornerRadius(10)
                    .shadow(radius: 2)
                        
                       
                }
            }
            .padding(.horizontal)
           
        }
    }
}

