//
//  XZCalculator.swift
//  CalculatorForSwift
//
//  Created by aa on 2017/11/7.
//  Copyright © 2017年 aa. All rights reserved.
//

import UIKit

class XZCalculator: NSObject {
    
    var result:Int = 0;

    func add(_ num:Int) -> XZCalculator {
        self.result += num;
        print("result \(self.result)");
        return self;
    }
    
    func minus(_ num:Int) -> XZCalculator {
        self.result -= num;
        print("result \(self.result)");
        return self;
    }
    
    func multiply(_ num:Int) -> XZCalculator {
        self.result *= num;
        print("result \(self.result)");
        return self;
    }
    
    func divide(_ num:Int) -> XZCalculator {
        self.result /= num;
        print("result \(self.result)");
        return self;
    }
}
