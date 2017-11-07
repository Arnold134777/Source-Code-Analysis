//
//  Any+XZCalculator.swift
//  CalculatorForSwift
//
//  Created by aa on 2017/11/7.
//  Copyright © 2017年 aa. All rights reserved.
//

import Foundation

extension NSObject {
    func xz_makeCalculation(_ block:(_ calculator:XZCalculator) -> ()){
        let calculator:XZCalculator = XZCalculator();
        block(calculator);
    }
}
