//
//  ViewController.swift
//  Md_latex
//
//  Created by Libing on 2025/2/10.
//

import UIKit
import Down

class ViewController2: UIViewController {

	
	override func viewDidLoad() {
			super.viewDidLoad()

			let markdownString = #"""
			# Hello, World!
			Welcome to **SwiftUI** and *UIKit* Markdown rendering.
			$$\int_{1}^{2} \cfrac{1}{a + \cfrac{7}{b + \cfrac{2}{9}}} =c$$
			| Header 1 | Header 2 | Header 3 |
			| --------- | --------- | --------- |
			| Row 1    | Row 1    | Row 1    |
			| Row 2    | Row 2    | Row 2    |
			"""#
			
		let str = try! Down(markdownString: markdownString).toHTML()
//		let latex =  try! Down(markdownString: markdownString).toLaTeX()
		let v = UITextView(frame: view.bounds)
		view.addSubview(v)
		do {
			
			let attributedString = try NSAttributedString(data: str.data(using: .utf8)!,
																	   options: [.documentType: NSAttributedString.DocumentType.html,
																				 .characterEncoding: String.Encoding.utf8.rawValue],
																	   documentAttributes: nil)
						v.attributedText = attributedString
					} catch {
						print("Error: \(error.localizedDescription)")
					}
		
		}



}

