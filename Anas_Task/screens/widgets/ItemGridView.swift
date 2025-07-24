//
//  TileGridItem.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//
import SwiftUI

struct ItemGridView :View {
    let item:DisplayableContent
    var body: some View {
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
    }
}
