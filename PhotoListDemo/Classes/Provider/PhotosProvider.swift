//
//  PhotosProvider.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/26.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift

/// 인스타그램 API 제공
final class PhotosProvider: APIProvider<UnsplashAPI> {
    static let shared = PhotosProvider()

    /// 포토 리스트를 요청
    func list(page: Int, pageSize: Int) -> Observable<[Photo]> {
        return request(api: .list(page, pageSize))
            .map([Photo].self)
    }
    
    /// 포토 리스트를 요청
    func search(page: Int, pageSize: Int, keyword: String) -> Observable<SearchResult> {
        return request(api: .search(page, pageSize, keyword))
            .map(SearchResult.self)
    }
}

