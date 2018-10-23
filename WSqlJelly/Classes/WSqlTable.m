//
//  WSqlTable.m
//  Pods
//
//  Created by 吴志强 on 2018/7/30.
//

#import "WSqlTable.h"

#define SELECT_TABLE_INFO(TABLENAME) [NSString stringWithFormat:@"pragma table_info(%@)",TABLENAME]

@interface WSqlTable ()

@property (nonatomic,strong) NSMutableArray *fieldArray;
@property (nonatomic,strong) NSMutableDictionary *fieldDict;

@end

@implementation WSqlTable

#pragma mark - 创建表
/**
 创建表

 @param tableName 表名
 @param infoDic 表信息字典
 @return 返回实例对象。
 */
+ (WSqlTable *) createTableWithName:(NSString *)tableName
                            infoDic:(NSDictionary *)infoDic;
{
    NSMutableArray *keyArray = [NSMutableArray array];
    for (NSString *key in [infoDic allKeys]) {
        [keyArray addObject:key];
    }

    [WSqlQuery query].createTable(tableName).tableFieldList(keyArray).fieldAndInfo(infoDic);
    BOOL flag = [[WSqlSession session] exeSqlQuery];

    if (!flag) {

        WSqlTable *table = [WSqlTable new];
        table.tableName = tableName;
        [table getTableInfo];

        return table;
    }

    return nil;
}


/**
 获取表

 @param tableName 表名
 @return 返回需要的表
 */
+ (WSqlTable *) tableWithName:(NSString *)tableName;
{
    WSqlTable *table = [WSqlTable new];
    table.tableName = tableName;
    [table getTableInfo];

    return table;
}


/**
 删除表

 @return 返回是否成功
 */
- (BOOL) deleteTable;
{
    [WSqlQuery query].deleteFromeTable(self.tableName);
    return [[WSqlSession session] exeSqlQuery];
}

/**
 清除表中的所有数据

 @return 返回是否成功
 */
- (BOOL) clearTable;
{
    [WSqlQuery query].deleteAllFromeTable(self.tableName);
    return [[WSqlSession session] exeSqlQuery];
}

#pragma mark - 获取表信息

- (void) getTableInfo
{
    NSArray *tableInfo = @[@"cid",@"name",@"type",@"notnull",@"dflt_value",@"pk"];

    self.fieldArray = [NSMutableArray array];
    self.fieldDict = [NSMutableDictionary dictionary];

    NSArray *array = [[WSqlSession session] quaryBySqlString:SELECT_TABLE_INFO(self.tableName) fieldsList:tableInfo];

    for (int i = 0; i<array.count; i++) {

        NSString *name = array[i][@"name"];
        if (name) {

            [self.fieldArray addObject:name];
            [self.fieldDict setObject:array[i][@"type"] forKey:name];
        }
    }
}


#pragma mark - 单表数据操作
/**
 记录数据

 @return 返回记录数据
 */
- (NSInteger) totalCount;
{
    [WSqlQuery query].selectCount().fromTable(self.tableName);
    NSArray *array = [[WSqlSession session] quaryBySqlString:[WSqlQuery query].sql() fieldsList:@[@"count"]];

    if (array.count == 0) {
        return 0;
    }

    return [array[0][@"count"] integerValue];
}


/**
 记录数据

 @param condition 条件
 @return 返回符合条件的所有记录
 */
- (NSInteger) countWithCondition:(NSString *)condition;
{
    //数据数组
    if (condition.length > 0) {
        [WSqlQuery query].selectCount().fromTable(self.tableName).where(condition);
    }
    else{
        [WSqlQuery query].selectCount().fromTable(self.tableName);
    }

    NSArray *array = [[WSqlSession session] quaryBySqlString:[WSqlQuery query].sql() fieldsList:@[@"count"]];

    if (array.count == 0) {
        return 0;
    }

    return [array[0][@"count"] integerValue];
}



/**
 获取列表信息 (recodeName不填写则返回字典)

 @param recordeName 记录类名称
 @param where where条件
 @param orderBy orderby条件
 @return 返回查询到的数据
 */
- (NSArray *) listWithRecordeName:(NSString *)recordeName
                            where:(NSString *)where
                          orderBy:(NSString *)orderBy;
{
    //数据数组
    if (where.length > 0) {

        if (orderBy.length > 0) {

            [WSqlQuery query].select(@"*").fromTable(self.tableName).where(where).orderBy(orderBy);
        }
        else{

            [WSqlQuery query].select(@"*").fromTable(self.tableName).where(where);
        }
    }
    else{

        [WSqlQuery query].select(@"*").fromTable(self.tableName);
    }

    NSArray *array = [[WSqlSession session] quaryBySqlString:[WSqlQuery query].sql() fieldsList:self.fieldArray];

    if (recordeName.length > 0) {

        NSMutableArray *dataListArray = [NSMutableArray array];
        for (int i = 0; i<array.count; i++) {

            [dataListArray addObject:[self modelerWithName:recordeName dict:array[i]]];
        }

        return dataListArray;
    }
    else{

        return array;
    }
}


/**
 获取列表信息 (recodeName不填写则返回字典)

 @param recordeName 记录类名称
 @param page 分页
 @param limit 每页记录数
 @param where where条件
 @param orderBy orderby条件
 @return 返回查询到的数据
 */
- (NSArray *) listWithRecordeName:(NSString *)recordeName
                             Page:(int)page
                            limit:(int)limit
                            where:(NSString *)where
                          orderBy:(NSString *)orderBy;
{
    //数据数组
    if (where.length > 0) {

        if (orderBy.length > 0) {

            [WSqlQuery query].select(@"*").fromTable(self.tableName).where(where).orderBy(orderBy).limit(page, limit);
        }
        else{

            [WSqlQuery query].select(@"*").fromTable(self.tableName).where(where).limit(page, limit);
        }
    }
    else{

        [WSqlQuery query].select(@"*").fromTable(self.tableName).limit(page, limit);
    }

    NSArray *array = [[WSqlSession session] quaryBySqlString:[WSqlQuery query].sql() fieldsList:self.fieldArray];

    if (recordeName.length > 0) {

        NSMutableArray *dataListArray = [NSMutableArray array];
        for (int i = 0; i<array.count; i++) {

            NSObject *obj = [self modelerWithName:recordeName dict:array[i]];
            if (obj) {
                [dataListArray addObject:obj];
            }
        }

        return dataListArray;
    }
    else{

        return array;
    }
}


/**
 获取列表信息

 @param recordeName 记录类名称
 @return 返回模型化的数据列表
 */
- (NSArray *) listWithRecordeName:(NSString *)recordeName;
{
    //数据数组
    [WSqlQuery query].select(@"*").fromTable(self.tableName);

    NSArray *array = [[WSqlSession session] quaryBySqlString:[WSqlQuery query].sql() fieldsList:self.fieldArray];

    if (recordeName.length > 0) {

        NSMutableArray *dataListArray = [NSMutableArray array];
        for (int i = 0; i<array.count; i++) {

            [dataListArray addObject:[self modelerWithName:recordeName dict:array[i]]];
        }

        return dataListArray;
    }
    else{

        return array;
    }
}


/**
 分页获取表中的记录数据（返回模型数组）

 @param recordeName 模型名称
 @param page 分页
 @param limit 每页记录数
 @return 返回模型数组
 */
- (NSArray *) listWithRecordeName:(NSString *)recordeName
                             Page:(int)page
                            limit:(int)limit;
{
    //数据数组
    [WSqlQuery query].select(@"*").fromTable(self.tableName).limit(page, limit);
    NSArray *array = [[WSqlSession session] quaryBySqlString:[WSqlQuery query].sql() fieldsList:self.fieldArray];

    if (recordeName.length > 0) {

        NSMutableArray *dataListArray = [NSMutableArray array];
        for (int i = 0; i<array.count; i++) {

            [dataListArray addObject:[self modelerWithName:recordeName dict:array[i]]];
        }

        return dataListArray;
    }
    else{

        return array;
    }
}


/**
 模型化并赋值数据

 @param recodeName 模型化的类名
 @param dict 要赋值的字典
 @return 返回模型
 */
- (id) modelerWithName:(NSString *)recodeName
                 dict:(NSDictionary *)dict;
{
    id obj = [NSClassFromString(recodeName) new];//创建对象
    SEL dismissbtn = NSSelectorFromString(@"setTableName:");
    if ([obj respondsToSelector:dismissbtn]) {
        [obj performSelector:dismissbtn withObject:self.tableName];
    }

    [obj safeSetWithDict:dict];
    return obj;
}


/**
 记录是否存在，返回记录  如果不填写recodename 就返回记录的字典

 @param recorde 字符串填写条件，比如 id = 1
 @param recordeName 记录类名称
 @return 返回记录的字典
 */
- (NSArray *) existRecordeWithCondition:(NSString *)recorde
                            recordeName:(NSString *)recordeName;
{
        //数据数组
    [WSqlQuery query].select(@"*").fromTable(self.tableName).where(recorde);

    NSArray *dictInfoArray = [[WSqlSession session] quaryBySqlString:[WSqlQuery query].sql() fieldsList:self.fieldArray];

    if (recordeName.length == 0) {
        return dictInfoArray;
    }

    NSMutableArray *dataListArray = [NSMutableArray array];
    for (int i = 0; i<dictInfoArray.count; i++) {

        [dataListArray addObject:[self modelerWithName:recordeName dict:dictInfoArray[i]]];
    }

    return dataListArray;
}


/**
 添加字段

 @param columnDescription 字段内容
 @return 返回是否成功
 */
- (BOOL) addColumnWithDescription:(NSString *)columnDescription;
{
    [WSqlQuery query].alert(self.tableName).addColumn(columnDescription);
    return [[WSqlSession session] exeSqlQuery];
}


/**
 修改字段名字

 @param column 要修改的字段
 @param toName 修改的字段名字
 @return 返回是否成功
 */
- (BOOL) renameColumn:(NSString *)column
               toName:(NSString *)toName;
{
    [WSqlQuery query].alert(self.tableName).renameColumn(column, toName);
    return [[WSqlSession session] exeSqlQuery];
}


#pragma mark - 多表数据操作

- (void) leftJoinWithTable:(NSString *)tableName
                     field:(NSString *)field
               recoderName:(NSString *)recodeName
                 condition:(NSString *)condition
                    result:(void(^)(NSArray *array))result;
{
    [WSqlQuery query].select(field).fromTable(self.tableName).leftJoin(tableName).onCondition(condition);
    result([self listWithRecordeName:recodeName]);
}

- (void) rightJoinWithTable:(NSString *)tableName
                     field:(NSString *)field
               recoderName:(NSString *)recodeName
                 condition:(NSString *)condition
                    result:(void(^)(NSArray *array))result;
{
    [WSqlQuery query].select(field).fromTable(self.tableName).rightJoin(tableName).onCondition(condition);
    result([self listWithRecordeName:recodeName]);
}


- (void) crossJoinWithTable:(NSString *)tableName
                      field:(NSString *)field
                recoderName:(NSString *)recodeName
                  condition:(NSString *)condition
                     result:(void(^)(NSArray *array))result;
{
    [WSqlQuery query].select(field).fromTable(self.tableName).crossJoin(tableName).onCondition(condition);
    result([self listWithRecordeName:recodeName]);
}


- (void) innerJoinWithTable:(NSString *)tableName
                      field:(NSString *)field
                recoderName:(NSString *)recodeName
                  condition:(NSString *)condition
                     result:(void(^)(NSArray *array))result;
{
    [WSqlQuery query].select(field).fromTable(self.tableName).innerJoin(tableName).onCondition(condition);
    result([self listWithRecordeName:recodeName]);
}


- (void) outerJoinWithTable:(NSString *)tableName
                      field:(NSString *)field
                recoderName:(NSString *)recodeName
                  condition:(NSString *)condition
                     result:(void(^)(NSArray *array))result;
{
    [WSqlQuery query].select(field).fromTable(self.tableName).outerJoin(tableName).onCondition(condition);
    result([self listWithRecordeName:recodeName]);
}


@end
