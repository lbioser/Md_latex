//
//  RunDelegateCallback.swift
//  customLabel
//
//  Created by libing on 6/3/25.
//

import Foundation

class RunDelegateInfo {
    let width: CGFloat
    let ascent: CGFloat
    let descent: CGFloat
    
    init(width: CGFloat, ascent: CGFloat, descent: CGFloat) {
        self.width = width
        self.ascent = ascent
        self.descent = descent
    }
}

// 释放回调
let deallocCallback: @convention(c) (UnsafeMutableRawPointer) -> Void = { info in
    Unmanaged<RunDelegateInfo>.fromOpaque(info).release()
}

// Ascent 回调（基线以上高度）
let getAscentCallback: @convention(c) (UnsafeMutableRawPointer) -> CGFloat = { info in
    let data = Unmanaged<RunDelegateInfo>.fromOpaque(info).takeUnretainedValue()
    return data.ascent
}

// Descent 回调（基线以下高度）
let getDescentCallback: @convention(c) (UnsafeMutableRawPointer) -> CGFloat = { info in
    let data = Unmanaged<RunDelegateInfo>.fromOpaque(info).takeUnretainedValue()
    return data.descent
}

// Width 回调（宽度）
let getWidthCallback: @convention(c) (UnsafeMutableRawPointer) -> CGFloat = { info in
    let data = Unmanaged<RunDelegateInfo>.fromOpaque(info).takeUnretainedValue()
    return data.width
}
