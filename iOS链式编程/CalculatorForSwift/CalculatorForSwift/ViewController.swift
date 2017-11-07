//
//  ViewController.swift
//  CalculatorForSwift
//
//  Created by aa on 2017/11/7.
//  Copyright © 2017年 aa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let calculator:XZCalculator = XZCalculator();
//        calculator.add(10).minus(5).multiply(3).divide(5);
        
        self.xz_makeCalculation { (calculator:XZCalculator) in
            calculator.add(10).minus(5).multiply(3).divide(5);
        };
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

