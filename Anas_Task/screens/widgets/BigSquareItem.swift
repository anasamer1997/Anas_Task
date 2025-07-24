//
//  DefaultGridItem.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//
import SwiftUI


struct BigSquareItem<ContentType: DisplayableContent>: View {
    let content: ContentType
    
    var body: some View {
        VStack(spacing: 8) {
            CachedAsyncImage(url: URL(string: content.displayImageURL)) { image in
                AnyView(
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 250, height: 250)
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
            
            
          
                VStack(alignment: .leading){
                    Text("name:" + content.displayName)
                        .font(.subheadline.bold())
                        .lineLimit(1)

                    Text("score:\(content.displayScore)")
                        .font(.subheadline.bold())
                        .lineLimit(1)
                   
                }.frame(maxWidth: .infinity,alignment: .leading)
               
            
           
        }
    }
}
