//
//  DefaultGridItem.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//
import SwiftUI


struct DefaultGridItem: View {
    let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CachedAsyncImage(url: URL(string: content.avatarURL)) { image in
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

            
            Text(content.name)
                .font(.subheadline.bold())
                .lineLimit(2)
                .frame(width: 120)
        }
    }
}
