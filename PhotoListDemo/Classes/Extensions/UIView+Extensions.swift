//
//  UIView+Extensions.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/26.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit

extension UIView {
    /// 해당하는 constraint를 찾아 반환함.
    ///
    /// - Parameter attribute: attribute
    /// - Returns: constraint
    func getConstraint(attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        //first, find on super
        var constraint = superview?.constraints.filter({ $0.firstItem === self && $0.firstAttribute == attribute }).first
        constraint = constraint == nil ? superview?.constraints.filter({ $0.secondItem === self && $0.secondAttribute == attribute }).first : constraint
        
        //second, find on self
        constraint = constraint == nil ? self.constraints.reversed().filter({ $0.firstItem === self && $0.firstAttribute == attribute }).first : constraint
        return constraint
    }
    
    /// 현재 뷰의 뷰컨트롤러 인스턴스
    var parentViewControllerOfSelf: UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            parentResponder = responder.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
