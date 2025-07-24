//
//  BilateralGridItem.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//
import SwiftUI

struct BilateralGridItem<ContentType: DisplayableContent>: View {
    let content: ContentType
    
    var body: some View {
        VStack(alignment: .leading) {
           
            CachedAsyncImage(url: URL(string: content.displayImageURL)) { image in
                AnyView(
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .cornerRadius(8)
                )
            } placeholder: {
                AnyView(
                    Color.gray
                        .frame(width: 150, height: 150)
                        .cornerRadius(8)
                )
            }
            
            VStack(alignment: .leading){
                Text(content.displayName)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                
                Text("score:\(content.displayScore)")
                    .font(.subheadline.bold())
                    .lineLimit(1)
            }
          
        }
        .frame(width: 150,alignment: .leading)
        
        
    }
}
