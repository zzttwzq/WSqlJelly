//
//  WSqlTable.h
//  Pods
//
//  Created by 吴志强 on 2018/7/30.
//

#import <Foundation/Foundation.h>
#import "WSqlSession.h"

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


#pragma mark - 单表数据操作
/**
 获取表中的记录数据 （单表）

 @param page 页数
 @param limit 每页记录数
 @param recodeName 要实例化并赋值的模型名称
 @param result 执行成功回调
 */
- (void) getListWithPage:(int)page
                   limit:(int)limit
              recodeName:(NSString *)recodeName
                  result:(void(^)(NSArray *array))result;

/**
 获取列表信息 （单表）

 @param recodeName 记录类名称
 @param result 执行成功回调
 */
- (void) getListWithRecodeName:(NSString *)recodeName
                        result:(void(^)(NSArray *array))result;

/**
 添加字段

 @param column 字段内容
 @return 返回是否成功
 */
- (BOOL) addColumn:(NSString *)column;


#pragma mark - 多表数据操作


@end
