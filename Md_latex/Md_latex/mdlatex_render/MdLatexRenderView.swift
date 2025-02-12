//
//  MdLatexRenderView.swift
//  Md_latex
//
//  Created by Libing on 2025/2/12.
//

import UIKit

class MdLatexRenderView: UIView {

	private var renderString: String
	
	init(renderString: String) {
		self.renderString = renderString
		super.init(frame: .zero)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func updateRenderString(_ str: String) {
		renderString = str
	}
	
}
