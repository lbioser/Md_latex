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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = ViewController1()
        present(vc, animated: true)
    }
    
}

class ViewController1: UIViewController {
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
        label.numberOfLines = 6
        
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .green
        label.attributedText = defaultAtr
        label.isUserInteractionEnabled = true
        label.layer.masksToBounds = true
        
        label.clickHandler = {[weak self] type in
            guard let self else { return }
            switch type {
            case .click(let str):
                showAlert(message: str)
            case .placeholder(let info):
                showAlert(message: "info.data")
            case .truncate:
                showAlert(message: "more more...")
          
            }
        }
        
        v.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
            make.height.equalTo(0.5)// 设置高度为了约束完整，以便更新
        }
        label.updateHeightHandler = {[weak self] height in
            self?.label.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
        }
    }

   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        
    }
    
    func showAlert(message: String) {
        let alertvc = UIAlertController(title: "xxx", message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "cancel", style: .cancel)
        alertvc.addAction(cancel)
        present(alertvc, animated: true)
    }
    
    
    deinit {
        print(self,#function)
    }
    
}

