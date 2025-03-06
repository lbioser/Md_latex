//
//  LBLabel2.swift
//  Md_latex
//
//  Created by libing on 6/3/25.
//

import UIKit
import CoreText

class LBLabel2: UIView {
    
    var placeholerRects: [CGRect] = [] //占位rect
    
    var attributedText: NSAttributedString?
    
    override func draw(_ rect: CGRect) {
        
        DispatchQueue.global().async {[self] in
            
            let render = UIGraphicsImageRenderer(bounds: bounds)
            let img = render.image { renderCtx in
                let ctx = renderCtx.cgContext
//                ctx.saveGState()
                ctx.textMatrix = .identity
                ctx.scaleBy(x: 1, y: -1)
                ctx.translateBy(x: 0, y: -bounds.height)
                guard let attributedText else {
                    ctx.restoreGState()
                    return
                }
                let frameSetter = CTFramesetterCreateWithAttributedString(attributedText)
                let ctframe = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributedText.length), UIBezierPath(rect: bounds).cgPath, nil)
                // 建设尺寸，能容纳的最小尺寸
                let s = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRange.zero, nil, bounds.size, nil)
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

                        if let runDelegate = attributes[kCTRunDelegateAttributeName as NSAttributedString.Key] {
                            let d = runDelegate as! CTRunDelegate
                            let rundelegateInfoP = CTRunDelegateGetRefCon(runDelegate as! CTRunDelegate)
                            let info = Unmanaged<RunDelegateInfo>.fromOpaque(rundelegateInfoP).takeUnretainedValue()
                            let viewRect = CGRect(x: leading+offsetx, y: bounds.height - (origin.y-descent) - (ascent+descent), width: w, height: ascent+descent)
                            placeholerRects.append(viewRect)
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
    
}

let defaultAtr = {
    let atr = NSMutableAttributedString(string: "1234567890asd jkl kl 1we re we && * f8)) )())))) |||| fdf /// fd; fd fd;; ///// // // // // 34 ")
  
    let para = NSMutableParagraphStyle()
    para.lineSpacing = 10
    atr.addAttribute(.paragraphStyle, value: para, range: atr.range)
    atr.addAttribute(.kern, value: 5, range: atr.range)
    atr.insert(NSAttributedString(string: "high high low low", attributes: [.font:UIFont.systemFont(ofSize: 30)]), at: 20)
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
