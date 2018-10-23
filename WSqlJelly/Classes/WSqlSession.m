//
//  WSqlSession.m
//  Pods
//
//  Created by 吴志强 on 2018/7/30.
//

#import "WSqlSession.h"

@implementation WSqlSession
{
    sqlite3 *dataBase;
    NSString *_dbName;
}

static WSqlSession *sharedInstance = nil;
static dispatch_once_t once;

#pragma mark - 初始化连接
+ (WSqlSession *) session;
{
    dispatch_once(&once, ^{

        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


/**
 初始化数据库

 @param dbName 数据库名称
 @return 返回实例化的数据库管理者
 */
-(instancetype)initWithDBName:(NSString *)dbName;
{
    self = [super init];
    if (self) {

        _dbName = dbName;

        //连接数据库
        _isConnected = [self selectDataBaseWithDBName:dbName];
    }
    return self;
}


/**
 更改数据库

 @param dbName 数据库名称
 */
-(BOOL)selectDataBaseWithDBName:(NSString *)dbName;
{
    _dbName = dbName;
    return [self connectToDataBase:dbName];
}


/**
 打开数据库

 @return 返回是否打开成功
 */
- (BOOL) open;
{
    return [self selectDataBaseWithDBName:_dbName];
}


/**
 关闭数据库
 */
- (void) close;
{
    sqlite3_close(dataBase);
}

#pragma mark - sql操作
/**
 连接到本地数据库

 @param dbname 要连接的数据库名称
 @return 返回连接状态
 */
- (BOOL) connectToDataBase:(NSString *)dbname;
{
    if (dbname.length > 0) {

        //1.获取数据库路径
        if (![dbname containsString:@"."]) {
            dbname = [dbname stringByAppendingString:@".db"];
        }
        NSString *filePath = [[WFileManager getDocumentPath] stringByAppendingPathComponent:dbname];
        [WSqlQuery showMessage:[NSString stringWithFormat:@"数据库位置: %@",filePath]];

        //2.连接数据库
        if (sqlite3_open([filePath UTF8String], &dataBase) != SQLITE_OK) {

            sqlite3_close(dataBase);
            [WSqlQuery showMessage:[NSString stringWithFormat:@"数据库：%@ 打开失败！",dbname]];

            return NO;
        }
    }
    else{

        [WSqlQuery showMessage:[NSString stringWithFormat:@"数据库：%@ 打开失败！",dbname]];
        return NO;
    }

    return YES;
}


/**
 执行sql语句

 @param sqlString 要执行的sql语句
 @return 返回执行结果
 */
- (BOOL) exeSql:(NSString *)sqlString;
{
    if (sqlString.length > 0) {

        char *err;
        BOOL state = sqlite3_exec(dataBase, [sqlString UTF8String], NULL, NULL, &err) != SQLITE_OK;

        if (state) {

            [WSqlQuery showMessage:[NSString stringWithFormat:@"数据库操作数据失败! \n [ %@ ] \n err: %s\n",sqlString,err]];
        }

        return state;
    }
    else{

        [WSqlQuery showMessage:@"sql语句不能为空!"];
        return NO;
    }
}


/**
 查询数据，返回字典

 @param sqlString sql语句
 @param fieldsList sql语句
 */
- (NSArray *) quaryBySqlString:(NSString *)sqlString
                    fieldsList:(NSArray *)fieldsList;
{
    NSMutableArray *listArray = [NSMutableArray array];

    if (sqlString.length > 0) {

        // 预编译
        sqlite3_stmt * statement;
        if (sqlite3_prepare_v2(dataBase, [sqlString UTF8String], -1, &statement, nil) == SQLITE_OK) {

            // 开始执行
            while (sqlite3_step(statement) == SQLITE_ROW) {

                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                for (int i = 0; i<fieldsList.count; i++) {

                    NSString *key = fieldsList[i];
                    char *name = (char *)sqlite3_column_text(statement, i);
                    if (name) {
                        
                        NSString *string = [NSString stringWithUTF8String:name];
//                        string = [string stringByRemovingPercentEncoding];

                        if (string) {
                            
                            [dict setObject:string forKey:key];
                        }
                    }
                }
                [listArray addObject:dict];
            }
        }
        else{

            [WSqlQuery showMessage:[NSString stringWithFormat:@"查询失败! \n [ %@ ] \n %s",sqlString,sqlite3_errmsg(dataBase)]];
        }

        sqlite3_finalize(statement);
    }
    else{

        [WSqlQuery showMessage:@"sql语句不能为空!"];
    }

    return listArray;
}


/**
 执行wsqlquery定义好的sql语句

 @return 返回执行结果
 */
- (BOOL) exeSqlQuery;
{
    return [self exeSql:[WSqlQuery query].sql()];
}

/**
 开始事务
 */
- (void) beginTransAction;
{
    [self exeSql:@"BEGIN;"];
}


/**
 提交事务
 */
- (void) commitTransAction;
{
    [self exeSql:@"COMMIT;"];
}


/**
 回滚到上次commit 或者 rollback的点
 */
- (void) rollBack;
{
    [self exeSql:@"ROLLBACK;"];
}


/**
 设置字符集
 */
- (void) setCharactSet
{
    [self exeSql:@"SET NAMES utf8;"];
}
@end
