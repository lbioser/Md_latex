//
//  MHCalculatorViewViewController.swift
//  Md_latex
//
//  Created by Libing on 2025/2/10.
//

import UIKit

import SnapKit
class ViewController: UIViewController {
	let label = MTMathUILabel()
	override func viewDidLoad() {
		super.viewDidLoad()
		
		label.latex = #"""
			=\frac{n \left( \frac{\sqrt{a^2+b^2} }{f} +a_{n}\right)}{2} 
			"""#
		view.addSubview(label)
		label.backgroundColor = .gray
		label.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.width.equalTo(150)
//			make.height.equalTo(500)
		}
	}
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		label.latex = #"""
			x_{b^2}=\frac{n \left( \frac{\sqrt{a^2+b^2} }{f} +a_{n}\right)}{2*\frac{\sqrt{a^2+b^2} }{\frac{\sqrt{a^2+b^2} }{f}}} 
			"""#
	}
	
}
