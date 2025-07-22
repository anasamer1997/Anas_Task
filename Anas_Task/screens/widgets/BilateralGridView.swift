//
//  BilateralGridView.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//

import SwiftUI
struct BilateralGridView: View {
    let content: [Content]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(content, id: \.articleID) { item in
                    BilateralGridItem(content: item)
                }
            }
            .padding(.horizontal)
        }
    }
}
