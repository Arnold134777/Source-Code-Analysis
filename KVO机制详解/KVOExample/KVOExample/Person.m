//
//  Person.m
//  KVOExample
//
//  Created by aa on 2017/10/12.
//  Copyright © 2017年 aa. All rights reserved.
//

#import "Person.h"

@implementation Person

- (void)setName:(NSString *)name{
    [self willChangeValueForKey:@"name"];
    _name = name;
    [self didChangeValueForKey:@"name"];
}

/**
 是否自动控制监听属性的变化
 
 @param key 键值
 @return YES/NO
 */
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key{
    if([key isEqualToString:@"name"]){
        return NO;
    }
    return YES;
}

@end
