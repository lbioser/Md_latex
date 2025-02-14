//
//  MHCalculatorViewViewController.swift
//  Md_latex
//
//  Created by Libing on 2025/2/10.
//

import UIKit
import Combine
import SnapKit
class ViewController: UIViewController {
	let label = MTMathUILabel()
	var cancelSet: [AnyCancellable] = []
	let latex = #"""
			\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm\pm
			 {\pm\pm\pm}\pm\pm\pm{\color{#ff0000} {rfffffdf}}\frac{1}{\left(\sqrt{\phi \sqrt{5}}-\phi\right) e^{\frac25 \pi}}
			 = 1+\frac{e^{-2\pi}} {1 +\frac{e^{-4\pi}} {1+\frac{e^{-6\pi}} {1+\frac{e^{-8\pi}} {1+\cdots} } } }
				   
			"""#
	lazy var panPublisher = UIPanGestureRecognizer(target: self, action: #selector(pan))
	override func viewDidLoad() {
		super.viewDidLoad()
		view.addGestureRecognizer(panPublisher)

		view.addSubview(label)
		label.frame = view.bounds
		label.backgroundColor = .gray
		timePublisher.sink {[weak self] t in
			guard let self else { return }
		 self.index += 1
		 guard index < latex.count else { return }
		 let str = latex[latex.startIndex..<latex.index(latex.startIndex, offsetBy: index)]
			label.latex = String(str)
		}.store(in: &cancelSet)
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		timePublisher.connect()
	}
	var lastP: CGPoint = .zero
	@objc func pan(_ ges: UIPanGestureRecognizer) {
		switch ges.state {
		case .changed:
			let p = ges.translation(in: self.view)
			let dp = CGPoint(x: p.x-lastP.x, y: p.y-lastP.y)
			lastP = p
			label.frame = CGRect(origin: CGPoint(x: label.frame.origin.x-dp.x/2, y: label.frame.origin.y-dp.y/2), size: CGSize(width: label.frame.size.width+dp.x, height: label.frame.size.height+dp.y))
		default:
			lastP = .zero
		}
	}
	
	var index = 0
	lazy var timePublisher = Timer.publish(every: 0.05, on: .current, in: .common)

}
