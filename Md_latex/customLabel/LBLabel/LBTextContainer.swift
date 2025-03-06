//
//  LBTextContainer.swift
//  customLabel
//
//  Created by libing on 5/3/25.
//

import UIKit

class LBTextContainer: NSTextContainer {
    
    ///有多少行
    private(set) var numberOfLine: Int = 0
    
    override func lineFragmentRect(forProposedRect proposedRect: CGRect, at characterIndex: Int, writingDirection baseWritingDirection: NSWritingDirection, remaining remainingRect: UnsafeMutablePointer<CGRect>?) -> CGRect {
        
        let rect = super.lineFragmentRect(forProposedRect: proposedRect, at: characterIndex, writingDirection: baseWritingDirection, remaining: remainingRect)
         
        let y = proposedRect.origin.y
        
        if y == 0 {
            numberOfLine = 1
        } else {
            numberOfLine += 1
        }
        
        var width: CGFloat = 50
        if y > 50 {
            width = proposedRect.width
        }
        
        
        return rect
        
    }
    

}
