//
//  XTaskManager.h
//  多任务下载
//
//  Created by mgfjx on 2017/7/14.
//  Copyright © 2017年 xintong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XTask;

@interface XTaskManager : NSObject

@property (nonatomic, strong) NSMutableArray<XTask *> *tasksList;
@property (nonatomic, assign) NSInteger asyncThreadCount;

+ (instancetype)manager;

- (XTask *)addDownloadMaskWithURL:(NSString *)urlString filePath:(NSString *)fileDirectory fileName:(NSString *)fileName;

//删除任务 一个或多个
- (void)deleteTasks:(NSArray *)tasks;

//app被杀掉时存储当前下载信息
- (void)saveTasksData;
//启动时加载上次未完成的下载任务
- (void)initTasksData;

@end
