//
//  ServerResponse.swift
//  Pixabay
//
//  Created by Muhammad Anum on 02/02/2022.
//

import Foundation

struct ServerResponse<Object: Decodable> : Decodable {
    var hits: [Object]
}
