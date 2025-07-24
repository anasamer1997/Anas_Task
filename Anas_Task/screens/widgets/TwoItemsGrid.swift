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
    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .gray, .black, .white]
    private let rows = [
        GridItem(.fixed(120)),
        GridItem(.fixed(120))
    ]
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows) {
                ForEach(content, id: \.uniqueID) { item in
                    HStack{
                        CachedAsyncImage(url: URL(string: item.displayImageURL)) { image in
                            AnyView(
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(8)

                            )
                        } placeholder: {
                            AnyView(
                                Color.gray
                                    .frame(width: 150, height: 150)
                                    .cornerRadius(8)
                            )
                        }
                        
                        Text(item.displayName)
                    }
                    .frame(width: 250, height: 120) // Full width
                    .cornerRadius(10)
                    .shadow(radius: 2)
                        
                       
                }
            }
            .padding(.horizontal)
        }
    }
}
