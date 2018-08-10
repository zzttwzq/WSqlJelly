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
 插入新数据或者更新旧的数据

 @param string 条件
 @return 返回是否成功
 */
- (BOOL) insertOrUpdateOn:(NSString *)string;
{
    NSMutableArray *propArray = [NSMutableArray arrayWithArray:[self getPropertyNames]];
    [propArray removeObject:@"s_id"];

    NSDictionary *propDict = [self getPropertiesAndValues];

    NSMutableArray *valueArray = [NSMutableArray array];
    for (int i = 0; i<propArray.count; i++) {

        [valueArray addObject:propDict[propArray[i]]];
    }

    [WSqlQuery query].insert(_tableName).fieldList(propArray).valueList(valueArray).where([NSString stringWithFormat:@" NOT EXISTS ( SELECT * FROM %@ WHERE %@ )",_tableName,string]);
    return [[WSqlSession session] exeSqlQuery];
}


/**
 插入新数据

 @param fields 要过滤的字段
 @return 返回操作结果
 */
- (BOOL) insertWithoutFields:(NSArray *)fields;
{
    NSMutableArray *propArray = [NSMutableArray arrayWithArray:[self getPropertyNames]];
    [propArray removeObject:@"s_id"];
    for (NSString *key in fields) {
        [propArray removeObject:key];
    }

    NSDictionary *propDict = [self getPropertiesAndValues];

    NSMutableArray *valueArray = [NSMutableArray array];
    for (int i = 0; i<propArray.count; i++) {

        [valueArray addObject:propDict[propArray[i]]];
    }

    [WSqlQuery query].insert(_tableName).fieldList(propArray).valueList(valueArray);
    return [[WSqlSession session] exeSqlQuery];
}


/**
 插入新数据

 @return 返回操作结果
 */
- (BOOL) insert;
{
    return [self insertWithoutFields:nil];
}


/**
 更新数据去掉字段

 @param fields 要去掉的字段
 @return 返回是否成功
 */
- (BOOL) updateWithoutFields:(NSArray *)fields;
{
    NSMutableDictionary *propDict = [NSMutableDictionary dictionaryWithDictionary:[self getPropertiesAndValues]];
    [propDict removeObjectForKey:@"s_id"];
    for (NSString *key in fields) {
        [propDict removeObjectForKey:key];
    }

    [WSqlQuery query].update(_tableName).updateInfo(propDict).where(@"s_id").equals([NSString stringWithFormat:@"%d",self.s_id]);
    return [[WSqlSession session] exeSqlQuery];
}


/**
 更新数据

 @return 返回操作结果
 */
- (BOOL) update;
{
    return [self updateWithoutFields:nil];
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
