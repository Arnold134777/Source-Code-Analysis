//
//  ViewController.m
//  KVOExample
//
//  Created by aa on 2017/10/12.
//  Copyright © 2017年 aa. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "FBKVOController.h"

@interface ViewController (){
    Person *person;
    FBKVOController *KVOController;
}

@end

@implementation ViewController

- (void)dealloc {
    [person removeObserver:self forKeyPath:@"name"];
    [person removeObserver:self forKeyPath:@"age"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupViews];
    
    [self setupPerson];
    
    // 1.系统原生的KVO使用方式
    //[self setupObservers];
    
    // 2.FB对KVO的封装
    [self setupFBKVO];
}

- (void)setupViews{
    UIButton *changeNameButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    [changeNameButton setTitle:@"change name" forState:UIControlStateNormal];
    changeNameButton.backgroundColor = [UIColor redColor];
    changeNameButton.center = CGPointMake(self.view.center.x, 100);
    [changeNameButton addTarget:self action:@selector(changeName:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeNameButton];
    
    UIButton *changeAgeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    [changeAgeButton setTitle:@"change age" forState:UIControlStateNormal];
    changeAgeButton.backgroundColor = [UIColor redColor];
    changeAgeButton.center = CGPointMake(self.view.center.x, 200);;
    [changeAgeButton addTarget:self action:@selector(changeAge:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeAgeButton];
}

- (void)setupPerson{
    person = [Person new];
    person.name = @"xz";
    person.age = 20;
    person.location = @"深圳";
    NSLog(@"before %s",object_getClassName(person));
}

- (void)setupObservers{
    [person addObserver:self
             forKeyPath:@"name"
                    options:NSKeyValueObservingOptionNew
                context:nil];
    
    [person addObserver:self
             forKeyPath:@"age"
                options:NSKeyValueObservingOptionNew
                context:nil];
}

- (void)setupFBKVO {
    KVOController = [FBKVOController controllerWithObserver:self];
    [KVOController observe:person
                   keyPath:@"name"
                   options:NSKeyValueObservingOptionNew
                     block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
                         NSLog(@"%@",change);
                     }];
    
    [KVOController observe:person
                   keyPath:@"age"
                   options:NSKeyValueObservingOptionNew
                     block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
                         NSLog(@"%@",change);
                     }];
}

- (void)changeName:(id)sender{
    person.name = @"xsc";
    NSLog(@"after %s",object_getClassName(person));
}

- (void)changeAge:(id)sender{
    person.age = 22;
    NSLog(@"after %s",object_getClassName(person));
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"%@",change);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
