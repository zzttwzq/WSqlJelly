//
//  WSqlQuery.m
//  test
//
//  Created by 吴志强 on 2018/7/31.
//  Copyright © 2018年 吴志强. All rights reserved.
//

#import "WSqlQuery.h"

@interface WSqlQuery ()

@property (nonatomic,copy) NSString *selectFieldString;
@property (nonatomic,copy) NSString *sqlString;
@property (nonatomic,copy) NSArray *filedLists;
@property (nonatomic,copy) NSDictionary *fieldInfoDict;

@end

@implementation WSqlQuery

static WSqlQuery *sharedInstance = nil;
static dispatch_once_t once;

+ (WSqlQuery *) query;
{
    dispatch_once(&once, ^{

        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void) clear;
{
    [WSqlQuery query].sqlString = @"";
}

- (instancetype) init
{
    self = [super init];
    if (self) {

        self.sqlString = @"";

        [self prepareOpration];

        [self prepareConditions];

        [self prepareControl];
    }
    return self;
}

- (void) prepareControl
{
    __weak typeof(WSqlQuery *)weakSelf = self;

    self.sql = ^NSString *{

        return weakSelf.sqlString;
    };

    self.getSelectFields = ^NSString *{

        return weakSelf.selectFieldString;
    };

    self.where = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" WHERE %@",string]];
        return weakSelf;
    };


    self.onCondition = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" ON %@",string]];
        return weakSelf;
    };


    self.inCondition = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" IN %@",string]];
        return weakSelf;
    };

    self.where = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" WHERE %@",string]];
        return weakSelf;
    };

    self.like = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" LIKE %@",string]];
        return weakSelf;
    };

    self.limit = ^WSqlQuery *(int page, int limit) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" LIMIT %d,%d",page*limit,limit]];
        return weakSelf;
    };

    self.orderBy = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" ORDER BY %@",string]];
        return weakSelf;
    };

    self.groupBy = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" GROUP BY %@",string]];
        return weakSelf;
    };

    self.having = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" HAVING %@",string]];
        return weakSelf;
    };

    
}

- (void) prepareOpration
{
    __weak typeof(WSqlQuery *)weakSelf = self;

    self.fromTable = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" %@",string]];
        return weakSelf;
    };


    //============选择数据
    self.select = ^WSqlQuery *(NSString *string) {

        weakSelf.selectFieldString = string;
        weakSelf.sqlString = [NSString stringWithFormat:@" SELECT %@ FROM",string];
        return weakSelf;
    };

    self.selectCount = ^WSqlQuery *{

        weakSelf.sqlString = @" SELECT COUNT(*) FROM";
        return weakSelf;
    };


    //============插入数据
    self.insert = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [NSString stringWithFormat:@" INSERT INTO %@",string];
        return weakSelf;
    };

    
    self.insertOrReplace = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [NSString stringWithFormat:@" INSERT OR REPLACE INTO %@",string];
        return weakSelf;
    };


    self.fieldList = ^WSqlQuery *(NSArray *array) {

        NSString *string = @" (";
        for (int i = 0; i<array.count; i++) {

            string = [string stringByAppendingString:[NSString stringWithFormat:@"%@,",array[i]]];
        }
        string = [string substringToIndex:string.length-1]; //去掉，号
        string = [string stringByAppendingString:@") "];//添加结尾

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:string];
        return weakSelf;
    };


    self.valueList = ^WSqlQuery *(NSArray *array) {

        NSString *string = @"VALUES (";
        for (int i = 0; i<array.count; i++) {

            string = [string stringByAppendingString:[NSString stringWithFormat:@"'%@',",array[i]]];
        }
        string = [string substringToIndex:string.length-1]; //去掉，号
        string = [string stringByAppendingString:@")"];//添加结尾

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:string];
        return weakSelf;
    };


    //============修改数据
    self.update = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [NSString stringWithFormat:@" UPDATE %@ SET",string];
        return weakSelf;
    };


    self.updateInfo = ^WSqlQuery *(NSDictionary *dict) {

        NSString *string = @" ";
        for (NSString *key in [dict allKeys]) {

            NSString *value = dict[key];

            string = [string stringByAppendingString:[NSString stringWithFormat:@"%@='%@',",key,value]];
        }
        string = [string substringToIndex:string.length-1]; //去掉，号
        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:string];

        return weakSelf;
    };


    //============删除数据
    self.deleteFromeTable = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [NSString stringWithFormat:@" DELETE FROM %@",string];
        return weakSelf;
    };


    self.deleteAllFromeTable = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [NSString stringWithFormat:@" DELETE FROM %@",string];
        return weakSelf;
    };


    //============创建表
    self.createTable = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [NSString stringWithFormat:@" CREATE TABLE IF NOT EXISTS %@ ",string];
        return weakSelf;
    };


    self.tableFieldList = ^WSqlQuery *(NSArray *array) {

        weakSelf.filedLists = array;
        return weakSelf;
    };


    self.fieldAndInfo = ^WSqlQuery *(NSDictionary *dict) {

        weakSelf.fieldInfoDict = dict;
        NSString *propertystring = @"请把下面的属性添加到sqlrowobj的子类中：\n";
        NSString *string = @"(";

        for (int i = 0; i<weakSelf.filedLists.count; i++) {

            NSString *key = weakSelf.filedLists[i];
            NSString *value = [weakSelf.fieldInfoDict[key] lowercaseString];

            if ([key isEqualToString:@"id"]){
                key = @"s_id";
            }

            string = [string stringByAppendingString:[NSString stringWithFormat:@"%@ %@,",key,value]];

            if ([value containsString:@"char"]||
                [value containsString:@"text"]||
                [value containsString:@"varchar"]||
                [value containsString:@"clob"]) {

                propertystring = [propertystring stringByAppendingString:[NSString stringWithFormat:@"@property(nonatomic,copy)NSString *%@;\n",key]];
            }
            else if ([value containsString:@"bool"]||
                     [value containsString:@"boolean"]){

                propertystring = [propertystring stringByAppendingString:[NSString stringWithFormat:@"@property(nonatomic,assign)BOOL %@;\n",key]];
            }
            else if ([value containsString:@"datetime"]||
                     [value containsString:@"date"]){

                propertystring = [propertystring stringByAppendingString:[NSString stringWithFormat:@"@property(nonatomic,copy)NSString *%@;\n",key]];
            }
            else if ([value containsString:@"int"]||
                     [value containsString:@"integer"]||
                     [value containsString:@"tinyint"]||
                     [value containsString:@"smallint"]||
                     [value containsString:@"mediumint"]||
                     [value containsString:@"bigint"]){

                propertystring = [propertystring stringByAppendingString:[NSString stringWithFormat:@"@property(nonatomic,assign)NSInterger %@;\n",key]];
            }
            else if ([value containsString:@"real"]||
                     [value containsString:@"float"]||
                     [value containsString:@"double"]){

                propertystring = [propertystring stringByAppendingString:[NSString stringWithFormat:@"@property(nonatomic,assign)double %@;\n",key]];
            }
            else if ([value containsString:@"blob"]){

                propertystring = [propertystring stringByAppendingString:[NSString stringWithFormat:@"@property(nonatomic,strong)NSData %@;\n",key]];
            }
            else if ([key containsString:@"s_id"]){

                propertystring = [propertystring stringByAppendingString:[NSString stringWithFormat:@"@property(nonatomic,assign)NSInterger %@;\n",key]];
            }
        }
        string = [string substringToIndex:string.length-1]; //去掉，号
        string = [string stringByAppendingString:@");"];//添加结尾

        propertystring = [propertystring stringByAppendingString:@"\n\n"];
        [WSqlQuery showMessage:propertystring];

        weakSelf.filedLists = nil;

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:string];
        return weakSelf;
    };

    //============表中新建字段
    self.alert = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [NSString stringWithFormat:@" ALTER TABLE %@",string];
        return weakSelf;
    };

    self.addColumn = ^WSqlQuery *(NSString *string2) {

        NSArray *array = [string2 componentsSeparatedByString:@" "];
        NSString *key = array[0];
        NSString *value = [string2 substringFromIndex:key.length];

        NSString *propertystring = @"请把下面的属性添加到sqlrowobj的子类中：\n";

        if ([value containsString:@"char"]||
            [value containsString:@"text"]||
            [value containsString:@"varchar"]||
            [value containsString:@"clob"]) {

            propertystring = [propertystring stringByAppendingString:[NSString stringWithFormat:@"@property(nonatomic,copy)NSString *%@;\n",key]];
        }
        else if ([value containsString:@"bool"]||
                 [value containsString:@"boolean"]){

            propertystring = [propertystring stringByAppendingString:[NSString stringWithFormat:@"@property(nonatomic,assign)BOOL %@;\n",key]];
        }
        else if ([value containsString:@"datetime"]||
                 [value containsString:@"date"]){

            propertystring = [propertystring stringByAppendingString:[NSString stringWithFormat:@"@property(nonatomic,copy)NSString *%@;\n",key]];
        }
        else if ([value containsString:@"int"]||
                 [value containsString:@"integer"]||
                 [value containsString:@"tinyint"]||
                 [value containsString:@"smallint"]||
                 [value containsString:@"mediumint"]||
                 [value containsString:@"bigint"]){

            propertystring = [propertystring stringByAppendingString:[NSString stringWithFormat:@"@property(nonatomic,assign)int %@;\n",key]];
        }
        else if ([value containsString:@"real"]||
                 [value containsString:@"float"]||
                 [value containsString:@"double"]){

            propertystring = [propertystring stringByAppendingString:[NSString stringWithFormat:@"@property(nonatomic,assign)double %@;\n",key]];
        }
        else if ([value containsString:@"blob"]){

            propertystring = [propertystring stringByAppendingString:[NSString stringWithFormat:@"@property(nonatomic,strong)NSData %@;\n",key]];
        }
        else if ([key containsString:@"s_id"]){

            propertystring = [propertystring stringByAppendingString:[NSString stringWithFormat:@"@property(nonatomic,assign)int %@;\n",key]];
        }

        propertystring = [propertystring stringByAppendingString:@"\n\n"];
        [WSqlQuery showMessage:propertystring];

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" ADD COLUMN %@",string2]];
        return weakSelf;
    };

    self.renameColumn = ^WSqlQuery *(NSString *string1, NSString *string2) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@"%@ RENAME TO %@",string1,string2]];
        return weakSelf;
    };
}

- (void) prepareConditions
{
    __weak typeof(WSqlQuery *)weakSelf = self;
    //============条件
    self.equals = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" = '%@'",string]];
        return weakSelf;
    };

    self.above = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" > '%@'",string]];
        return weakSelf;
    };

    self.less = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" < '%@'",string]];
        return weakSelf;
    };

    self.above_equal = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" >= '%@'",string]];
        return weakSelf;
    };

    self.less_equal = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" <= '%@'",string]];
        return weakSelf;
    };

    self.andState = ^WSqlQuery *{

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:@" AND"];
        return weakSelf;
    };

    self.orState = ^WSqlQuery *{

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:@" OR"];
        return weakSelf;
    };
}

- (void) prepareJoin
{
    __weak typeof(WSqlQuery *)weakSelf = self;

    self.leftJoin = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" LEFT %@",string]];
        return weakSelf;
    };

    self.rightJoin = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" RIGHT %@",string]];
        return weakSelf;
    };

    self.innerJoin = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" JOIN %@",string]];
        return weakSelf;
    };

    self.outerJoin = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" OUTER JOIN %@",string]];
        return weakSelf;
    };

    self.crossJoin = ^WSqlQuery *(NSString *string) {

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:[NSString stringWithFormat:@" CROSS JOIN %@",string]];
        return weakSelf;
    };

    self.unionState = ^WSqlQuery *{

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:@" UNION"];
        return weakSelf;
    };

    self.unionAllState = ^WSqlQuery *{

        weakSelf.sqlString = [weakSelf.sqlString stringByAppendingString:@" UNION ALL"];
        return weakSelf;
    };
}

#pragma mark - 其他方法
/**
 调试的时候显示调试消息

 @param message 调试消息
 */
+(void)showMessage:(NSString *)message;
{
    #ifdef DEBUG
        NSLog(@" < WSql > %@",message);
    #endif
}
@end
