//
//  LBExt.swift
//  customLabel
//
//  Created by libing on 6/3/25.
//

import UIKit
import CoreText

extension CFRange {
    static var zero: CFRange {
        return CFRange(location: 0, length: 0)
    }
}

extension NSAttributedString {
    var range: NSRange {
        return NSRange(location: 0, length: self.length)
    }
    
    static func + (l: NSAttributedString, r: NSAttributedString) -> NSMutableAttributedString {
        let t = NSMutableAttributedString(attributedString: l)
        t.append(r)
        return t
    }
    
    //MARK: convinence create NSMutableAttributedString
    static func normal(_ str: String) -> NSMutableAttributedString {
        let t = NSMutableAttributedString(string: str)
        return t
    }
    
    static func click(_ str: String) -> NSMutableAttributedString {
        let t = NSMutableAttributedString.placeholer(.zero)
        t.append(.normal(str).click(true))
        t.append(NSMutableAttributedString.placeholer(.zero))
        return t
    }
    
    static func placeholer(_ info: RunDelegateInfo) -> NSMutableAttributedString {
        let t = NSMutableAttributedString.normal(invisibleCharString)
        return t.kRunDelegate(info)
    }
    
}

extension NSMutableAttributedString {
    //MARK: - addAttribute
    @discardableResult
    func font(_ font: UIFont) -> Self {
        addAttribute(.font, value: font, range: range)
        return self
    }
    
    @discardableResult
    func paragraphStyle(_ style: NSParagraphStyle) -> Self {
        addAttribute(.paragraphStyle, value: style, range: range)
        return self
    }
    
    @discardableResult
    func foregroundColor(_ color: UIColor) -> Self {
        addAttribute(.foregroundColor, value: color, range: range)
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        addAttribute(.backgroundColor, value: color, range: range)
        return self
    }
    
    @discardableResult
    func ligature(_ n: Int) -> Self {
        addAttribute(.ligature, value: n, range: range)
        return self
    }
    
    @discardableResult
    func kern(_ n: Int) -> Self {
        addAttribute(.kern, value: n, range: range)
        return self
    }
    
    @discardableResult
    func strikethroughStyle(_ n: Int) -> Self {
        addAttribute(.strikethroughStyle, value: n, range: range)
        return self
    }
    
    @discardableResult
    func underlineStyle(_ n: Int) -> Self {
        addAttribute(.underlineStyle, value: n, range: range)
        return self
    }
    
    @discardableResult
    func strokeColor(_ color: UIColor) -> Self {
        addAttribute(.strokeColor, value: color, range: range)
        return self
    }
    
    @discardableResult
    func strokeWidth(_ n: Int) -> Self {
        addAttribute(.strokeWidth, value: n, range: range)
        return self
    }
    
    @discardableResult
    func shadow(_ shadow: NSShadow) -> Self {
        addAttribute(.shadow, value: shadow, range: range)
        return self
    }
    
    @discardableResult
    func textEffect(_ str: String) -> Self {
        addAttribute(.textEffect, value: str, range: range)
        return self
    }
    
    @discardableResult
    func attachment(_ attachment: NSTextAttachment) -> Self {
        addAttribute(.attachment, value: attachment, range: range)
        return self
    }
    
    @discardableResult
    func link(_ url: NSURL) -> Self {
        addAttribute(.link, value: url, range: range)
        return self
    }
    
    @discardableResult
    func baselineOffset(_ n: Int) -> Self {
        addAttribute(.baselineOffset, value: n, range: range)
        return self
    }
    
    @discardableResult
    func underlineColor(_ color: UIColor) -> Self {
        addAttribute(.underlineColor, value: color, range: range)
        return self
    }
    
    @discardableResult
    func strikethroughColor(_ color: UIColor) -> Self {
        addAttribute(.strikethroughColor, value: color, range: range)
        return self
    }
    
    @discardableResult
    func writingDirection(_ v: [Int]) -> Self {
        addAttribute(.writingDirection, value: v, range: range)
        return self
    }
    //MARK: - custom
    
    @discardableResult
    func click(_ can: Bool) -> Self {
        addAttribute(.click, value: can, range: range)
        return self
    }
    
    @discardableResult
    func kRunDelegate(_ info: RunDelegateInfo) -> Self {
        addAttribute(.kRunDelegate, value: createRunDelegate(info: info), range: range)
        return self
    }
    
    @discardableResult
    func truncate() -> Self {
        addAttribute(.truncate, value: 1, range: range)
        return self
    }
    
    @discardableResult
    func strokeBorder() -> Self {
        addAttribute(.strokeBorder, value: 1, range: range)
        return self
    }
    @discardableResult
    func seletedColor(_ color: UIColor) -> Self {
        addAttribute(.seletedColor, value: color, range: range)
        return self
    }
    //MARK: -
}

//MARK: - custom key
extension NSAttributedString.Key {
    
    static let click: Self = .init("click") // Bool, true:可点
    
    static let kRunDelegate: Self = .init(kCTRunDelegateAttributeName as String)
    
    static let truncate: Self = .init("truncate") //用于标记省略点
    
    static let strokeBorder: Self = .init("strokeBorder") //边框
    
    static let seletedColor: Self = .init("seletedColor") //选中时的颜色 UIColor
    
    enum ClickType {
        case click(String)  //点了click修饰的文本
        case placeholder(RunDelegateInfo) //点了占位图
        case truncate //点了省略号
    }
    
}


extension CTRun {
    var isClick: Bool {
        let attributes = CTRunGetAttributes(self) as! [NSAttributedString.Key:Any]
        if let _ = attributes[.click] {
            return true
        }
        return false
    }
    var isKRunDelegate: Bool {
        let attributes = CTRunGetAttributes(self) as! [NSAttributedString.Key:Any]
        if let _ = attributes[.kRunDelegate] {
            return true
        }
        return false
    }
    var isTruncate: Bool {
        let attributes = CTRunGetAttributes(self) as! [NSAttributedString.Key:Any]
        if let _ = attributes[.truncate] {
            return true
        }
        return false
    }
    
    var isStrokeBorder: Bool {
        let attributes = CTRunGetAttributes(self) as! [NSAttributedString.Key:Any]
        if let _ = attributes[.strokeBorder] {
            return true
        }
        return false
    }
    
    func seletedColor() -> UIColor? {
        let attributes = CTRunGetAttributes(self) as! [NSAttributedString.Key:Any]
        if let color = attributes[.seletedColor] as? UIColor {
            return color
        }
        return nil
    }
}
