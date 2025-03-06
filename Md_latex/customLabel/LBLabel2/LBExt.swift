//
//  LBExt.swift
//  customLabel
//
//  Created by libing on 6/3/25.
//

import Foundation


extension CFRange {
    static var zero: CFRange {
        return CFRange(location: 0, length: 0)
    }
}

extension NSAttributedString {
    var range: NSRange {
        return NSRange(location: 0, length: self.length)
    }
}

extension NSAttributedString.Key {
    
    static let click: Self = .init("click") // Bool, true:可点
    
    
}
