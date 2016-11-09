//
//  MXPropertyInfo.m
//  NewModel
//
//  Created by caoye on 16/7/21.
//  Copyright © 2016年 caoye. All rights reserved.
//

#import "MXPropertyInfo.h"

@implementation MXPropertyInfo

/**
 *  设置property的属性
 *
 *  @param propertyName 名称
 *  @param propertyType 类型
 *
 *  @return 存储property属性的对象
 */
+ (nullable instancetype)setPropertyInfoWithPropertyName:(nullable NSString *)propertyName type:(nullable NSString *)propertyType changeDict:(nullable NSDictionary *)changeDict property:(nullable objc_property_t)property {
    
    MXPropertyInfo * propertyInfo = [[MXPropertyInfo alloc] init];
    propertyInfo->readonly = NO;
    propertyInfo->dynamic = NO;
    propertyInfo->setName = getSetterStringFromPropertyName(propertyName);
    propertyInfo->getName = propertyName;
    propertyInfo->setSel = getSetterSelFromPropertyName(propertyName);
    propertyInfo->getSel = NSSelectorFromString(propertyName);
    propertyInfo->clsName = NSClassFromString(propertyType);
    
    [changeDict.allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:propertyName]) {
            propertyInfo->forwardGetName = changeDict.allKeys[idx];
            propertyInfo->mapping = YES;
        }
    }];
    
    uint propertyCount;
    objc_property_attribute_t* attributes = property_copyAttributeList(property, &propertyCount);
    for (uint i = 0; i < propertyCount; i++) {
        if (attributes[i].name[0] == 'T') {
            if (attributes[i].value) {
                propertyInfo->propertyType = getPropertyInfoType(attributes[i].value);
                if (propertyInfo->propertyType == PropertyTypeObject) {
                    getPropertyObjectType(propertyInfo, NSClassFromString(propertyType));
                }
            }
        } else if (attributes[i].name[0] == 'R') {
            propertyInfo->readonly = YES;
        } else if (attributes[i].name[0] == 'D') {
            propertyInfo->dynamic = YES;
        }
    }
    if (attributes) {
        free(attributes);
        attributes = nil;
    }
    return propertyInfo;
}

static inline void getPropertyObjectType(MXPropertyInfo *propertyInfo, Class cls) {
    if ([cls isSubclassOfClass:[NSString class]]) {
        propertyInfo->objectType = NSObjectTypeNSString;
    } else if ([cls isSubclassOfClass:[NSMutableString class]]) {
        propertyInfo->objectType = NSObjectTypeNSMutableString;
    } else if ([cls isSubclassOfClass:[NSDictionary class]]) {
        propertyInfo->objectType = NSObjectTypeNSDictionary;
    } else if ([cls isSubclassOfClass:[NSMutableDictionary class]]) {
        propertyInfo->objectType = NSObjectTypeNSMutableDictionary;
    } else if ([cls isSubclassOfClass:[NSArray class]]) {
        propertyInfo->objectType = NSObjectTypeNSArray;
    } else if ([cls isSubclassOfClass:[NSMutableArray class]]) {
        propertyInfo->objectType = NSObjectTypeNSMutableArray;
    } else if ([cls isSubclassOfClass:[NSSet class]]) {
        propertyInfo->objectType = NSObjectTypeNSSet;
    } else if ([cls isSubclassOfClass:[NSMutableSet  class]]) {
        propertyInfo->objectType = NSObjectTypeNSMutableSet ;
    } else if ([cls isSubclassOfClass:[NSData class]]) {
        propertyInfo->objectType = NSObjectTypeNSData;
    } else if ([cls isSubclassOfClass:[NSMutableData class]]) {
        propertyInfo->objectType = NSObjectTypeNSMutableData;
    } else if ([cls isSubclassOfClass:[NSDate class]]) {
        propertyInfo->objectType = NSObjectTypeNSDate;
    } else if ([cls isSubclassOfClass:[NSNumber class]]) {
        propertyInfo->objectType = NSObjectTypeNSNumber;
    } else if ([cls isSubclassOfClass:[NSURL class]]) {
        propertyInfo->objectType = NSObjectTypeNSURL;
    } else if ([cls isSubclassOfClass:[NSValue class]]) {
        propertyInfo->objectType = NSObjectTypeNSValue;
    } else if ([cls isSubclassOfClass:[NSDecimalNumber class]]) {
        propertyInfo->objectType = NSObjectTypeNSDecimalNumber;
    } else {
        propertyInfo->objectType = NSObjectTypeNSObject;
    }
}

static inline PropertyType getPropertyInfoType(const char* value) {
    size_t len = strlen(value);
    if (len == 0) return PropertyTypeUnkonw;
    switch (* value) {
        case 'v': {return PropertyTypeVoid;}
        case 'B': {return PropertyTypeBool;}
        case 'c': {return PropertyTypeInt8;}
        case 'C': {return PropertyTypeUInt8;}
        case 's': {return PropertyTypeInt16;}
        case 'S': {return PropertyTypeUInt16;}
        case 'i': {return PropertyTypeInt32;}
        case 'I': {return PropertyTypeUInt32;}
        case 'l': {return PropertyTypeInt32;}
        case 'L': {return PropertyTypeUInt32;}
        case 'q': {return PropertyTypeInt64;}
        case 'Q': {return PropertyTypeUInt64;}
        case 'f': {return PropertyTypeFloat;}
        case 'd': {return PropertyTypeDouble;}
        case 'D': {return PropertyTypeLongDouble;}
        case '#': {return PropertyTypeClass;}
        case ':': {return PropertyTypeSEL;}
        case '*': {return PropertyTypeCFString;}
        case '^': {return PropertyTypePointer;}
        case '[': {return PropertyTypeCFArray;}
        case '(': {return PropertyTypeUnion;}
        case '{': {return PropertyTypeStruct;}
        case '@': {
            if (len == 2 && *(value + 1) == '?'){
                return PropertyTypeBlock;
            } else {
                return PropertyTypeObject;
            }
        }
        default:{return PropertyTypeUnkonw;}
    }
}


/**
 *  根据属性名称获取set方法
 *
 *  @param propertyName 属性名称（NSString类型）
 *
 *  @return 返回对应的SEL对象
 */
static inline SEL getSetterSelFromPropertyName(__unsafe_unretained NSString * propertyName) {
    NSString * newPropertyName = propertyName;
    newPropertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[propertyName substringToIndex:1] uppercaseString]];
    newPropertyName = [NSString stringWithFormat:@"set%@:", newPropertyName];
    return NSSelectorFromString(newPropertyName);
}

/**
 *  根据属性名称获取set方法的字符串名称
 *
 *  @param propertyName 属性名称（NSString类型）
 *
 *  @return 返回对应的set方法的字符串
 */
static inline NSString * getSetterStringFromPropertyName(__unsafe_unretained NSString * propertyName) {
    NSString * newPropertyName = propertyName;
    newPropertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[propertyName substringToIndex:1] uppercaseString]];
    newPropertyName = [NSString stringWithFormat:@"set%@:", newPropertyName];
    return newPropertyName;
}

@end
