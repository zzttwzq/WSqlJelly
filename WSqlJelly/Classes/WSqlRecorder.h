//
//  WSqlRecorder.h
//  Pods
//
//  Created by 吴志强 on 2018/7/30.
//

#import <Foundation/Foundation.h>
#import "NSObject+Whandler.h"
#import "WSqlSession.h"

@interface WSqlRecorder : NSObject

/**
 创建记录模型

 @param tableName 表名
 @return 返回模型
 */
+ (WSqlRecorder *) recodeWithTableName:(NSString *)tableName;


/**
 设置数据表名

 @param tableName 数据表名
 */
- (void) setTableName:(NSString *)tableName;


/**
 插入新数据

 @return 返回操作结果
 */
- (BOOL) insert;


/**
 更新数据

 @return 返回操作结果
 */
- (BOOL) update;


/**
 删除数据

 @return 返回操作结果
 */
- (BOOL) remove;

@end
