//
//  XZCalculator.m
//  CalculatorForOC
//
//  Created by aa on 2017/11/7.
//  Copyright © 2017年 aa. All rights reserved.
//

#import "XZCalculator.h"

@implementation XZCalculator

- (XZCalculator *(^)(NSInteger num))add{
    return ^(NSInteger num){
        _result += num;
        NSLog(@"result %d",_result);
        return self;
    };
}

- (XZCalculator *(^)(NSInteger num))minus{
    return ^(NSInteger num){
        _result -= num;
        NSLog(@"result %d",_result);
        return self;
    };
}


- (XZCalculator *(^)(NSInteger num))multiply{
    return ^(NSInteger num){
        _result *= num;
        NSLog(@"result %d",_result);
        return self;
    };
}


- (XZCalculator *(^)(NSInteger num))divide{
    return ^(NSInteger num){
        _result /= num;
        NSLog(@"result %d",_result);
        return self;
    };
}

@end
