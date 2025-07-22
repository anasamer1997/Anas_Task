//
//  CachedAsyncImage.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//

import SwiftUI
struct CachedAsyncImage: View {
    let url: URL?
    let content: (Image) -> AnyView
    let placeholder: () -> AnyView
    
    @State private var imageData: Data?
    
    var body: some View {
        Group {
            if let data = imageData, let uiImage = UIImage(data: data) {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .task {
                        await loadImage()
                    }
            }
        }
    }
    
    private func loadImage() async {
        guard let url = url, imageData == nil else { return }
        
        if let cachedData = ImageCache.shared.get(for: url) {
            imageData = cachedData
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            ImageCache.shared.set(data, for: url)
            imageData = data
        } catch {
            print("Image loading failed: \(error)")
        }
    }
}
class ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSURL, NSData>()
    
    func get(for url: URL) -> Data? {
        cache.object(forKey: url as NSURL) as Data?
    }
    
    func set(_ data: Data, for url: URL) {
        cache.setObject(data as NSData, forKey: url as NSURL)
    }
}
