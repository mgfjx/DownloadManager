//
//  ViewController.m
//  DownloadManager
//
//  Created by mgfjx on 2017/7/17.
//  Copyright © 2017年 XXL. All rights reserved.
//

#import "ViewController.h"
#import "XTaskManager.h"
#import "XTask.h"

#import "MultiTaskDownloadController.h"

@interface ViewController ()<XTaskDelegate,NSURLSessionDelegate>

@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIButton *btn;

@property (nonatomic, strong) NSData *resumeData;

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) XTask *task;

@property (nonatomic, assign) NSInteger location;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.urls = @[
//                  @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/m.mp4",
//                  @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/yuenv.mp4",
//                  @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/live-Avril-Lavigne.mp4",
                  ];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 60, 30);
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn setTitle:@"push" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(pushVC:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(100, 150, 60, 30);
    addBtn.backgroundColor = [UIColor lightGrayColor];
    [addBtn setTitle:@"add" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(downLoadFiles:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
}

- (void)downLoadFiles:(UIButton *)sender{
    
    for (NSString *urlStr in self.urls) {
        NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        
        [[XTaskManager manager] addDownloadMaskWithURL:urlStr filePath:path fileName:nil];
    }
    
}

- (void)pushVC:(id)sender{
    
    MultiTaskDownloadController *vc = [[MultiTaskDownloadController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)onTaskModelDidFinished:(XTask *)taskModel{
    
    self.task = nil;
    
}

@end
