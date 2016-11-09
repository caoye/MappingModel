//
//  PersonModel.h
//  NewModel
//
//  Created by caoye on 16/7/4.
//  Copyright © 2016年 caoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChildModel.h"
#import "SubModel.h"

@interface PersonModel : NSObject


@property (nonatomic, copy) NSString * name;

@property (nonatomic, copy) NSString * names;

@property (nonatomic, copy) NSString * namesssss;

@property (nonatomic, copy) NSString * age;

@property (nonatomic, copy) NSString * sex;

@property (nonatomic, copy) NSString * color;

@property (nonatomic, copy) NSString * caoye;

@property (nonatomic, copy) NSString * other;

@property (nonatomic, strong) NSArray * theArray;

@property (nonatomic, strong) NSArray * theArr;

@property (nonatomic, strong) ChildModel * child;

@property (nonatomic, strong) ChildModel * childOne;

@property (nonatomic, strong) NSURL * url;

@property (nonatomic, assign) NSNumber * myNumber;

@property (nonatomic, assign) BOOL rest;

@property (nonatomic) NSInteger ssssss;

@end
