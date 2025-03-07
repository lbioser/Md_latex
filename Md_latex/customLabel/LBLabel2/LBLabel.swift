//
//  LBLabel.swift
//  Md_latex
//
//  Created by libing on 6/3/25.
//

import UIKit
import CoreText

class LBLabel: UILabel {
    
    public override var attributedText: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var placeholerRects: [CGRect] = [] //占位rect
    
    public var updateHeightHandler: ((CGFloat) -> ())?
    
    private(set) var textSuggestHeight: CGFloat = 0 {
        didSet {
            DispatchQueue.main.async {[self] in
                updateHeightHandler?(textSuggestHeight)
            }
        }
    }
    
    private var runRects: [(CTRun,CGRect)] = []
    
    
    
    //MARK: - core draw
    
    override func draw(_ rect: CGRect) {
        clear()
        guard let attributedText else {
            return
        }
        //height大了之后会很卡,先取10_000
        let realHeight = bounds.height
        let height: CGFloat = 10_000
        let width: CGFloat = bounds.width
        let esatimalBounds = CGRect(x: 0, y: 0, width: width, height: height) //让attributedText能绘制完，不截断，所以设置了很大的高
        print("------------")
        DispatchQueue.global().async {[self] in
            
            let frameSetter = CTFramesetterCreateWithAttributedString(attributedText)
            let ctframe = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributedText.length), UIBezierPath(rect: esatimalBounds).cgPath, nil)
            // 建设尺寸，能容纳的最小尺寸
            let suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRange.zero, nil, esatimalBounds.size, nil)
           
            let lines = CTFrameGetLines(ctframe) as! [CTLine]
            let lineCount = lines.count
            var origins:[CGPoint] = .init(repeating: .zero, count: lineCount)
            CTFrameGetLineOrigins(ctframe, CFRange.zero, &origins)
            
            let renderBounds = CGRect(x: 0, y: 0, width: width, height: realHeight) // 实际渲染的rect，和esatimalBounds不一样大
            let render = UIGraphicsImageRenderer(bounds: renderBounds)
            let img = render.image { renderCtx in
                let ctx = renderCtx.cgContext
                ctx.saveGState()
                ctx.textMatrix = .identity
                ctx.translateBy(x: 0, y: height)
                ctx.scaleBy(x: 1, y: -1)
                
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
                        
                        let realRunRect = CGRect(x: leading+offsetx, y: esatimalBounds.height - (origin.y-descent) - (ascent+descent), width: w, height: ascent+descent)
                        
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
                textSuggestHeight = suggestSize.height
                self.layer.contents = img.cgImage
                placeholerRects.forEach { rect in
                    let v = UIView(frame: rect)
                    v.backgroundColor = .gray
                    addSubview(v)
                }
            }
            
        }
        
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
            for i in stride(from: index-1, to: -1, by: -1) {
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
let invisibleCharString = String(Unicode.Scalar(0xFFFC)!)

let defaultAtr = {
    let atr = NSMutableAttributedString.normal("1234567890asd jkl kl 1we re we && * f8)) )())))) |||| fdf /// fd; fd fd;; ///// // // // // 34 ")
  
    let para = NSMutableParagraphStyle()
    para.lineSpacing = 10
    atr.paragraphStyle(para)

    atr.insert(.click("High").font(.boldSystemFont(ofSize: 20)).foregroundColor(.red), at: 0)
    atr.insert(.click("Book"), at: 0)

    let info = RunDelegateInfo(
        width: 100,   // 自定义宽度
        ascent: 20,   // 基线以上高度
        descent: 25    // 基线以下高度
    )

    atr.insert(.placeholer(info), at: 9)
    
    let info1 = RunDelegateInfo(
        width: 150,   // 自定义宽度
        ascent: 20,   // 基线以上高度
        descent: 25    // 基线以下高度
    )

    atr.insert(.placeholer(info1), at: 10)
    
    let info2 = RunDelegateInfo(
        width: 250,   // 自定义宽度
        ascent: 20,   // 基线以上高度
        descent: 25    // 基线以下高度
    )
    atr.insert(.placeholer(info2), at: 19)

    return atr
}()
