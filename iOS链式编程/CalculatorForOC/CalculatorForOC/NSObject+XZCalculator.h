//
//  NSObject+XZCalculator.h
//  CalculatorForOC
//
//  Created by aa on 2017/11/7.
//  Copyright © 2017年 aa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZCalculator.h"

@interface NSObject (XZCalculator)

- (void)xz_makeCalculation:(void(^)(XZCalculator *calculator))block;

@end
