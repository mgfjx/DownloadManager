//
//  MultiTaskDownloadCell.h
//  多任务下载
//
//  Created by 谢小龙 on 16/5/31.
//  Copyright © 2016年 xintong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTask.h"

@protocol MultiTaskDownloadCellDelegate <NSObject>

- (void)onTaskFinished:(NSInteger)tag;

@end

@interface MultiTaskDownloadCell : UITableViewCell

@property (nonatomic, strong) XTask *downloadTask;

@property (nonatomic, weak) id<MultiTaskDownloadCellDelegate> delegate;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subLable;

@end
