//
//  ObservableType+Extensions.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/26.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift

/// extesion from Moya RxSwift
extension ObservableType where Element == Data {
    /// Maps received data at key path into a Decodable object. If the conversion fails, the signal errors.
    func map<D: Decodable>(_ type: D.Type) -> Observable<D> {
        return flatMap { response -> Observable<D> in
            return Observable.just(try response.map(type))
        }
    }
}
