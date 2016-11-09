//
//  MXPropertyInfo.h
//  NewModel
//
//  Created by caoye on 16/7/21.
//  Copyright © 2016年 caoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef NS_OPTIONS(NSUInteger, NSObjectType) {
    NSObjectTypeNSString            = 0,
    NSObjectTypeNSMutableString     = 1,
    NSObjectTypeNSDictionary        = 2,
    NSObjectTypeNSMutableDictionary = 3,
    NSObjectTypeNSArray             = 4,
    NSObjectTypeNSMutableArray      = 5,
    NSObjectTypeNSSet                = 6,
    NSObjectTypeNSMutableSet        = 7,
    NSObjectTypeNSData              = 8,
    NSObjectTypeNSMutableData       = 9,
    NSObjectTypeNSDate              = 10,
    NSObjectTypeNSNumber            = 11,
    NSObjectTypeNSDecimalNumber     = 12,
    NSObjectTypeNSURL               = 13,
    NSObjectTypeNSValue             = 14,
    NSObjectTypeNSObject            = 15,
};

typedef NS_ENUM(NSUInteger, PropertyType) {
    PropertyTypeUnkonw        = 0,
    PropertyTypeVoid          = 1,
    PropertyTypeBool          = 2,
    PropertyTypeInt8          = 3,
    PropertyTypeUInt8         = 4,
    PropertyTypeInt16         = 5,
    PropertyTypeUInt16        = 6,
    PropertyTypeInt32         = 7,
    PropertyTypeUInt32        = 8,
    PropertyTypeInt64         = 9,
    PropertyTypeUInt64        = 10,
    PropertyTypeFloat         = 11,
    PropertyTypeDouble        = 12,
    PropertyTypeLongDouble    = 13,
    PropertyTypeClass         = 14,
    PropertyTypeSEL           = 15,
    PropertyTypeCFString      = 16,
    PropertyTypePointer       = 17,
    PropertyTypeCFArray       = 18,
    PropertyTypeUnion         = 19,
    PropertyTypeStruct        = 20,
    PropertyTypeObject        = 21,
    PropertyTypeBlock         = 22
};

@interface MXPropertyInfo : NSObject

{
    @package
    
    NSString * setName;
    NSString * getName;         //property的getName
    NSString * forwardGetName;  //映射前字段
    BOOL mapping;               //是否是映射字段
    BOOL readonly;
    BOOL dynamic;
    
    SEL setSel;
    SEL getSel;
    NSObjectType objectType;
    PropertyType propertyType;
    Class clsName;
}

+ (nullable instancetype)setPropertyInfoWithPropertyName:(nullable NSString *)propertyName type:(nullable NSString *)propertyType changeDict:(nullable NSDictionary *)contentDict property:(nullable objc_property_t)property;

@end
