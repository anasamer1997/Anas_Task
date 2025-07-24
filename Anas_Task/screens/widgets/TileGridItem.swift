//
//  TileGridItem.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//
import SwiftUI


struct TileGridItem<ContentType: DisplayableContent>: View {
    let content: ContentType
    
    var body: some View {
        HStack(spacing: 8) {
            CachedAsyncImage(url: URL(string: content.displayImageURL)) { image in
                AnyView(
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 90, height: 120)
                        .cornerRadius(8)

                )
            } placeholder: {
                AnyView(
                    Color.gray
                        .frame(width: 150, height: 150)
                        .cornerRadius(8)
                )
            }
            
            Text(content.displayName)
                .font(.subheadline.bold())
                .lineLimit(2)
        }
        .background(Color.red)
   
    }
}
