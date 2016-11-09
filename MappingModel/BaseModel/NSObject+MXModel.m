//
//
//  NSObject+MXModel.m
//  NewModel
//
//  Created by caoye on 16/7/4.
//  Copyright © 2016年 caoye. All rights reserved.
//

#import "NSObject+MXModel.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "ListDictModel.h"
#import "MXPropertyInfo.h"

@implementation NSObject (MXModel)

#pragma mark -- NSDictionary to model
- (instancetype)MXmodelWithDictionary:(NSDictionary *)dict {
    if (!dict ) {
        return nil;
    }
    Class clss = [self class];
    
    NSObject * model = [[clss alloc] init];
    [model analyzeToPropertyWithDictionary:dict];
    
    return model;
}

- (void)analyzeToPropertyWithDictionary: (NSDictionary *) data {
    if (data == nil) {
        return;
    }
    
    Class clss = [self class];
    
    NSDictionary * contDict;
    NSDictionary * changeDic;
    
    // MARK ::包涵其他类型
    if ([clss respondsToSelector:@selector(contentClass)]) {
        contDict = [clss contentClass];
    }
    
    // MARK ::属性映射
    if ([clss respondsToSelector:@selector(changeDictKey)]) {
        changeDic = [clss changeDictKey];
    }
    
    ListDictModel * additionalModel = getCachPropertyList(clss, contDict, changeDic, data);
    setPropertyWithDict(additionalModel.propertList, data, self, additionalModel);
}

/**
 *  动态给属性付值（内联函数）
 *
 *  @param propertyList   当前类的属性列表
 *  @param newDict        如果有映射，转化后的字典
 *  @param currentClass   当前类
 *  @param additionalModel 存储包含类型和映射类型的model
 *
 *  @return nil
 */
static inline void setPropertyWithDict(NSMutableArray * propertyList, NSDictionary * newDict, id currentClass, ListDictModel * additionalModel) {
    [propertyList enumerateObjectsUsingBlock:^(MXPropertyInfo * _Nonnull propertyInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString * setStirng;
        if (propertyInfo->mapping) {
            setStirng = propertyInfo->forwardGetName;
        } else {
            setStirng = propertyInfo->getName;
        }
        if (propertyInfo->readonly || propertyInfo->dynamic) {
            return;
        }
        
        if (propertyInfo->propertyType == PropertyTypeObject) {
            setObjectPropery(propertyInfo, newDict, currentClass, setStirng, additionalModel);
        } else {
            setNumberPropertyValue(propertyInfo, newDict, currentClass, setStirng, additionalModel);
        }
    }];
}

/**
 *  给继承自NSObject的属性付值
 *
 *  @param propertyInfo    属性信息
 *  @param newDict         内容
 *  @param currentClass    持有属性的对象
 *  @param setStirng       set方法的字符串
 *  @param additionalModel 持有属性列表的model
 */
static inline void setObjectPropery(MXPropertyInfo *propertyInfo, NSDictionary * newDict, id currentClass, NSString * setStirng, ListDictModel * additionalModel) {
    // id value = newDict[setStirng];
    SEL objectForKeySel =NSSelectorFromString(@"objectForKey:");
    IMP impForKey = [newDict methodForSelector:objectForKeySel];
    id (*func)(id, SEL, NSString *) = (void *)impForKey;
    id value = func(newDict, objectForKeySel, setStirng);
    
    IMP imp = [currentClass methodForSelector:propertyInfo->setSel];
    switch (propertyInfo->objectType) {
        case NSObjectTypeNSString:{
            NSString* string = [NSString stringWithFormat:@"%@",(NSString *)value];
            void (*func)(id, SEL, NSString *) = (void *)imp;
            func(currentClass, propertyInfo->setSel, string);           
        }break;
        case NSObjectTypeNSMutableString:{
            NSMutableString* mutableString = [NSString stringWithFormat:@"%@",value].mutableCopy;
            void (*func)(id, SEL, NSMutableString *) = (void *)imp;
            func(currentClass, propertyInfo->setSel, mutableString);
        }break;
        case NSObjectTypeNSValue:{
            void (*func)(id, SEL, NSValue *) = (void *)imp;
            func(currentClass, propertyInfo->setSel, value);
        }break;
        case NSObjectTypeNSNumber:{
            NSNumber* number = (NSNumber *)value;
            void (*func)(id, SEL, NSNumber *) = (void *)imp;
            func(currentClass, propertyInfo->setSel, number);
        }break;
        case NSObjectTypeNSDecimalNumber:{
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                NSDecimalNumber* number = (NSDecimalNumber *)value;
                void (*func)(id, SEL, NSDecimalNumber *) = (void *)imp;
                func(currentClass, propertyInfo->setSel, number);
            }
        }break;
        case NSObjectTypeNSData:{
            if ([value isKindOfClass:[NSData class]]) {
                NSData* data = ((NSData *)value).copy;
                void (*func)(id, SEL, NSData *) = (void *)imp;
                func(currentClass, propertyInfo->setSel, data);
            } else if ([value isKindOfClass:[NSString class]]) {
                NSData* data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                void (*func)(id, SEL, NSData *) = (void *)imp;
                func(currentClass, propertyInfo->setSel, data);
            }
        }break;
        case NSObjectTypeNSMutableData:{
            if ([value isKindOfClass:[NSMutableData class]]) {
                NSMutableData* data = ((NSData *)value).mutableCopy;
                void (*func)(id, SEL, NSMutableData *) = (void *)imp;
                func(currentClass, propertyInfo->setSel, data);
            } else if ([value isKindOfClass:[NSString class]]) {
                NSMutableData* data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding].mutableCopy;
                void (*func)(id, SEL, NSMutableData *) = (void *)imp;
                func(currentClass, propertyInfo->setSel, data);
            }
        }break;
        case NSObjectTypeNSDate:{
            if ([value isKindOfClass:[NSDate class]]) {
                void (*func)(id, SEL, NSDate *) = (void *)imp;
                func(currentClass, propertyInfo->setSel, value);
            } else if ([value isKindOfClass:[NSString class]]) {
                void (*func)(id, SEL, NSDate *) = (void *)imp;
                func(currentClass, propertyInfo->setSel, dateFromString(value));
            } else {
                void (*func)(id, SEL, NSDate *) = (void *)imp;
                func(currentClass, propertyInfo->setSel, dateFromString([NSString stringWithFormat:@"%@",value]));
            }
        }break;
        case NSObjectTypeNSURL:{
             void (*func)(id, SEL, NSURL *) = (void *)imp;
            if ([value isKindOfClass:[NSURL class]]) {
                func(currentClass, propertyInfo->setSel, value);
            } else {
                NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",(NSString *)value]];
                func(currentClass, propertyInfo->setSel, URL);
            }
        }break;
        case NSObjectTypeNSArray:{
            NSArray * value = newDict[setStirng];
            id obja = [additionalModel.customClass->contDict objectForKey:propertyInfo->getName];
            NSMutableArray * array = [[NSMutableArray alloc] init];
            for (NSInteger i = 0; i < value.count; i++) {
                id obec = [[[obja class] alloc] init];
                [obec analyzeToPropertyWithDictionary:((NSArray *)value)[i]];
                [array addObject:obec];
            }
            NSArray * finalArray = (NSArray *)array;
            void (*func)(id, SEL, NSArray *) = (void *)imp;
            func(currentClass, propertyInfo->setSel, finalArray);
        }break;
        case NSObjectTypeNSMutableArray:{
            NSArray * value = newDict[setStirng];
            id obja = [additionalModel.customClass->contDict objectForKey:propertyInfo->getName];
            NSMutableArray * array = [[NSMutableArray alloc] init];
            for (NSInteger i = 0; i < value.count; i++) {
                id obec = [[[obja class] alloc] init];
                [obec analyzeToPropertyWithDictionary:((NSArray *)value)[i]];
                [array addObject:obec];
            }
            void (*func)(id, SEL, NSMutableArray *) = (void *)imp;
            func(currentClass, propertyInfo->setSel, array);
        }break;
        case NSObjectTypeNSDictionary:{
            NSDictionary* dictionary = (NSDictionary *)value;
            void (*func)(id, SEL, NSDictionary *) = (void *)imp;
            func(currentClass, propertyInfo->setSel, dictionary);
        }break;
        case NSObjectTypeNSMutableDictionary:{
            NSMutableDictionary* mutableDict = ((NSDictionary *)value).mutableCopy;
            void (*func)(id, SEL, NSMutableDictionary *) = (void *)imp;
            func(currentClass, propertyInfo->setSel, mutableDict);
        }break;
        case NSObjectTypeNSSet:{
            NSSet* set = (NSSet *)value;
            void (*func)(id, SEL, NSSet *) = (void *)imp;
            func(currentClass, propertyInfo->setSel, set);
        }break;
        case NSObjectTypeNSMutableSet:{
            NSMutableSet* mutableSet = ((NSSet *)value).mutableCopy;
            void (*func)(id, SEL, NSMutableSet *) = (void *)imp;
            func(currentClass, propertyInfo->setSel, mutableSet);
        }break;
        case NSObjectTypeNSObject:
        {
            id subDict = newDict[setStirng];
            id value = [[propertyInfo->clsName alloc] init];
            if ([subDict isKindOfClass:[NSDictionary class]]) {
                [value analyzeToPropertyWithDictionary:subDict];
            }
            void (*func)(id, SEL, id) = (void *)imp;
            func(currentClass, propertyInfo->setSel, value);
        }break;
        default:
        {
            id value = newDict[setStirng];
            void (*func)(id, SEL, id) = (void *)imp;
            func(currentClass, propertyInfo->setSel, value);
        }break;
    }
}

/**
 *  给基本数据类型的的属性付值
 *
 *  @param propertyInfo    属性信息
 *  @param newDict         内容
 *  @param currentClass    持有属性的对象
 *  @param setStirng       set方法的字符串
 *  @param additionalModel 持有属性列表的model
 */
static void setNumberPropertyValue(MXPropertyInfo *propertyInfo, NSDictionary * newDict, id currentClass, NSString * setStirng, ListDictModel * additionalModel) {
    // id value = newDict[setStirng];
    SEL objectForKeySel =NSSelectorFromString(@"objectForKey:");
    IMP impForKey = [newDict methodForSelector:objectForKeySel];
    id (*func)(id, SEL, NSString *) = (void *)impForKey;
    id value = func(newDict, objectForKeySel, setStirng);
    
    
    IMP imp = [currentClass methodForSelector:propertyInfo->setSel];

    switch (propertyInfo->propertyType) {
        case PropertyTypeBool: {
            NSNumber* num = (NSNumber *)value;
            void (*func)(id, SEL, BOOL) = (void *)imp;
            func(currentClass, propertyInfo->setSel, [num boolValue]);
        }break;
        case PropertyTypeInt8:{
            NSNumber* num = (NSNumber *)value;
            void (*func)(id, SEL, int8_t) = (void *)imp;
            func(currentClass, propertyInfo->setSel, (int8_t)num.charValue);
        }break;
        case PropertyTypeUInt8: {
            NSNumber* num = (NSNumber *)value;
            void (*func)(id, SEL, uint8_t) = (void *)imp;
            func(currentClass, propertyInfo->setSel, (uint8_t)num.charValue);
        }break;
        case PropertyTypeInt16: {
            NSNumber* num = (NSNumber *)value;
            void (*func)(id, SEL, int16_t) = (void *)imp;
            func(currentClass, propertyInfo->setSel, (int16_t)num.charValue);
        }break;
        case PropertyTypeUInt16: {
            NSNumber* num = (NSNumber *)value;
            void (*func)(id, SEL, uint16_t) = (void *)imp;
            func(currentClass, propertyInfo->setSel, (uint16_t)num.charValue);
        }break;
        case PropertyTypeInt32: {
            NSNumber* num = (NSNumber *)value;
            void (*func)(id, SEL, int32_t) = (void *)imp;
            func(currentClass, propertyInfo->setSel, (int32_t)num.charValue);
        }break;
        case PropertyTypeUInt32: {
            NSNumber* num = (NSNumber *)value;
            void (*func)(id, SEL, uint32_t) = (void *)imp;
            func(currentClass, propertyInfo->setSel, (uint32_t)num.charValue);
        }break;
        case PropertyTypeInt64: {
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                NSNumber* num = (NSDecimalNumber *)value;
                void (*func)(id, SEL, int64_t) = (void *)imp;
                func(currentClass, propertyInfo->setSel, (int64_t)num.stringValue.longLongValue);
            } else {
                NSNumber* num = (NSNumber *)value;
                void (*func)(id, SEL, int64_t) = (void *)imp;
                func(currentClass, propertyInfo->setSel, (int64_t)num.longLongValue);
            }
        }break;
        case PropertyTypeUInt64:{
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                NSNumber* num = (NSDecimalNumber *)value;
                void (*func)(id, SEL, uint64_t) = (void *)imp;
                func(currentClass, propertyInfo->setSel, (uint64_t)num.stringValue.longLongValue);
            } else {
                NSNumber* num = (NSNumber *)value;
                void (*func)(id, SEL, uint64_t) = (void *)imp;
                func(currentClass, propertyInfo->setSel, (uint64_t)num.longLongValue);
            }
        }break;
        case PropertyTypeFloat: {
            NSNumber* num = (NSNumber *)value;
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) f = 0;
            void (*func)(id, SEL, float) = (void *)imp;
            func(currentClass, propertyInfo->setSel, f);
        }break;
        case PropertyTypeDouble:{
            NSNumber* num = (NSNumber *)value;
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            void (*func)(id, SEL, double) = (void *)imp;
            func(currentClass, propertyInfo->setSel, d);
        }break;
        case PropertyTypeLongDouble: {
            NSNumber* num = (NSNumber *)value;
            long double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            void (*func)(id, SEL, long double) = (void *)imp;
            func(currentClass, propertyInfo->setSel, d);
        }break;
        default:break;
    }
}

/**
 *  将字符串成时间
 *
 *  @param string 传入的时间的字符串
 *
 *  @return 返回NSDate类型
 */
static inline NSDate* dateFromString(__unsafe_unretained NSString *string) {
    NSTimeInterval timeInterval = [string floatValue];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return date;
}

#pragma mark -- model to NSDictionary
- (NSDictionary *)modelToDict {
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    ListDictModel * listDicModel = getCachPropertyList([self class], nil, nil, nil);
    
    [listDicModel.propertList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MXPropertyInfo * propertyInfo = (MXPropertyInfo *)obj;
        if (!propertyInfo->dynamic) {
           
            if (propertyInfo->propertyType == PropertyTypeObject) {
                SEL getSel = propertyInfo->getSel;
                IMP imp = [self methodForSelector:getSel];
                id (*func)(id, SEL) = (void *)imp;
                id resultValue = func(self, getSel);
                id finalResult = getDictWithObject(propertyInfo, resultValue);
                if (finalResult) {
                    [dict setObject:finalResult forKey:propertyInfo->getName];
                }

            } else {
                getNSObjectProperty(propertyInfo, self,dict );
            }
        }
    }];
    
    return dict;
}

/**
 *  NSNumber类型的model转换成json
 *
 *  @param propertyInfo 属性信息
 *  @param currentClass 调用者
 *  @param dict         目标字典
 *
 *  @return
 */
static inline void getNSObjectProperty(MXPropertyInfo * propertyInfo, id currentClass, NSMutableDictionary *dict) {
    SEL getSel = propertyInfo->getSel;
    IMP imp = [currentClass methodForSelector:getSel];

    switch (propertyInfo->propertyType) {
        case PropertyTypeBool: {
            BOOL (*func)(id, SEL) = (void *)imp;
            BOOL resultValue = func(currentClass, getSel);
            [dict setObject:[NSNumber numberWithBool:resultValue] forKey:propertyInfo->getName];
        }break;
        case PropertyTypeInt8:{
            int8_t (*func)(id, SEL) = (void *)imp;
            int8_t resultValue = func(currentClass, getSel);
            [dict setObject:[NSNumber numberWithInt:resultValue] forKey:propertyInfo->getName];
        }break;
        case PropertyTypeUInt8: {
            uint8_t (*func)(id, SEL) = (void *)imp;
            uint8_t resultValue = func(currentClass, getSel);
            [dict setObject:[NSNumber numberWithInt:resultValue] forKey:propertyInfo->getName];
        }break;
        case PropertyTypeInt16: {
            int16_t (*func)(id, SEL) = (void *)imp;
            int16_t resultValue = func(currentClass, getSel);
            [dict setObject:[NSNumber numberWithInt:resultValue] forKey:propertyInfo->getName];
        }break;
        case PropertyTypeUInt16: {
            uint16_t (*func)(id, SEL) = (void *)imp;
            uint16_t resultValue = func(currentClass, getSel);
            [dict setObject:[NSNumber numberWithInt:resultValue] forKey:propertyInfo->getName];
        }break;
        case PropertyTypeInt32: {
            int32_t (*func)(id, SEL) = (void *)imp;
            int32_t resultValue = func(currentClass, getSel);
            [dict setObject:[NSNumber numberWithInteger:resultValue] forKey:propertyInfo->getName];
        }break;
        case PropertyTypeUInt32: {
            uint32_t (*func)(id, SEL) = (void *)imp;
            uint32_t resultValue = func(currentClass, getSel);
            [dict setObject:[NSNumber numberWithInteger:resultValue] forKey:propertyInfo->getName];
        }break;
        case PropertyTypeInt64: {
            uint64_t (*func)(id, SEL) = (void *)imp;
            uint64_t resultValue = func(currentClass, getSel);
            [dict setObject:[NSNumber numberWithInteger:resultValue] forKey:propertyInfo->getName];
        }break;
        case PropertyTypeUInt64:{
            uint64_t (*func)(id, SEL) = (void *)imp;
            uint64_t resultValue = func(currentClass, getSel);
            [dict setObject:[NSNumber numberWithUnsignedInteger:resultValue] forKey:propertyInfo->getName];
        }break;
        case PropertyTypeFloat: {
            float (*func)(id, SEL) = (void *)imp;
            float resultValue = func(currentClass, getSel);
            [dict setObject:[NSNumber numberWithFloat:resultValue] forKey:propertyInfo->getName];
        }break;
        case PropertyTypeDouble:{
            double (*func)(id, SEL) = (void *)imp;
            double resultValue = func(currentClass, getSel);
            [dict setObject:[NSNumber numberWithDouble:resultValue] forKey:propertyInfo->getName];
        }break;
        case PropertyTypeLongDouble: {
            long double (*func)(id, SEL) = (void *)imp;
            long double resultValue = func(currentClass, getSel);
            [dict setObject:[NSNumber numberWithLongLong:resultValue] forKey:propertyInfo->getName];        }break;
        default:break;
    }

}

/**
 *  将property属性对应的值放入字典中 （内联函数）
 *
 *  @param propertyInfo 每个property的内容
 *  @param resultValue  每个属性对应的内容
 *
 *  @return 最终转化后的结果
 */
static inline id getDictWithObject(MXPropertyInfo * propertyInfo, id resultValue) {
    id finalResult;
    switch (propertyInfo->objectType) {
        case NSObjectTypeNSObject: {
            NSDictionary * subDict = [resultValue modelToDict];
            finalResult = subDict;
        }
            break;
        case NSObjectTypeNSArray: {
            NSMutableArray * subArray = [[NSMutableArray alloc] init];
            for (NSObject * subObj in resultValue) {
                NSDictionary * dic = [subObj modelToDict];
                [subArray addObject:dic];
            }
            finalResult = subArray;
        }
            break;
        case NSObjectTypeNSString:
            finalResult = resultValue;
            break;
            
        default:
            finalResult = resultValue;
            break;
    }
    return finalResult;
}

#pragma mark -- model cach
/**
 *   对类的proty、类的映射关系、包涵的特殊类型进行缓存（内联函数）
 *
 *  @param cls        cls 当前的类
 *  @param contentDic 包涵特殊类型的字典
 *  @param changeDic  需要映射的字典
 *  @param intentDict 要解析的目标字典
 *
 *  @return 返回缓存的model
 */
static inline ListDictModel * getCachPropertyList(Class cls, NSDictionary *contentDic, NSDictionary *changeDic, NSDictionary *intentDict) {
    if (!cls) return nil;
    static CFMutableDictionaryRef propertyListDict;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        propertyListDict = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    NSString * keyString = NSStringFromClass(cls);
    
    ListDictModel * cachModel = CFDictionaryGetValue(propertyListDict, (__bridge const void *)(keyString));
    
    dispatch_semaphore_signal(lock);
    if (!cachModel) {
        cachModel = [[ListDictModel alloc] init];
        cachModel.propertList = PropertyListGetFromClass(cls, changeDic);
        cachModel.customClass->contDict = contentDic;
        cachModel.customClass->changeDic = changeDic;
        
        if (cachModel) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(propertyListDict, (__bridge const void *)(keyString), (__bridge const void *)(cachModel));
            dispatch_semaphore_signal(lock);
        }
    }
    
    return cachModel;
}

/**
 *  获取类的所有属性对象（内联函数）
 *
 *  @param objeClass 想要获取property的list的类名
 *
 *  @return 该类的属性类型数组
 */
static inline NSMutableArray * PropertyListGetFromClass(__unsafe_unretained id objeClass, __unsafe_unretained NSDictionary *changeDict) {
    uint propertyCount;
    objc_property_t *ps = class_copyPropertyList([objeClass class], &propertyCount);
    NSMutableArray* results = [NSMutableArray arrayWithCapacity:propertyCount];
    
    for (uint i = 0; i < propertyCount; i++) {
        objc_property_t property = ps[i];
        const char *propertyName = property_getName(property);
        const char *propertyAttributes = property_getAttributes(property);
        
        //    https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        //    https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
        //通常:T@"NSString",C,N,V_name   dynamic:T@"NSString",C,D,N  readonly:T@"NSString",R,C,N,V_name
        NSString* type = [NSString stringWithUTF8String:propertyAttributes];
        if ([type rangeOfString:@"@"].location !=NSNotFound) {
            type = [type componentsSeparatedByString:@"\""][1];
        }
        
        NSString* name = [NSString stringWithUTF8String:propertyName];
        MXPropertyInfo * propertyInfo = [MXPropertyInfo setPropertyInfoWithPropertyName:name type:type changeDict:changeDict property:(objc_property_t)property];
        [results addObject:propertyInfo];
    }
    if (ps) {
        free(ps);
    }
    return results;
}

@end

