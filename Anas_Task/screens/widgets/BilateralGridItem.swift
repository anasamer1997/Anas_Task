//
//  BilateralGridItem.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//
import SwiftUI

struct BilateralGridItem: View {
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
                    Color.gray
                        .frame(width: 150, height: 150)
                        .cornerRadius(8)
                )
            }
            
            Text(content.name)
                .font(.subheadline.bold())
                .lineLimit(1)
            
            if let author = content.authorName?.rawValue, !author.isEmpty {
                Text(author)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 150)
    }
}
