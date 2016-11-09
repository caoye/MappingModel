# MappingModel


#### Example

将NSDictionary转model：

```
PersonModel * model = [PersonModel MXmodelWithDictionary:dict];
```
将model转NSDictionary：

```
NSDictionary * dict ＝ [model modelToDict];
```

转化NSDictionary转的数组类型：

```
+ (NSDictionary *)contentClass {
    return @{@"theArray":[ChildModel class],@"theArr":[SubModel class]};
}
```


特殊字段的映射：

```
+ (NSDictionary *)changeDictKey {
    return @{@"id":@"nameId"};
}
```

#### Author


“caoye”, “1595576349@qq.com”

