//
//  UnsplashAPI.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/26.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation

protocol API {
    var url: String { get }
}

enum UnsplashAPI: API {
    static let domain: String = "https://api.unsplash.com"
    static let clientId = "Cucxa-WzacTQknrD5Ocu-RUARI4rMoDiUbag81fT88A"
    
    ///포토 리스트
    case list(Int, Int)
    ///검색
    case search(Int, Int, String)
    
    private var path: String {
        switch self {
        case let .list(page, pageSize):
            return "/photos?page=\(page)&per_page=\(pageSize)&client_id=\(Self.clientId)"
        case let .search(page, pageSize, keyword):
            return "/search/photos?query=\(keyword)&page=\(page)&per_page=\(pageSize)&client_id=\(Self.clientId)"
        }
    }
    
    var method: String {
        switch self {
        default:
            return "GET"
        }
    }
    
    var url: String {
        return Self.domain + self.path
    }
}
