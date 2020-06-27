//
//  APIProvider.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/26.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift

///네트워크 통신 프로바이더
class APIProvider<T: API> {
    
}

extension APIProvider {
    
    /// API request
    /// moya concept을 빌려옴
    /// - Parameter api: api path generic
    /// - Returns: response date
    func request(api: T) -> Observable<Data> {
        
        guard let url = URL(string: api.url) else {
            return Observable.error(NetworkError.error("잘못된 URL입니다."))
        }
        
        #if DEBUG
        print("url=\(url)")
        #endif
        
        //또는 -> URLSession.shared.rx.json(request: request)
        return Observable.create { observer in
            
            let request = NSMutableURLRequest(url: url)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if 200 ... 399 ~= statusCode {//서버의 응답 결과 정의 후 다양하게 처리 가능..
                        observer.onNext(data ?? Data())
                    } else {
                        observer.onError(NetworkError.error(HTTPURLResponse.localizedString(forStatusCode: statusCode)))
                    }
                }
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
