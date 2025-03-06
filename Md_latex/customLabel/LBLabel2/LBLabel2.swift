//
//  LBLabel2.swift
//  Md_latex
//
//  Created by libing on 6/3/25.
//

import UIKit
import CoreText

class LBLabel2: UIView {
    
    public var attributedText: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var placeholerRects: [CGRect] = [] //占位rect
    
    private(set) var textSuggestHeight: CGFloat = 0 {
        didSet {
            DispatchQueue.main.async {[self] in 
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    private var runRects: [(CTRun,CGRect)] = []
    
    
    
    //MARK: - core draw
    
    override func draw(_ rect: CGRect) {
        
        clear()
        let bounds = bounds
        guard let attributedText else {
            return
        }
        DispatchQueue.global().async {[self] in
            
            let render = UIGraphicsImageRenderer(bounds: bounds)
            let img = render.image { renderCtx in
                let ctx = renderCtx.cgContext
//                ctx.saveGState()
                ctx.textMatrix = .identity
                ctx.scaleBy(x: 1, y: -1)
                ctx.translateBy(x: 0, y: -bounds.height)
                
                let frameSetter = CTFramesetterCreateWithAttributedString(attributedText)
                let ctframe = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributedText.length), UIBezierPath(rect: bounds).cgPath, nil)
                // 建设尺寸，能容纳的最小尺寸
                let suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRange.zero, nil, bounds.size, nil)
                textSuggestHeight = suggestSize.height
                let lines = CTFrameGetLines(ctframe) as! [CTLine]
                let lineCount = lines.count
                var origins:[CGPoint] = .init(repeating: .zero, count: lineCount)
                CTFrameGetLineOrigins(ctframe, CFRange.zero, &origins)
               
                //手动调整行高
//                var i = -1
//                origins = origins.map({ p in
//                    i += 1
//                    return .init(x: p.x, y: p.y+CGFloat(-10*i))
//                })
                
                for i in 0..<lineCount {
                    let line = lines[i]
                    let runs = CTLineGetGlyphRuns(line) as! [CTRun]
                    // 一旦我们通过CTLineDraw绘制文字后，那么需要我们自己来设置行的位置，否则都位于最底下显示。
                    let origin = origins[i]
                    ctx.textPosition = CGPoint(x: origin.x, y: origin.y)
                    let runCount = runs.count
                   
                    for j in 0..<runCount {
                        let run = runs[j]
                        let range = CTRunGetStringRange(run)
                        
                        let offsetx = CTLineGetOffsetForStringIndex(line, range.location, nil)
                        CTRunDraw(run, ctx, CFRange.zero) // 画

                        var ascent: CGFloat = 0
                        var descent: CGFloat = 0
                        var leading: CGFloat = 0
                        let w = CTRunGetTypographicBounds(run, CFRange.zero, &ascent, &descent, &leading)
                        ctx.saveGState()
                        
                        let runRect = CGRect(x: leading+offsetx, y: origin.y-descent, width: w, height: ascent+descent)
                        let p = UIBezierPath(rect: runRect)
                        p.lineWidth = 1
                        UIColor.red.setStroke()
                        ctx.addPath(p.cgPath)
                        ctx.strokePath()
                        ctx.restoreGState()
                        
                        
                        
                        let attributes = CTRunGetAttributes(run) as! [NSAttributedString.Key:Any]
                        
                        let realRunRect = CGRect(x: leading+offsetx, y: bounds.height - (origin.y-descent) - (ascent+descent), width: w, height: ascent+descent)
                        
                        runRects.append((run, realRunRect))
                        
                        if let runDelegate = attributes[kCTRunDelegateAttributeName as NSAttributedString.Key] {
                            let d = runDelegate as! CTRunDelegate
                            let rundelegateInfoP = CTRunDelegateGetRefCon(runDelegate as! CTRunDelegate)
                            let info = Unmanaged<RunDelegateInfo>.fromOpaque(rundelegateInfoP).takeUnretainedValue()
                            
                            placeholerRects.append(realRunRect)
                        }
                        
                        if let clicked = attributes[.click] as? Bool, clicked{
                            
                        }
                        
                        
                    }
                    
                }
                ctx.restoreGState()
            }
            
            DispatchQueue.main.async {
                self.layer.contents = img.cgImage
                placeholerRects.forEach { rect in
                    let v = UIView(frame: rect)
                    v.backgroundColor = .gray
                    addSubview(v)
                }
            }
            
        }
        
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: textSuggestHeight)
    }
    
    
    //MARK: -
    
    
    
    
    //MARK: - for click
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        let location = touch?.location(in: self) ?? CGPoint(x: 0, y: CGFloat.infinity)
        for (run, rect) in runRects {
            if rect.contains(location) {
                let clickedStr = joinRuns(findAroundRun(by: .click, around: run))
                print(clickedStr)
                break
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
    }
    
    
    /// 查找run附近的run，有一样的属性key
    /// - Parameters:
    ///   - key: key
    ///   - run: 被查找的run
    /// - Returns: 附近的runs
    private func findAroundRun(by key: NSAttributedString.Key, around run: CTRun) -> [CTRun] {
        let attributes = CTRunGetAttributes(run) as! [NSAttributedString.Key:Any]
        var runs: [CTRun] = []
        if let index = runRects.firstIndex(where: { (r, rect) in
            r == run
        }), attributes[key] != nil {
            
            runs.append(run)
            // 向前找：
            for i in stride(from: index-1, to: 0, by: -1) {
                let attributes = CTRunGetAttributes(runRects[i].0) as! [NSAttributedString.Key:Any]
                if let _ = attributes[key] {
                    runs.insert(runRects[i].0, at: 0)
                } else {
                    break
                }
              
            }
            //向后找：
            for i in stride(from: index+1, to: runRects.count, by: 1) {
                let attributes = CTRunGetAttributes(runRects[i].0) as! [NSAttributedString.Key:Any]
                if let _ = attributes[key] {
                    runs.append(runRects[i].0)
                } else {
                    break
                }
            }
            return runs
        }
        
        return []
    }
    
    
    private func joinRuns(_ runs: [CTRun]) -> String {
        var str = ""
        runs.forEach { run in
            let range = CTRunGetStringRange(run)
            let string = attributedText!.string
            let subStr = string[string.index(string.startIndex, offsetBy: range.location)..<string.index(string.startIndex, offsetBy: range.location+range.length)]
            str += subStr
        }
        
        return str
    }
    
    //MARK: - clear
    
    private func clear() {
        placeholerRects.removeAll(keepingCapacity: true)
        runRects.removeAll(keepingCapacity: true)
        subviews.forEach { $0.removeFromSuperview() }
    }
    
}






//MARK: temp demo NSMutableAttributedString for test

let defaultAtr = {
    let atr = NSMutableAttributedString(string: "1234567890asd jkl kl 1we re we && * f8)) )())))) |||| fdf /// fd; fd fd;; ///// // // // // 34 ")
  
    let para = NSMutableParagraphStyle()
    para.lineSpacing = 10
    atr.addAttribute(.paragraphStyle, value: para, range: atr.range)
    atr.addAttribute(.kern, value: 5, range: atr.range)
    atr.insert(NSAttributedString(string: "high high low low", attributes: [.font:UIFont.systemFont(ofSize: 30), .click:true]), at: 20)
    var callbacks = CTRunDelegateCallbacks(
        version: kCTRunDelegateVersion1,
        dealloc: deallocCallback,
        getAscent: getAscentCallback,
        getDescent: getDescentCallback,
        getWidth: getWidthCallback
    )
    
    let info = RunDelegateInfo(
        width: 100,   // 自定义宽度
        ascent: 20,   // 基线以上高度
        descent: 25    // 基线以下高度
    )
    // 转换为指针并保留引用计数
    let infoPointer = Unmanaged.passRetained(info).toOpaque()
    
   
    let rundelegate = CTRunDelegateCreate(&callbacks, infoPointer)
    
    atr.insert(NSAttributedString(string: String(Unicode.Scalar(0xFFFC)!), attributes: [kCTRunDelegateAttributeName as NSAttributedString.Key : rundelegate]), at: 9)
    return atr
}()


