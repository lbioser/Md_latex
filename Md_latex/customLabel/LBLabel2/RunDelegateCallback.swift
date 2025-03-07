//
//  RunDelegateCallback.swift
//  customLabel
//
//  Created by libing on 6/3/25.
//

import Foundation
import CoreText

func createRunDelegate(info: RunDelegateInfo) -> Any {
    // 转换为指针并保留引用计数
    let infoPointer = Unmanaged.passRetained(info).toOpaque()
    
    var callbacks = CTRunDelegateCallbacks(
        version: kCTRunDelegateVersion1,
        dealloc: deallocCallback,
        getAscent: getAscentCallback,
        getDescent: getDescentCallback,
        getWidth: getWidthCallback
    )
    
    let rundelegate = CTRunDelegateCreate(&callbacks, infoPointer)
    
    return rundelegate as Any
}


class RunDelegateInfo {
    var data: Data? //图片数据
    var frame: CGRect = .zero
    weak var run: CTRun?
    let width: CGFloat // 自定义宽度
    let ascent: CGFloat // 基线以上高度
    let descent: CGFloat // 基线以下高度
    
    init(data: Data? = nil, width: CGFloat, ascent: CGFloat, descent: CGFloat) {
        self.data = data
        self.width = width
        self.ascent = ascent
        self.descent = descent
    }
    
    static let zero = RunDelegateInfo(width: 0, ascent: 0, descent: 0)
    
    deinit {
        print(self,#function)
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
