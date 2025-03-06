//
//  ViewController.swift
//  customLabel
//
//  Created by libing on 5/3/25.
//

import UIKit
import SnapKit
import CoreText
class ViewController: UIViewController {
    let v = LBLabel2()
    override func viewDidLoad() {
        super.viewDidLoad()
        v.attributedText = defaultAtr
        view.addSubview(v)
        v.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(100)
//            make.height.equalTo(500)
            make.height.equalTo(500)
            
        }
        
    }

    private func test() {
        let matr = NSMutableAttributedString(string: "123456789")
        
        let attach = NSTextAttachment()
        
        matr.append(.init(attachment: attach))
        
        matr.append(.init(string: "123456789", attributes: [.font:UIFont.systemFont(ofSize: 20)]))
  
//        matr.enumerateAttributes(in: matr.range) { map, range, stop in
//            print("----")
//        }
//        matr.enumerateAttribute(.font, in: NSRange(location: 9, length: 2)) { v, range, stop in
//            print("----")
//        }
    }
    
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
////        v.setNeedsDisplay()
//    }
}

