//
//  WSqlTable.h
//  Pods
//
//  Created by 吴志强 on 2018/7/30.
//

#import <Foundation/Foundation.h>
#import "WSqlSession.h"
#import "WSqlRecorder.h"

@interface WSqlTable : NSObject

#pragma mark - 创建表

@property (nonatomic,copy) NSString *tableName;

/**
 创建表

 @param tableName 表名
 @param infoDic 表信息字典
 @return 返回实例对象。
 */
+ (WSqlTable *) createTableWithName:(NSString *)tableName
                            infoDic:(NSDictionary *)infoDic;


/**
 获取表

 @param tableName 表名
 @return 返回需要的表
 */
+ (WSqlTable *) tableWithName:(NSString *)tableName;


/**
 删除表

 @return 返回是否成功 
 */
- (BOOL) deleteTable;


/**
 删除所有

 @return 返回是否成功
 */
- (BOOL) deleteAll;


#pragma mark - 单表数据操作
/**
 记录数据

 @return 返回记录数据
 */
- (NSInteger) totalCount;


/**
 记录数据

 @param condition 条件
 @return 返回符合条件的所有记录
 */
- (NSInteger) totalCountWithCondition:(NSString *)condition;


/**
 获取列表信息

 @param recordeName 记录类名称
 @param condition 条件
 @return 返回模型化的数据列表
 */
- (NSArray *) listWithRecordeName:(NSString *)recordeName
                         condition:(NSString *)condition;


/**
 分页获取表中的记录数据（返回模型数组）

 @param condition 条件
 @param recordeName 模型名称
 @param page 分页
 @param limit 每页记录数
 @return 返回模型数组
 */
- (NSArray *) listWithRecordeName:(NSString *)recordeName
                         condition:(NSString *)condition
                            Page:(int)page
                           limit:(int)limit;


/**
 添加字段

 @param column 字段内容
 @return 返回是否成功
 */
- (BOOL) addColumn:(NSString *)column;


/**
 修改字段名字

 @param column 要修改的字段
 @param toName 修改的字段名字
 @return 返回是否成功
 */
- (BOOL) renameColumn:(NSString *)column
               toName:(NSString *)toName;


/**
 记录是否存在，返回记录  如果不填写recodename 就返回记录的字典

 @param recorde 字符串填写条件，比如 id = 1
 @param recordeName 记录类名称
 @return 返回记录的字典
 */
- (NSArray *) recordeExistsWithCondition:(NSString *)recorde
                             recordeName:(NSString *)recordeName;

#pragma mark - 多表数据操作


@end
