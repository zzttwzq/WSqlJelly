//
//  WSqlSession.h
//  Pods
//
//  Created by 吴志强 on 2018/7/30.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <malloc/malloc.h>

#import "WFileManager.h"
#import "WSqlQuery.h"
#import "NSObject+Whandler.h"

typedef void (^queryBlock)(sqlite3_stmt * _Nullable satement);

@interface WSqlSession : NSObject
@property (nonatomic,assign) BOOL isConnected;

#pragma mark - 初始化连接
/**
 更改数据库

 @param dbName 数据库名称
 */
- (BOOL) selectDataBaseWithDBName:(NSString *)dbName;


/**
 获取全局的session

 @return 返回session
 */
+ (WSqlSession *) session;


/**
 打开数据库

 @return 返回是否打开成功
 */
- (BOOL) open;


/**
 关闭数据库
 */
- (void) close;


#pragma mark - sql操作
/**
 执行sql语句

 @param sqlString 要执行的sql语句
 @return 返回执行结果
 */
- (BOOL) exeSql:(NSString *)sqlString;


/**
执行wsqlquery定义好的sql语句

@return 返回执行结果
*/
- (BOOL) exeSqlQuery;


/**
 查询数据方法

 @param sqlString sql语句
 @param stepCallBack 循环遍历数据
 */
-(void)quaryBysqlString:(NSString *)sqlString
           stepCallBack:(queryBlock)stepCallBack
               complete:(void(^)(void))complete;


/**
 开启事务
 */
- (void) beginTransAction;


/**
 提交事务
 */
- (void) commitTransAction;


/**
 回滚到上次commit 或者 rollback的点
 */
- (void) rollBack;
@end
