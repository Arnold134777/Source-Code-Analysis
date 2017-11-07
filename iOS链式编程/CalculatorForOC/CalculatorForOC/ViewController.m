//
//  ViewController.m
//  CalculatorForOC
//
//  Created by aa on 2017/11/7.
//  Copyright © 2017年 aa. All rights reserved.
//

#import "ViewController.h"
#import "XZCalculator.h"
#import "NSObject+XZCalculator.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    XZCalculator *calculator = [[XZCalculator alloc] init];
//    calculator.add(10).minus(5).multiply(3).divide(5);
    
    [self xz_makeCalculation:^(XZCalculator *calculator) {
        calculator.add(10).minus(5).multiply(3).divide(5);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
