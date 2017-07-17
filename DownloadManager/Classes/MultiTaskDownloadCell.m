//
//  MultiTaskDownloadCell.m
//  多任务下载
//
//  Created by 谢小龙 on 16/5/31.
//  Copyright © 2016年 xintong. All rights reserved.
//

#import "MultiTaskDownloadCell.h"
#import <MRProgress/MRProgress.h>
#import "UIColor+Hex.h"
#import "XTaskManager.h"

@interface MultiTaskDownloadCell ()<XTaskDelegate>{
    
//    UILabel *speedLabel;
    
}

@property (nonatomic, strong) MRCircularProgressView *progressView;
@property (nonatomic, strong) UIButton *getBtn;

@end

@implementation MultiTaskDownloadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIColor *commonColor = [UIColor colorWithRed:0  green:0.479  blue:0.999 alpha:1];
        
        MRCircularProgressView *progress = [[MRCircularProgressView alloc] init];
        progress.lineWidth = 3;
        progress.mayStop = YES;
        progress.hidden = YES;
        [progress.stopButton addTarget:self action:@selector(progressStop:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:progress];
        _progressView = progress;
        
        UILabel *title = [[UILabel alloc] init];
        title.font = [UIFont systemFontOfSize:17];
        title.textColor = [UIColor blackColor];
        [self.contentView addSubview:title];
        _titleLabel = title;
        
        UILabel *subTitle = [[UILabel alloc] init];
        subTitle.font = [UIFont systemFontOfSize:13];
        subTitle.textColor = [UIColor grayColor];
        [self.contentView addSubview:subTitle];
        _subLable = subTitle;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"获取" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        btn.layer.cornerRadius = 5;
        btn.layer.borderColor = commonColor.CGColor;
        btn.layer.borderWidth = 1.5;
        [btn setTitleColor:commonColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(downloadBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn];
        _getBtn = btn;
        
    }
    return self;
}

- (void)setDownloadTask:(XTask *)downloadTask{
    _downloadTask = downloadTask;
    downloadTask.delegate = self;
    [self setTaskInfo];
}

- (void)setTaskInfo{
    
    if (self.downloadTask.state == XDownloadTaskStatePasue) {
        
    }
    
    if (self.downloadTask.state == XDownloadTaskStateRunning) {
        
    }
    
}

- (void)progressStop:(UIButton *)sender{
    _getBtn.hidden = NO;
    _progressView.hidden = YES;
    _progressView.progress = 0.0;
    [_downloadTask deleteTask];
}

- (void)downloadBtnClicked:(UIButton *)sender{
    
    _getBtn.hidden = YES;
    _progressView.hidden = NO;
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    XTask *task = [[XTaskManager manager] addDownloadMaskWithURL:_subLable.text filePath:path fileName:nil];
    task.delegate = self;
    self.downloadTask = task;
}

- (void)clickControlBtn:(UIButton *)sender{
    
    if (sender.selected) {
        if (self.downloadTask.state == XDownloadTaskStateRunning) {
            [self.downloadTask pasueTask];
        }else{
            [self.downloadTask restartTask];
        }
        
    }else{
        if (self.downloadTask.state == XDownloadTaskStateRunning) {
            [self.downloadTask pasueTask];
        }else{
            [self.downloadTask restartTask];
        }
    }
    
    sender.selected = !sender.selected;
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    _titleLabel.frame = CGRectMake(10, 0, width - 60, height*2/3);
    _subLable.frame = CGRectMake(10, CGRectGetMaxY(_titleLabel.frame), width - 60, height/3);
    _progressView.frame = CGRectMake(width - 60 + (60 - 30)/2.0, (height - 30.0)/2, 30, 30);
    _getBtn.frame = CGRectMake(width - 60 + (60 - 40)/2.0, (height - 25.0)/2, 40, 25);
    
}


#pragma mark - TaskModelDelegate

- (void)onTaskBeginDownload:(nonnull XTask *)task{
    
}

- (void)onGetDownloadSpeed:(CGFloat)speed{
    
//    speedLabel.text = [NSString stringWithFormat:@"%.2fKB/S",speed];
    
}

- (void)onGetDownloadReceivedData:(int64_t)recrived totalData:(int64_t)total{
    
    _progressView.progress = (float)recrived/total;
//    contentLabel.text = [NSString stringWithFormat:@"%.2fm/%.2fm",(float)recrived/1000000,(float)total/1000000];
    
}

- (void)onTaskModelDidFinished:(XTask *)taskModel{
    NSLog(@"onTaskModelDidFinished");
    _getBtn.hidden = NO;
    _progressView.hidden = YES;
    [_getBtn setTitle:@"完成" forState:UIControlStateNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTaskFinished:)]) {
        [self.delegate onTaskFinished:self.tag];
    }
    self.downloadTask = nil;
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

@end
