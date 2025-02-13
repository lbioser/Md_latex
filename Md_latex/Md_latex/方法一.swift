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
			{\color{#ff0000} {ffffdsfdsfdsfdsfasdfdsfasdfdsafadsfdsfdsfdsfadsfasdff}}
			\text{ff.sdafsadfsd}
			1fx = \frac{-b \pm \sqrt{b^2-4ac}}{2a}
			"""#
		view.addSubview(label)
		label.backgroundColor = .gray
		label.snp.makeConstraints { make in
			make.center.equalToSuperview()
//			make.width.equalTo(100)
			make.height.equalTo(500)
		}
	}
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		label.latex = #"""
			{\color{#ff0000} {ffff}}
			\text{ff.sdafsadfsd}
			1fx = \frac{-b \pm \sqrt{b^2-4ac}}{2a}
			"""#
	}
	
}
