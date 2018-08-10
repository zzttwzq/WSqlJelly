//
//  WSqlQuery.h
//  test
//
//  Created by 吴志强 on 2018/7/31.
//  Copyright © 2018年 吴志强. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSqlQuery;

typedef WSqlQuery *(^stringBlock)(NSString *string);

typedef WSqlQuery *(^doubleStringBlock)(NSString *string1,NSString *string2);

typedef WSqlQuery *(^voidBlock)(void);

typedef WSqlQuery *(^arrayBlock)(NSArray *array);

typedef WSqlQuery *(^dictBlock)(NSDictionary *dict);

typedef WSqlQuery *(^limitBlock)(int page,int limit);

typedef NSString *(^getStringBlock)(void);

@interface WSqlQuery : NSObject

@property (nonatomic,copy) stringBlock select;
@property (nonatomic,copy) voidBlock selectCount;
@property (nonatomic,copy) stringBlock insert;
@property (nonatomic,copy) stringBlock insertOrReplace;
@property (nonatomic,copy) stringBlock update;
@property (nonatomic,copy) stringBlock deleteFromeTable;
@property (nonatomic,copy) stringBlock deleteAllFromeTable;
@property (nonatomic,copy) stringBlock createTable;
@property (nonatomic,copy) stringBlock alert;

@property (nonatomic,copy) stringBlock inCondition;
@property (nonatomic,copy) stringBlock onCondition;
@property (nonatomic,copy) stringBlock where;
@property (nonatomic,copy) stringBlock fromTable;
@property (nonatomic,copy) arrayBlock fieldList;
@property (nonatomic,copy) arrayBlock valueList;
@property (nonatomic,copy) arrayBlock tableFieldList;
@property (nonatomic,copy) dictBlock fieldAndInfo;
@property (nonatomic,copy) dictBlock updateInfo;
@property (nonatomic,copy) stringBlock addColumn;
@property (nonatomic,copy) doubleStringBlock renameColumn;

@property (nonatomic,copy) stringBlock equals;
@property (nonatomic,copy) stringBlock above;
@property (nonatomic,copy) stringBlock less;
@property (nonatomic,copy) stringBlock above_equal;
@property (nonatomic,copy) stringBlock less_equal;
@property (nonatomic,copy) voidBlock andState;
@property (nonatomic,copy) voidBlock orState;

@property (nonatomic,copy) stringBlock like;
@property (nonatomic,copy) limitBlock limit;
@property (nonatomic,copy) stringBlock orderBy;
@property (nonatomic,copy) stringBlock groupBy;
@property (nonatomic,copy) stringBlock having;

@property (nonatomic,copy) stringBlock leftJoin;
@property (nonatomic,copy) stringBlock rightJoin;
@property (nonatomic,copy) stringBlock innerJoin;
@property (nonatomic,copy) stringBlock outerJoin;
@property (nonatomic,copy) stringBlock crossJoin;

@property (nonatomic,copy) voidBlock unionState;
@property (nonatomic,copy) voidBlock unionAllState;

@property (nonatomic,copy) getStringBlock sql;
@property (nonatomic,copy) getStringBlock getSelectFields;


+ (WSqlQuery *) query;


#pragma mark - 其他方法
/**
 调试的时候显示调试消息

 @param message 调试消息
 */
+(void)showMessage:(NSString *)message;
@end
