//
//  MultiTaskDownloadController.m
//  多任务下载
//
//  Created by 谢小龙 on 16/5/31.
//  Copyright © 2016年 xintong. All rights reserved.
//

#import "MultiTaskDownloadController.h"
#import "XTaskManager.h"
#import "MultiTaskDownloadCell.h"

@interface MultiTaskDownloadController ()<MultiTaskDownloadCellDelegate>{
    NSArray *titles;
    NSArray *urls;
}

@end

@implementation MultiTaskDownloadController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    titles = @[@"m",@"yuenv",@"live-Avril-Lavigne",@"m",@"yuenv",@"live-Avril-Lavigne",@"m",@"yuenv",@"live-Avril-Lavigne",@"m",@"yuenv",@"live-Avril-Lavigne",@"m",@"yuenv",@"live-Avril-Lavigne",@"m",@"yuenv",@"live-Avril-Lavigne",@"m",@"yuenv",@"live-Avril-Lavigne",@"m",@"yuenv",@"live-Avril-Lavigne",@"m",@"yuenv",@"live-Avril-Lavigne",@"m",@"yuenv",@"live-Avril-Lavigne",];
    urls = @[
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/m.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/yuenv.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/live-Avril-Lavigne.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/m.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/yuenv.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/live-Avril-Lavigne.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/m.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/yuenv.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/live-Avril-Lavigne.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/m.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/yuenv.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/live-Avril-Lavigne.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/m.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/yuenv.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/live-Avril-Lavigne.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/m.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/yuenv.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/live-Avril-Lavigne.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/m.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/yuenv.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/live-Avril-Lavigne.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/m.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/yuenv.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/live-Avril-Lavigne.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/m.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/yuenv.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/live-Avril-Lavigne.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/m.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/yuenv.mp4",
             @"https://raw.githubusercontent.com/mgfjxxiexiaolong/DataSource/master/Video/live-Avril-Lavigne.mp4",
             ];
    
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"cell";
    MultiTaskDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    MultiTaskDownloadCell *cell = nil;
    
    if (!cell) {
        cell = [[MultiTaskDownloadCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }

    cell.titleLabel.text = titles[indexPath.row];
    cell.subLable.text = urls[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.tag = indexPath.row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XTask *task = [XTaskManager manager].tasksList[indexPath.row];
    
    [[XTaskManager manager] deleteTasks:@[task]];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)onTaskFinished:(NSInteger)tag{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
    });
    
}

@end
