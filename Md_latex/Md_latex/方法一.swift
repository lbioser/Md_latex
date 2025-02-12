//
//  MHCalculatorViewViewController.swift
//  Md_latex
//
//  Created by Libing on 2025/2/10.
//

import UIKit

import SnapKit
class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		let label = MTMathUILabel()
		label.latex = #"""
			\text{ff.  fff. ffdsfadsfasfasdfasdfasdfasdfasdfsdafsadfsd   }
			{1111fx} = \frac{-b \pm \sqrt{b^2-4ac}}{2a}{\color{#ff0000} {ffff}}
			"""#
		view.addSubview(label)
		label.backgroundColor = .gray
		label.snp.makeConstraints { make in
			make.center.equalToSuperview()
//			make.width.equalTo(100)
		}
	}

	
}
