//
//  LBLabel.swift
//  customLabel
//
//  Created by libing on 5/3/25.
//

import UIKit
class LBLabel: UILabel {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTextKit()
    }
    
    private func setTextKit() {
        textStorge.addLayoutManager(textLayoutManger)
        textLayoutManger.addTextContainer(textCotainer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override var attributedText: NSAttributedString? { //
        didSet {
            guard let attributedText else { return }
            textStorge.setAttributedString(attributedText)
            
            invalidateIntrinsicContentSize()
        }
    }
    
    override func draw(_ rect: CGRect) {
        textLayoutManger.drawBackground(forGlyphRange: attributedText!.range, at: .zero)
        textLayoutManger.drawGlyphs(forGlyphRange: attributedText!.range , at: .zero)
        
//        textLayoutManger.underlineGlyphRange(NSRange(location: 0, length: 2), underlineType: .double, lineFragmentRect: .zero, lineFragmentGlyphRange: NSRange(location: 0, length: 2), containerOrigin: .zero)
        textLayoutManger.drawUnderline(forGlyphRange: NSRange(location: 0, length: 2), underlineType: .double, baselineOffset: 0, lineFragmentRect: .zero, lineFragmentGlyphRange: NSRange(location: 0, length: 2), containerOrigin: .zero)
       
    }
   
    override var intrinsicContentSize: CGSize {
        return textLayoutManger.usedRect(for: textCotainer).size
    }
    
    
    
    
    lazy var textCotainer =  {
        let container = LBTextContainer()
        container.lineFragmentPadding = 0
        
        return container
    }()
    
    lazy var textLayoutManger = NSLayoutManager()
    
    lazy var textStorge = NSTextStorage()
    
    

}




extension NSAttributedString.Key {
    
    static let stroke: Self = .init("stroke")
    
    static let fill: Self = .init("fill")
    
    static let strokeLineWidth: Self = .init("strokeLineWidth")
    
    
    
}
