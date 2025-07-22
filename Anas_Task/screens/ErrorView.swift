//
//  ErrorView.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//

import SwiftUI

// MARK: - Helper Views
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(8)
                .padding()
                .onTapGesture {
                    retryAction()
                }
        }
    }
}
