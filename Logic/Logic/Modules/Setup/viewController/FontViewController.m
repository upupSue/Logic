//
//  FontViewController.m
//  Logic
//
//  Created by 方琼蔚 on 16/12/22.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import "FontViewController.h"
#import "Configure.h"

@interface FontViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FontViewController
{
    NSMutableDictionary *fontNames;
    NSArray *familyNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    fontNames = [@{} mutableCopy];
    familyNames = [[UIFont familyNames] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    for (NSString *familyName in familyNames) {
        fontNames[familyName] = [UIFont fontNamesForFamilyName:familyName];
    }
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)recoverDefault:(id)sender
{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:@"确认要还原成默认字体吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertVc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [Configure sharedConfigure].fontName = @"Hiragino Sans";
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return fontNames.allValues.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fontNames[familyNames[section]] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fontCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fontCell"];
    }
    cell.textLabel.text = fontNames[familyNames[indexPath.section]][indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:fontNames[familyNames[indexPath.section]][indexPath.row] size:[Configure sharedConfigure].fontSize];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [Configure sharedConfigure].fontName = fontNames[familyNames[indexPath.section]][indexPath.row];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
