//
//  XTask.m
//  多任务下载
//
//  Created by mgfjx on 2017/7/14.
//  Copyright © 2017年 xintong. All rights reserved.
//

#import "XTask.h"
#import <objc/runtime.h>

@interface XTask ()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *downloadSession;

@property (nonatomic, strong, readonly) NSString * fullPath;

@property (nonatomic, assign) int64_t speedSizeEveSec;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSURLSessionDataTask * _Nullable task;

@property (nonatomic, assign) int64_t location;

@property (nonatomic, strong) NSOutputStream *outputStream;

@end

@implementation XTask

- (NSString *)fullPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:_relativePath];
}

- (NSDictionary *)getMianInfo {
    [self pasueTask];
    NSDictionary *info = @{
                           @"downloadUrl": self.downloadUrl,
                           @"fileName":self.fileName,
                           @"totalSize":@(self.totalSize),
                           @"relativePath":self.relativePath,
                           @"percentage":@(self.percentage),
                           };
    return info;
}

- (instancetype)initWithInfoDict:(NSDictionary *)info {
    self = [super init];
    if (self) {
        
        _downloadUrl = info[@"downloadUrl"];
        _fileName = info[@"fileName"];
        _totalSize = [info[@"totalSize"] integerValue];
        _relativePath = info[@"relativePath"];
        _percentage = [info[@"percentage"] floatValue];
        _state = XDownloadTaskStatePasue;
        
    }
    return self;
}

- (NSURLSession *)downloadSession{
    
    if (!_downloadSession) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _downloadSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _downloadSession;
}

- (instancetype)initWithDownloadURL:(NSString *)url localPath:(NSString *)fileDirectory fileName:(NSString * _Nullable)fileName {
    self = [super init];
    if (self) {
        _totalSize = 0;
        _speedSizeEveSec = 0;
        if (!fileDirectory) {
            _relativePath = [@"" stringByAppendingPathComponent:NSStringFromClass([self class])];
        }else{
            _relativePath = [fileDirectory substringFromIndex:NSHomeDirectory().length];
        }
        _downloadUrl = url;
        _fileName = fileName;
        
    }
    return self;
}

#pragma mark - 操作任务
- (void)startTask{
    
    if (!self.downloadUrl) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[self.downloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    //设置请求头，用于获取文件信息
    NSMutableURLRequest *headRequest = [NSMutableURLRequest requestWithURL:url];
    headRequest.HTTPMethod = @"HEAD";
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:headRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"thread: %@",[NSThread currentThread]);
        if (error) {
            [self deleteTask];
            return ;
        }
        _totalSize = response.expectedContentLength;
        if (!_fileName) {
            _fileName = response.suggestedFilename;
            _relativePath = [_relativePath stringByAppendingPathComponent:_fileName];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onTaskBeginDownload:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate onTaskBeginDownload:self];
            });
        }
        [self initTaskWith:response.URL];
    }];
    self.task = task;
    
    [self startTimer];
    [task resume];
    
}

- (void)pasueTask{
    
    [self.task cancel];
    _state = XDownloadTaskStatePasue;
    [_timer invalidate];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTaskModelDidPause:)]) {
        [self.delegate onTaskModelDidPause:self];
    }
    NSLog(@"pasueTask");
    
}

- (void)restartTask{
    [self startTask];
    NSLog(@"restartTask");
}

- (void)deleteTask{
    
    [self.task cancel];
    [_timer invalidate];
    BOOL isDelete = [[NSFileManager defaultManager] removeItemAtPath:self.fullPath error:nil];
    NSLog(@"deleteTask:%d",isDelete);
    [[NSNotificationCenter defaultCenter] postNotificationName:XTASKDELETED object:self];
    
}

- (void)initTaskWith:(NSURL *)url{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSData *data = nil;
    BOOL b = [manager fileExistsAtPath:self.fullPath];
    NSLog(@"fullPath: %@", self.fullPath);
    if (b) {
        data = [NSData dataWithContentsOfFile:self.fullPath];
    }else{
        [manager createFileAtPath:self.fullPath contents:nil attributes:nil];
        data = [NSData dataWithContentsOfFile:self.fullPath];
    }
    
    self.location = data.length;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *head = [NSString stringWithFormat:@"bytes=%zd-",self.location];
    [request setValue:head forHTTPHeaderField:@"Range"];
    
    self.task = [self.downloadSession dataTaskWithRequest:request];
    
    //创建并打开写入流
    self.outputStream = [[NSOutputStream alloc] initToFileAtPath:self.fullPath append:YES];
    [self.outputStream open];
    
    [self.task resume];
    
    _state = XDownloadTaskStateRunning;
    
}

- (void)startTimer{
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setupDownloadSpeed) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
}

- (void)setupDownloadSpeed{
    
    _speed = _speedSizeEveSec/1000.0;
//    NSLog(@"网速:%f/s",self.speed);
//    NSLog(@"进度: %f", _percentage);
    _speedSizeEveSec = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onGetDownloadSpeed:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate onGetDownloadSpeed:self.speed];
        });
    }
    
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    if (!error) {
        _state = XDownloadTaskStateDone;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onTaskModelDidFinished:)]) {
            [self.delegate onTaskModelDidFinished:self];
        }
        NSLog(@"视频下载完成");
        [session finishTasksAndInvalidate];//完成任务一定要调用，否则会内存泄露
        [[NSNotificationCenter defaultCenter] postNotificationName:XTASKFINISHDOWNLOAD object:self];
    }else{
        _state = XDownloadTaskStateFaild;
//        [session invalidateAndCancel];
    }
    
    [_timer invalidate];
    
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.outputStream write:data.bytes maxLength:data.length];
    self.location += data.length;
    _speedSizeEveSec += data.length;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onGetDownloadReceivedData:totalData:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate onGetDownloadReceivedData:self.location totalData:_totalSize];
        });
    }
    
}


- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

@end
