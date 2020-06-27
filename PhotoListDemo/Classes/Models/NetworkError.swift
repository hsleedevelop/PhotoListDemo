//
//  NetworkError.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/26.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation


///API 또는 네트워크 에러
enum NetworkError: Error {
    case error(String)
    
    var message: String {
        switch self {
        case .error(let message):
            return message
        }
    }
}

