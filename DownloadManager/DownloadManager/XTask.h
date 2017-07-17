//
//  XTask.h
//  多任务下载
//
//  Created by mgfjx on 2017/7/14.
//  Copyright © 2017年 xintong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XTask;

#define DocumentPath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
#define XTASKFINISHDOWNLOAD @"XTASKFINISHDOWNLOAD"
#define XTASKDELETED @"XTASKDELETED"

typedef NS_ENUM(NSInteger, XDownloadTaskState){
    
    XDownloadTaskStateNotRunning = 0,
    XDownloadTaskStateRunning,
    XDownloadTaskStatePasue,
    XDownloadTaskStateDone,
    XDownloadTaskStateFaild
    
};

@protocol XTaskDelegate <NSObject>
@optional
- (void)onTaskBeginDownload:(nonnull XTask *)task;
- (void)onTaskModelDidFinished:(nonnull XTask *)taskModel;
- (void)onTaskModelDidPause:(nonnull XTask *)taskModel;
- (void)onTaskModelDidRestart:(nonnull XTask *)taskModel;
- (void)onGetDownloadSpeed:(CGFloat)speed;
- (void)onGetDownloadReceivedData:(int64_t)recrived totalData:(int64_t)total;

@end

@interface XTask : NSObject

// 下载地址
@property (nonatomic, strong) NSString * _Nonnull downloadUrl;
@property (nonatomic, strong) NSString * _Nullable fileName ;
// 下载百分比
@property (nonatomic, assign, readonly) CGFloat percentage ;
// 总大小：字节
@property (nonatomic, assign, readonly) int64_t totalSize;
// 速度
@property (nonatomic, assign, readonly) CGFloat speed ;
// 状态
@property (nonatomic, assign, readonly) XDownloadTaskState state;

@property (nonatomic, weak) id<XTaskDelegate> _Nullable delegate;

//相对路径：需要拼接
@property (nonatomic, strong) NSString * _Nullable relativePath;

- (void)startTask;
- (void)pasueTask;
- (void)restartTask;
- (void)deleteTask;

- (NSDictionary  * _Nonnull )getMianInfo ;

- (instancetype _Nonnull)initWithDownloadURL:(NSString * _Nonnull)url localPath:(NSString * _Nullable)fileDirectory fileName:(NSString * _Nullable)fileName ;

- (instancetype _Nonnull )initWithInfoDict:(NSDictionary *_Nonnull)info ;

@end
