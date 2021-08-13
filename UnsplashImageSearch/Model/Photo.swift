//
//  Photo.swift
//  UnsplashImageSearch
//
//  Created by Yupin Hu on 8/13/21.
//

import Foundation

struct Photo: Equatable {
    let id: String
    let thumbnail: URL
    let url: URL
    let likes: Int
    let description: String
}
