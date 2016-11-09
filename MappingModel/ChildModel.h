//
//  ChildModel.h
//  model
//
//  Created by 曹飞 on 16/7/2.
//  Copyright © 2016年 曹飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChildModel : NSObject

@property (nonatomic, copy) NSString * childName;

@property (nonatomic, copy) NSString * childAge;

@property (nonatomic, copy) NSString * childSex;

@property (nonatomic, strong) ChildModel * child;

@end
