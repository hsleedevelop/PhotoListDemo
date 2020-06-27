//
//  UIViewController+Extensions.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/27.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    ///얼럿 출력
    func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        var cancelTitle = "화인"
        if let completion = completion {
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                completion()
            }
            alert.addAction(okAction)
            cancelTitle = "취소"
        }
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .default)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }
}
