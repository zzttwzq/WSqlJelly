//
//  WSqlRecorder.m
//  Pods
//
//  Created by 吴志强 on 2018/7/30.
//

#import "WSqlRecorder.h"

@interface WSqlRecorder ()

@property(nonatomic,assign)int s_id;

@end

@implementation WSqlRecorder
{
    NSString *_tableName;
}

/**
 创建记录模型

 @param tableName 表名
 @return 返回模型
 */
+ (WSqlRecorder *) recodeWithTableName:(NSString *)tableName;
{
    WSqlRecorder *recode = [[WSqlRecorder alloc] initWithTableName:tableName];
    return recode;
}

/**
 创建记录模型

 @param tableName 表名
 @return 返回模型
 */
- (instancetype) initWithTableName:(NSString *)tableName;
{
    self = [super init];
    if (self) {

        _tableName = tableName;
    }
    return self;
}


/**
 设置数据表名

 @param tableName 数据表名
 */
- (void) setTableName:(NSString *)tableName;
{
    _tableName = tableName;
}


/**
 插入新数据

 @return 返回操作结果
 */
- (BOOL) insert;
{
    NSMutableArray *propArray = [NSMutableArray arrayWithArray:[self getPropertyNames]];
    [propArray removeObject:@"s_id"];

    NSDictionary *propDict = [self getPropertiesAndValues];

    NSMutableArray *valueArray = [NSMutableArray array];
    for (int i = 0; i<propArray.count; i++) {

        [valueArray addObject:propDict[propArray[i]]];
    }

    [WSqlQuery query].insert(_tableName).fieldList(propArray).valueList(valueArray);
    return [[WSqlSession session] exeSqlQuery];
}


/**
 更新数据

 @return 返回操作结果
 */
- (BOOL) update;
{
    NSMutableDictionary *propDict = [NSMutableDictionary dictionaryWithDictionary:[self getPropertiesAndValues]];
    [propDict removeObjectForKey:@"s_id"];

    [WSqlQuery query].update(_tableName).updateInfo(propDict).where(@"s_id").equals([NSString stringWithFormat:@"%d",self.s_id]);
    return [[WSqlSession session] exeSqlQuery];
}


/**
 删除数据

 @return 返回操作结果
 */
- (BOOL) remove;
{
    [WSqlQuery query].deleteFromeTable(_tableName).where(@"s_id").equals([NSString stringWithFormat:@"%d",self.s_id]);
    return [[WSqlSession session] exeSqlQuery];
}

@end
