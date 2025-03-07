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
    let label = LBLabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v = UIView()
        v.backgroundColor = .white
        view.addSubview(v)
        v.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(100)
        }
        
        label.backgroundColor = .lightGray
        label.numberOfLines = 5
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .green
        label.attributedText = defaultAtr
        label.isUserInteractionEnabled = true
        v.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
            make.height.equalTo(1)// 设置高度为了约束完整，以便更新
        }
        label.updateHeightHandler = {[weak self] height in
            self?.label.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
        }
    }

   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        
    }
}

