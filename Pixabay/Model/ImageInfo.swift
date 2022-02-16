//
//  ImageInfo.swift
//  Pixabay
//
//  Created by Muhammad Anum on 02/02/2022.
//

import Foundation


struct ImageInfo: Decodable {
    var id: Int
    var previewURL: URL?
    var webformatURL: URL?
    var likes: Int
    var views: Int
    var downloads: Int
    var tags: String?
    var user: String?
    var userImageURL: String?
    var comments: Int?

}
