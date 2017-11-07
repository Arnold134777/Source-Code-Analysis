//
//  XZCalculator.h
//  CalculatorForOC
//
//  Created by aa on 2017/11/7.
//  Copyright © 2017年 aa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZCalculator : NSObject

@property (assign, nonatomic) NSInteger result;

- (XZCalculator *(^)(NSInteger num))add;

- (XZCalculator *(^)(NSInteger num))minus;

- (XZCalculator *(^)(NSInteger num))multiply;

- (XZCalculator *(^)(NSInteger num))divide;

@end
