//
//  DefaultGridItem.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//
import SwiftUI


struct DefaultGridItem<ContentType: DisplayableContent>: View {
    let content: ContentType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                    
                    ProgressView()
                        .frame(width: 120, height: 120)
                        .foregroundStyle(Color.white)
                        .background(Color.gray)
                        .cornerRadius(8)
                )
            }

            
            Text(content.displayName)
                .font(.subheadline.bold())
                .lineLimit(2)
                .frame(width: 120)
        }
    }
}
