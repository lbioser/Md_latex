//
//  LBLabel.swift
//  Md_latex
//
//  Created by libing on 6/3/25.
//

import UIKit
import CoreText
/// 就像普通的label一样使用
/// 支持背景色，换行，自适应size，占位图，省略号，点击某个字符
class LBLabel: UILabel {
    
    public override var attributedText: NSAttributedString? {
        didSet {
//            if oldValue?.string == attributedText?.string { return }
            setNeedsDisplay()
        }
    }
    
    public override var text: String? {
        didSet {
            guard let text else { return }
            attributedText = .normal(text).font(font).foregroundColor(textColor)
        }
    }
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            if isUserInteractionEnabled {
                addGestureRecognizer(tapGesture)
                addGestureRecognizer(pressGesture)
            } else {
                removeGestureRecognizer(tapGesture)
                removeGestureRecognizer(pressGesture)
            }
        }
    }
    
    public var placeholerRects: [RunDelegateInfo] = [] //占位rectInfo
    
    public var updateHeightHandler: ((CGFloat) -> ())?
    
    public var clickHandler: ((NSAttributedString.Key.ClickType) -> ())?
    
    private var textSuggestHeight: CGFloat = 0 {
        didSet {
            DispatchQueue.main.async {[self] in
                updateHeightHandler?(textSuggestHeight)
            }
        }
    }
    
    private var lineRunsModels: [LBLineRunsModel] = []
    
    //MARK: - core draw
    
    override func draw(_ rect: CGRect) {
        clear()
        guard let attributedText else {
            return
        }
        let numberOfLines = numberOfLines
        //height大了之后会很卡,先取10_000
        let realHeight = bounds.height
        let height: CGFloat = 10_000
        let width: CGFloat = bounds.width
        let esatimalBounds = CGRect(x: 0, y: 0, width: width, height: height) //让attributedText能绘制完，不截断，所以设置了很大的高
        print("------------")
        DispatchQueue.global().async {[self] in
            
            let frameSetter = CTFramesetterCreateWithAttributedString(attributedText)
            let ctframe = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributedText.length), UIBezierPath(rect: esatimalBounds).cgPath, nil)
            
            let lines = CTFrameGetLines(ctframe) as! [CTLine]
            let lineCount = lines.count
            let count = (numberOfLines == 0) ? lineCount : min(lineCount, numberOfLines)
            // 判断是否需要展示截断符，小于总行数都需要展示截断符。
            let needShowTruncation = count < lineCount;
            
            let lineRange = CTLineGetStringRange(lines[count-1])
            // 建设尺寸，能容纳的最小尺寸
            let suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRange(location: 0, length: (lineRange.location + lineRange.length)), nil, esatimalBounds.size, nil)
            
            
            
            var origins:[CGPoint] = .init(repeating: .zero, count: lineCount)
            CTFrameGetLineOrigins(ctframe, CFRange.zero, &origins)
            
            let renderBounds = CGRect(x: 0, y: 0, width: width, height: realHeight) // 实际渲染的rect，和esatimalBounds不一样大
            let render = UIGraphicsImageRenderer(bounds: renderBounds)
            let img = render.image { renderCtx in
                setBackGroundColor(renderCtx, in: renderBounds)
                let ctx = renderCtx.cgContext
                ctx.saveGState()
                ctx.textMatrix = .identity
                resetDrawCoordinate(on: ctx, height: height)
                
                //手动调整行高
//                var i = -1
//                origins = origins.map({ p in
//                    i += 1
//                    return .init(x: p.x, y: p.y+CGFloat(-10*i))
//                })
                
                for i in 0..<count { // line
                    var line = lines[i]
                    if i == count-1 && needShowTruncation { //最后一行要展示省略符的
                        let lineRange = CTLineGetStringRange(line)
                        line = createTruncatedLine(lineRange: lineRange) ?? line
                    }
                    
                    var lineRunsModel = LBLineRunsModel(line: line, runs: [])
                    lineRunsModels.append(lineRunsModel)
                    let runs = CTLineGetGlyphRuns(line) as! [CTRun]
                    // 一旦我们通过CTLineDraw绘制文字后，那么需要我们自己来设置行的位置，否则都位于最底下显示。
                    let origin = origins[i]
                    ctx.textPosition = CGPoint(x: origin.x, y: origin.y)
                    let runCount = runs.count

                    for j in 0..<runCount { // run
                        let run = runs[j]
                        CTRunDraw(run, ctx, CFRange.zero) // 画
                        if run.isStrokeBorder {
                            strokerBorder(on: run, in: line, lineOrigin: origin, with: ctx) //画边框
                        }
                        let realRunRect = calcRunRect(run: run, line: line, lineOrigin: origin, base: esatimalBounds)
                       
                        lineRunsModel.runs.append(LBRunModel(run: run, rect: realRunRect))
                       
                        if let seletedColor = run.seletedColor() {
//                            let layer = CALayer()
//                            layer.backgroundColor = seletedColor.cgColor
//                            ctx.draw(CGLayer(layer), in: realRunRect)
                            ctx.setFillColor(seletedColor.cgColor)
                            ctx.fill([realRunRect])
                        }
                        
                        let attributes = CTRunGetAttributes(run) as! [NSAttributedString.Key:Any]
                        if let runDelegate = attributes[.kRunDelegate] {
                            let rundelegateInfoP = CTRunDelegateGetRefCon(runDelegate as! CTRunDelegate)
                            let info = Unmanaged<RunDelegateInfo>.fromOpaque(rundelegateInfoP).takeUnretainedValue()
                            info.frame = realRunRect //记录
                            info.run = run
                            placeholerRects.append(info)
                        }
                    }
                    
                }
                ctx.restoreGState()
            }
            
            DispatchQueue.main.async {[self] in
                textSuggestHeight = suggestSize.height
                self.layer.contents = img.cgImage
                placeholerRects.forEach { info in
                    guard let data = info.data else { return }
                    let v = UIImageView(image: UIImage(data: data))
                    v.frame = info.frame
                    v.backgroundColor = .gray
                    addSubview(v)
                }
            }
            
        }
        
    }
    
    deinit {
        print(self,#function)
    }
    //MARK: - backgroundColor
    
    private func setBackGroundColor(_ renderCtx: UIGraphicsImageRendererContext, in renderBounds: CGRect) {
        // 设置填充颜色为红色
        backgroundColor?.setFill()
           // 填充整个绘制区域
        renderCtx.fill(renderBounds)
    }
    
    private func resetDrawCoordinate(on ctx: CGContext, height: CGFloat) {
        ctx.translateBy(x: 0, y: height)
        ctx.scaleBy(x: 1, y: -1)
    }
    
    //MARK: - stroke border
    
    private func calcRunRect(run: CTRun, line: CTLine, lineOrigin origin: CGPoint,base esatimalBounds: CGRect) -> CGRect {
        let range = CTRunGetStringRange(run)
        let offsetx = CTLineGetOffsetForStringIndex(line, range.location, nil)
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var leading: CGFloat = 0
        let w = CTRunGetTypographicBounds(run, CFRange.zero, &ascent, &descent, &leading)
        
        let realRunRect = CGRect(x: leading+offsetx, y: esatimalBounds.height - (origin.y-descent) - (ascent+descent), width: w, height: ascent+descent)
        return realRunRect
    }
    
    private func strokerBorder(on run: CTRun, in line: CTLine, lineOrigin origin: CGPoint, with ctx: CGContext) {
        let range = CTRunGetStringRange(run)
        let offsetx = CTLineGetOffsetForStringIndex(line, range.location, nil)
        
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
    }
    
    
    //MARK: - TruncatedLine ...
    
    private func createTruncatedLine(lineRange: CFRange) -> CTLine? {
        let truncationAtr = NSAttributedString.normal("...").font(font).foregroundColor(textColor).truncate()
        let drawLineAtr = attributedText!.attributedSubstring(from: NSRange(location: lineRange.location, length: lineRange.length)) + truncationAtr
        let drawLine = CTLineCreateWithAttributedString(drawLineAtr as CFAttributedString)
        let truncationTokenLine = CTLineCreateWithAttributedString(truncationAtr)
        
        let truncatedLine = CTLineCreateTruncatedLine(drawLine, bounds.width, .end, truncationTokenLine)
        return truncatedLine
    }
    
    
    
    //MARK: - for click
    
    lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapClick))
    
    lazy var pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressClick))
    
    @objc private func tapClick(_ gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .ended:
            let location = gesture.location(in: self)
            let runRects = lineRunsModels.reduce([LBRunModel]()) { partialResult, lineRunsModel in
                return partialResult+lineRunsModel.runs
            }
            for runRect in runRects {
                if runRect.rect.contains(location) {
                    if runRect.run.isTruncate {  //点到了省略号
                        clickHandler?(.truncate)
                    } else if runRect.run.isKRunDelegate { //点到了占位图
                        if let info = getRunDelegateInfo(by: runRect.run) {
                            clickHandler?(.placeholder(info))
                        }
                        
                    } else if runRect.run.isClick{ //点到了被标记为click的run
                        let clickedStr = joinRuns(findAroundRun(by: .click, around: runRect.run))
                        clickHandler?(.click(clickedStr))
                    }
                    
                    break
                }
            }
        default:
            break
        }
    }
    
    @objc private func longPressClick(_ gesture: UILongPressGestureRecognizer) {
        var startIndex: CFIndex = 0
        var endIndex: CFIndex = 0
        switch gesture.state {
        case .began:
            let p = gesture.location(in: self)
            var line = getLineByPoint(p)
            guard let line else { return }
            startIndex = CTLineGetStringIndexForPosition(line, p)
        case  .changed, .ended:
            let p = gesture.location(in: self)
            var line = getLineByPoint(p)
            guard let line else { return }
            
            endIndex = CTLineGetStringIndexForPosition(line, p)
            
            let atr = attributedText?.mutableCopy() as? NSMutableAttributedString
            let range = NSRange(location: Int(startIndex), length: abs(Int(startIndex) - Int(endIndex)))
            atr?.seletedColor(.red)
            attributedText = atr
            
            
        default:
            break
        }
    }
    
    private func getLineByPoint(_ p: CGPoint) -> CTLine? {
        var line: CTLine?
        for lineRunsModel in lineRunsModels {
            for runRect in lineRunsModel.runs {
                if runRect.rect.contains(p) {
                    line = lineRunsModel.line
                    return line
                }
            }
        }
        return nil
    }
    
    private func getRunDelegateInfo(by: CTRun) -> RunDelegateInfo? {
        return placeholerRects.first { info in
            info.run == by
        }
        
    }
    
    
    /// 查找run附近的run，有一样的属性key
    /// - Parameters:
    ///   - key: key
    ///   - run: 被查找的run
    /// - Returns: 附近的runs
    private func findAroundRun(by key: NSAttributedString.Key, around run: CTRun) -> [CTRun] {
        let attributes = CTRunGetAttributes(run) as! [NSAttributedString.Key:Any]
        var runs: [CTRun] = []
        let runRects = lineRunsModels.reduce([LBRunModel]()) { partialResult, lineRunsModel in
            return partialResult+lineRunsModel.runs
        }
        if let index = runRects.firstIndex(where: { r in
            r.run == run
        }), attributes[key] != nil {
            
            runs.append(run)
            // 向前找：
            for i in stride(from: index-1, to: -1, by: -1) {
                let attributes = CTRunGetAttributes(runRects[i].run) as! [NSAttributedString.Key:Any]
                if let _ = attributes[key] {
                    runs.insert(runRects[i].run, at: 0)
                } else {
                    break
                }
              
            }
            //向后找：
            for i in stride(from: index+1, to: runRects.count, by: 1) {
                let attributes = CTRunGetAttributes(runRects[i].run) as! [NSAttributedString.Key:Any]
                if let _ = attributes[key] {
                    runs.append(runRects[i].run)
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
        lineRunsModels.removeAll(keepingCapacity: true)
        subviews.forEach { $0.removeFromSuperview() }
    }
    
}


//MARK: temp demo NSMutableAttributedString for test
let invisibleCharString = String(Unicode.Scalar(0xFFFC)!)
let truncateCharString = String(Unicode.Scalar(0x2026)!) //...
let defaultAtr = {
    let atr = NSMutableAttributedString.normal("1234567890asd jkl kl 1we re we && * f8)) )())))) |||| fdf /// fd; fd fd;; ///// // // // // 34 ").font(.systemFont(ofSize: 20))
    let para = NSMutableParagraphStyle()
    para.lineSpacing = 0
    atr.paragraphStyle(para)
    
    atr.insert(.click("High Low").font(.boldSystemFont(ofSize: 20)).foregroundColor(.green).strokeBorder(), at: 0)
//    atr.insert(.click("Book").font(.systemFont(ofSize: 10)), at: 0)

    let info = RunDelegateInfo(
        data: UIImage(named: "1")?.pngData(),
        width: 55,   // 自定义宽度
        ascent: 40,   // 基线以上高度
        descent: 5    // 基线以下高度
    )

    atr.insert(.placeholer(info), at: 9)
    
    let info1 = RunDelegateInfo(
        data: UIImage(named: "2")?.pngData(),
        width: 100,   // 自定义宽度
        ascent: 40,   // 基线以上高度
        descent: 5    // 基线以下高度
    )

    atr.insert(.placeholer(info1), at: 10)
    
    let info2 = RunDelegateInfo(
        data: UIImage(named: "3")?.pngData(),
        width: 200,   // 自定义宽度
        ascent: 40,   // 基线以上高度
        descent: 5    // 基线以下高度
    )
    atr.insert(.placeholer(info2), at: 19)

    return atr
}()
