//
//  XTaskManager.m
//  多任务下载
//
//  Created by mgfjx on 2017/7/14.
//  Copyright © 2017年 xintong. All rights reserved.
//

#import "XTaskManager.h"
#import "XTask.h"

#define PLISTPATH [DocumentPath stringByAppendingPathComponent:@"XTaskManager.plist"]

@interface XTaskManager (){
    UIWindow *infoWindow;
}

@end

@implementation XTaskManager

/*
 * 单例
 */
+ (instancetype)manager{
    
    static XTaskManager *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[super allocWithZone:NULL] init];
        [[NSNotificationCenter defaultCenter] addObserver:singleton selector:@selector(taskDone:) name:XTASKFINISHDOWNLOAD object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:singleton selector:@selector(taskDeleted:) name:XTASKDELETED object:nil];
    });
    return singleton;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [XTaskManager manager];
}

- (id)copyWithZone:(NSZone *)zone{
    return [XTaskManager manager];
}

/*
 * 懒加载
 */
- (NSMutableArray *)tasksList{
    if (!_tasksList) {
        _tasksList = [NSMutableArray array];
    }
    return _tasksList;
}

- (XTask *)addDownloadMaskWithURL:(NSString *)urlString filePath:(NSString *)fileDirectory fileName:(NSString *)fileName {
    BOOL isExist = [self isTaskExist:urlString];
    if (isExist) {
        [self indicatorInfo:@"任务已存在"];
        return nil;
    }
    
    XTask *task = [[XTask alloc] initWithDownloadURL:urlString localPath:fileDirectory fileName:fileName];
    [task startTask];
    [self.tasksList addObject:task];
    [self indicatorInfo:@"已添加到任务管理器"];
    return task;
}

- (void)deleteTasks:(NSArray *)tasks{
    
    if (!tasks || tasks.count == 0) {
        return;
    }
    for (XTask *task in tasks) {
        
        if ([self.tasksList containsObject:task]) {
            [task deleteTask];
            [self.tasksList removeObject:task];
        }
        
    }
    
}

#pragma mark - check task exist or not
- (BOOL)isTaskExist:(NSString *)urlString{
    
    for (XTask *task in self.tasksList) {
        if ([task.downloadUrl isEqualToString:urlString]) {
            return YES;
        }
    }
    return NO;
}

- (void)indicatorInfo:(NSString *)message{
    
    if (infoWindow) {
        return;
    }
    
    CGRect oldFrame = CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, 20);
    CGRect newFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20);
    
    UIWindow *indicatorWin = [[UIWindow alloc] initWithFrame:newFrame];
    indicatorWin.windowLevel = UIWindowLevelAlert;
    [indicatorWin makeKeyAndVisible];
    
    infoWindow = indicatorWin;
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = oldFrame;
    label.backgroundColor = [UIColor colorWithRed:0.124 green:0.783 blue:0.325 alpha:1.000];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    label.text = message;
    [indicatorWin addSubview:label];
    
    CGFloat duration = 0.25;
    
    [UIView animateWithDuration:duration animations:^{
        label.frame = newFrame;
    } completion:^(BOOL finished) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [NSThread sleepForTimeInterval:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:duration animations:^{
                    label.frame = oldFrame;
                } completion:^(BOOL finished) {
                    [label removeFromSuperview];
                    [infoWindow resignKeyWindow];
                    infoWindow = nil;
                }];
            });
        });
        
    }];
    
}

#pragma mark - save task data
- (void)saveTasksData{
    
    NSMutableArray *array = [NSMutableArray array];
    if (![[NSFileManager defaultManager] fileExistsAtPath:PLISTPATH]) {
        [[NSFileManager defaultManager] createFileAtPath:PLISTPATH contents:nil attributes:nil];
    }
    for (XTask *task in self.tasksList) {
        [array addObject:[task getMianInfo]];
    }
    [array writeToFile:PLISTPATH atomically:YES];
    
}

#pragma mark - initail task data
- (void)initTasksData{
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:PLISTPATH]) {
        return;
    }
    NSArray *array = [NSArray arrayWithContentsOfFile:PLISTPATH];
    for (NSDictionary *info in array) {
        XTask *task = [[XTask alloc] initWithInfoDict:info];
        [[XTaskManager manager].tasksList addObject:task];
        NSLog(@"url: %@", task.downloadUrl);
    }
    [[NSFileManager defaultManager] removeItemAtPath:PLISTPATH error:nil];
    
}

- (void)taskDone:(NSNotification *)notification {
    XTask *task = (XTask *)notification.object;
    if ([self.tasksList containsObject:task]) {
        [self.tasksList removeObject:task];
    }
}

- (void)taskDeleted:(NSNotification *)notification {
    [self taskDone:notification];
}

@end
