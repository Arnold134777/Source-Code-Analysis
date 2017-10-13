//
//  Person.h
//  KVOExample
//
//  Created by aa on 2017/10/12.
//  Copyright © 2017年 aa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, copy) NSString *location;

@end
