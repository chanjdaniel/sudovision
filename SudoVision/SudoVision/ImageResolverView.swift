//
//  ImageResolverView.swift
//
//
//  Created by Daniel Chan on 2023-08-07.
//

import Foundation
import SwiftUI
import Photos

struct ImageResolverView: View {
    var asset: PhotoAsset?
    var cache: CachedImageManager?
    var passedPhoto: Image?
    @State private var image: Image?
    @State private var imageRequestID: PHImageRequestID?
    @Environment(\.dismiss) var dismiss
    private let imageSize = CGSize(width: 1024 * 2, height: 1024 * 2)
    
    var body: some View {
        ZStack {
            if let image = image {
                SolverView(image: image)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Solver")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if passedPhoto != nil {
                self.image = passedPhoto
                return
            }
            guard image == nil, let cache = cache else { return }
            imageRequestID = await cache.requestImage(for: asset!, targetSize: imageSize) { result in
                Task {
                    if let result = result {
                        self.image = result.image
                    }
                }
            }
        }
    }
}
