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

    if (flag) {

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

#pragma mark - 获取表信息

- (void) getTableInfo
{
    NSArray *tableInfo = @[@"cid",@"name",@"type",@"notnull",@"dflt_value",@"pk"];

    self.fieldArray = [NSMutableArray array];
    self.fieldDict = [NSMutableDictionary dictionary];
    NSMutableArray *typeArray = [NSMutableArray array];

    [[WSqlSession session] quaryBysqlString:SELECT_TABLE_INFO(self.tableName) stepCallBack:^(sqlite3_stmt * _Nullable statement) {

        for (int i = 0; i<tableInfo.count; i++) {

            NSString *key = tableInfo[i];

            char *name = (char*)sqlite3_column_text(statement, i);
            if (name) {

                NSString *stringData = [[NSString alloc]initWithUTF8String:name];
                stringData = [stringData stringByRemovingPercentEncoding];


                if ([key isEqualToString:@"name"]) {
                    [self.fieldArray addObject:stringData];
                }

                if ([key isEqualToString:@"type"]) {
                    [typeArray addObject:stringData];
                }
            }
        }


    } complete:^{

        for (int i = 0;i<self.fieldArray.count;i++) {

            [self.fieldDict setObject:typeArray[i] forKey:self.fieldArray[i]];
        }
    }];
}



#pragma mark - 单表数据操作
/**
 获取表中的记录数据

 @param page 页数
 @param limit 每页记录数
 @param recodeName 要实例化并赋值的模型名称
 @param result 执行成功回调
 */
- (void) getListWithPage:(int)page
                        limit:(int)limit
                   recodeName:(NSString *)recodeName
                  result:(void(^)(NSArray *array))result;
{
    [WSqlQuery query].select(@"*").fromTable(self.tableName).limit(page, limit);
    [self getListWithRecodeName:recodeName result:result];
}


/**
 获取列表信息

 @param recodeName 记录类名称
 @param result 执行成功回调
 */
- (void) getListWithRecodeName:(NSString *)recodeName
                        result:(void(^)(NSArray *array))result;
{
    //数据数组
    NSMutableArray *listArray = [NSMutableArray array];

    [[WSqlSession session] quaryBysqlString:[WSqlQuery query].sql() stepCallBack:^(sqlite3_stmt * _Nullable satement) {

        [listArray addObject:[self handleStatementWithRecodeName:recodeName statement:satement]];
    } complete:^{

        result(listArray);
    }];
}


/**
 处理返回结果

 @param recodeName 字段类名
 @param statement 一条记录
 @return 返回实例化的结果
 */
- (id) handleStatementWithRecodeName:(NSString *)recodeName
                           statement:(sqlite3_stmt *)statement
{
    id obj = [NSClassFromString(recodeName) new];//创建对象
    if (!obj) {
        obj = [NSMutableDictionary dictionary];
    }

    SEL dismissbtn = NSSelectorFromString(@"setTableName:");
    if ([obj respondsToSelector:dismissbtn]) {
        [obj performSelector:dismissbtn withObject:self.tableName];
    }

    //给单个记录对象赋值
    NSDictionary *propAndTypes = [obj getPropertiesAndTypes];

    NSArray *fieldsArray;
    if ([[WSqlQuery query].getSelectFields() containsString:@"*"]) {
        fieldsArray = self.fieldArray;
    }
    else{

        fieldsArray = [[WSqlQuery query].getSelectFields() componentsSeparatedByString:@","];
    }

    for (int i = 0; i<fieldsArray.count; i++) {

        NSString *key = fieldsArray[i];
        NSString *type = propAndTypes[key];

        if ([type containsString:@"Ti"]) {

            NSInteger intdata = sqlite3_column_int(statement, i);
            [obj setValue:@(intdata) forKey:key];
        }
        else if ([type containsString:@"TB"]) {

            int integerValue = sqlite3_column_int(statement, i);
            [obj setValue:@(integerValue) forKey:key];
        }
        else if ([type containsString:@"Td"]) {

            double doubledata = sqlite3_column_double(statement, i);
            [obj setValue:@(doubledata) forKey:key];
        }
        else if ([type containsString:@"NSString"]) {

            char *name = (char*)sqlite3_column_text(statement, i);
            if (name) {

                NSString *stringData = [[NSString alloc]initWithUTF8String:name];
                stringData = [stringData stringByRemovingPercentEncoding];
                [obj setValue:stringData forKey:key];
            }
        }
        else if ([type containsString:@"NSData"]) {

            NSData *name = (__bridge NSData *)sqlite3_column_blob(statement, i);
            if (name) {

                [obj setValue:name forKey:key];
            }
        }
    }

    return obj;
}

/**
 添加字段

 @param column 字段内容
 @return 返回是否成功
 */
- (BOOL) addColumn:(NSString *)column;
{
    [WSqlQuery query].alert(self.tableName).add(column);
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
    [self getListWithRecodeName:recodeName result:result];
}

- (void) rightJoinWithTable:(NSString *)tableName
                     field:(NSString *)field
               recoderName:(NSString *)recodeName
                 condition:(NSString *)condition
                    result:(void(^)(NSArray *array))result;
{
    [WSqlQuery query].select(field).fromTable(self.tableName).rightJoin(tableName).onCondition(condition);
    [self getListWithRecodeName:recodeName result:result];
}


- (void) crossJoinWithTable:(NSString *)tableName
                      field:(NSString *)field
                recoderName:(NSString *)recodeName
                  condition:(NSString *)condition
                     result:(void(^)(NSArray *array))result;
{
    [WSqlQuery query].select(field).fromTable(self.tableName).crossJoin(tableName).onCondition(condition);
    [self getListWithRecodeName:recodeName result:result];
}


- (void) innerJoinWithTable:(NSString *)tableName
                      field:(NSString *)field
                recoderName:(NSString *)recodeName
                  condition:(NSString *)condition
                     result:(void(^)(NSArray *array))result;
{
    [WSqlQuery query].select(field).fromTable(self.tableName).innerJoin(tableName).onCondition(condition);
    [self getListWithRecodeName:recodeName result:result];
}


- (void) outerJoinWithTable:(NSString *)tableName
                      field:(NSString *)field
                recoderName:(NSString *)recodeName
                  condition:(NSString *)condition
                     result:(void(^)(NSArray *array))result;
{
    [WSqlQuery query].select(field).fromTable(self.tableName).outerJoin(tableName).onCondition(condition);
    [self getListWithRecodeName:recodeName result:result];
}


@end
