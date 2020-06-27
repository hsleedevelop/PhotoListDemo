//
//  SearchResultModel.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/27.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation

// MARK: - Photo
struct SearchResult: Codable {
    var total: Int?
    var totla_page: Int?
    var results: [Photo]?
}

