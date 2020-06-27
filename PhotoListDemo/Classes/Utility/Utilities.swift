//
//  Reusable.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/25.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

struct Utilities {
    static func rect(forSize size: CGSize) -> CGRect {
        return CGRect(origin: .zero, size: size)
    }
    
    static func aspectFitRect(forSize size: CGSize, insideRect: CGRect) -> CGRect {
        return AVMakeRect(aspectRatio: size, insideRect: insideRect)
    }
}
