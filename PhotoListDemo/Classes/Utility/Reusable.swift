//
//  Reusable.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/25.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit

protocol Reusable {
    static var reuseId: String {get}
}

extension Reusable {
    static var reuseId: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Reusable {}

extension UIViewController: Reusable {}

extension UITableView {
    func dequeueReusableCell<T>(ofType cellType: T.Type = T.self, at indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseId,
                                             for: indexPath) as? T else {
            fatalError()
        }
        return cell
    }
}

extension UIStoryboard {
    func instantiateViewController<T>(ofType type: T.Type = T.self) -> T where T: UIViewController {
        guard let viewController = instantiateViewController(withIdentifier: type.reuseId) as? T else {
            fatalError()
        }
        return viewController
    }
}
