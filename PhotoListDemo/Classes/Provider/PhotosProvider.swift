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
    
    /// 사용자 프로필 정보 요청
    ///
    /// - Parameter userId: 사용자 아이디 - Sandbox에서는 self만 제공
    /// - Returns: 사용자 모델
//    func user(_ userId: String) -> Observable<User?> {
//        return request(api: .user(userId)) //API에서 self만 제공함.
//            .map(UserResponse.self)
//            .map { $0.data }
//    }
}

