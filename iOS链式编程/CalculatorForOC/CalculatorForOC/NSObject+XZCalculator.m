//
//  NSObject+XZCalculator.m
//  CalculatorForOC
//
//  Created by aa on 2017/11/7.
//  Copyright © 2017年 aa. All rights reserved.
//

#import "NSObject+XZCalculator.h"

@implementation NSObject (XZCalculator)

- (void)xz_makeCalculation:(void(^)(XZCalculator *calculator))block{
    XZCalculator *calculator = [[XZCalculator alloc] init];
    block(calculator);
}
@end
