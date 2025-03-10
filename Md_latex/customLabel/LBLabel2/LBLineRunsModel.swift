//
//  LBLineRunsModel.swift
//  customLabel
//
//  Created by libing on 10/3/25.
//

import Foundation
import CoreText

class LBLineRunsModel {
    var line: CTLine
    var runs: [LBRunModel]
    init(line: CTLine, runs: [LBRunModel]) {
        self.line = line
        self.runs = runs
    }
}


class LBRunModel {
    var run: CTRun
    var rect: CGRect
    init(run: CTRun, rect: CGRect) {
        self.run = run
        self.rect = rect
    }
}
