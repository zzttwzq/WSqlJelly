//
//  WSqlRecorder.h
//  Pods
//
//  Created by 吴志强 on 2018/7/30.
//

#import <Foundation/Foundation.h>
#import "WSqlSession.h"

@interface WSqlRecorder : NSObject

/**
 设置表名
 */
@property (nonatomic,copy) NSString *tableName;

/**
 获取记录实例

 @param tableName 表名
 */
+ (instancetype) recorderWithTableName:(NSString *)tableName;


/**
 创建记录模型

 @param tableName 表名
 @return 返回模型
 */
- (instancetype) initWithTableName:(NSString *)tableName;


/**
 插入新数据或者更新旧的数据

 @param string 条件
 @return 返回是否成功
 */
- (BOOL) insertOrUpdateOn:(NSString *)string;


/**
 插入新数据

 @param fields 要过滤的字段
 @return 返回操作结果
 */
- (BOOL) insertWithoutFields:(NSArray *)fields;


/**
 插入新数据

 @return 返回操作结果
 */
- (BOOL) insert;


/**
 更新数据去掉字段

 @param fields 要去掉的字段
 @return 返回是否成功
 */
- (BOOL) updateWithoutFields:(NSArray *)fields;


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
