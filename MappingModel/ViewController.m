//
//  ViewController.m
//  MappingModel
//
//  Created by caoye on 16/7/25.
//  Copyright © 2016年 caoye. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+MXModel.h"
#import "PersonModel.h"
#import "ChildModel.h"
#import "SubModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSDictionary * childDictss = @{@"childName":@"tttttt", @"childAge":@"yyyyy",@"childSex":@"uuuuu"};
    NSDictionary * childDict = @{@"childName":@"aaaa", @"childAge":@"bbbb",@"childSex":@"ccccc"};
    NSDictionary * ssss = @{@"childName":@"aaaa", @"childAge":@"bbbb",@"childSex":@"ccccc",@"child":childDict};
    NSDictionary * childDictAr = @{@"childName":@"1111111111", @"childAge":@"2222222",@"childSex":@"3333333"};
    NSDictionary * childDictAaaa = @{@"childName":@"sssss", @"childAge":@"dddddd",@"childSex":@"fffff"};
    NSDictionary * suDict = @{@"mobile":@"13381282065", @"email":@"1595576349@qq.com",@"deptName":@"gongsizhiyuan"};
    
    NSArray * array = @[childDictAr,childDictAaaa];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"caoye" forKey:@"name"];
    [dict setObject:@"10" forKey:@"age"];
    [dict setObject:@"man" forKey:@"sex"];
    [dict setObject:@"red" forKey:@"color"];
    [dict setObject:ssss forKey:@"child"];
    [dict setObject:childDictss forKey:@"childOne"];
    [dict setObject:@"heh" forKey:@"caoye"];
    [dict setObject:[NSNumber numberWithFloat:1234] forKey:@"myNumber"];
    [dict setObject:array forKey:@"theArray"];
    [dict setObject:@[suDict] forKey:@"theArr"];
    [dict setObject:[NSURL URLWithString:@"http://www.baidu.com"] forKey:@"url"];
    [dict setObject:@111 forKey:@"ssssss"];

    PersonModel * model = [PersonModel MXmodelWithDictionary:dict];
    NSLog(@"---------%@",model.name);
    NSLog(@"---------%@",model.namesssss);
    NSLog(@"---------%@",model.url.host);
    NSLog(@"---------%@",model.myNumber);
    NSLog(@"---------%@",model.child.childName);
    NSLog(@"---------**%@",model.child.child.childAge);
    NSLog(@"---------%@",model.childOne.childAge);
    NSLog(@"--------%@",((ChildModel *)model.theArray[1]).childAge);
    NSLog(@"--------%@",((SubModel *)model.theArr[0]).mobile);
    NSLog(@"--------%ld",(long)model.ssssss);
    NSLog(@"-----%@",[model modelToDict]);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
