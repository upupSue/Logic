//
//  TrashViewController.m
//  Logic
//
//  Created by 方琼蔚 on 16/12/23.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import "TrashViewController.h"
#import "HomeTableViewCell.h"
#import "Item.h"
#import "FileManager.h"
#import "Configure.h"
#import "PathUtils.h"

static NSString *cellIdentifier = @"homeTableViewCell";

@interface TrashViewController (){
    NSMutableArray *trashArray;
}

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,assign) FileManager *fm;
@property (nonatomic,copy) Item *root;

@end

@implementation TrashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _fm = [FileManager sharedManager];
    self.tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
    if ([self.tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableview respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableview setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    [_fm createTrashWorkspace];
    _root = _fm.trash;
    [self loadFile];
}

- (void)loadFile
{
    NSPredicate *preNote = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        Item *i = evaluatedObject;
        if (i.type == FileTypeText) {
            return YES;
        }
        return NO;
    }];
    NSArray *noteArray = nil;
    noteArray = [_root.items filteredArrayUsingPredicate:preNote];
    [self listNoteWithSortOption:[Configure sharedConfigure].sortOption arr:noteArray];
}


- (void)listNoteWithSortOption:(NSInteger)sortOption arr:(NSArray *)arr
{
    beginLoadingAnimationOnParent(ZHLS(@"Loading"), self.view);
    dispatch_async(dispatch_queue_create("loading", DISPATCH_QUEUE_CONCURRENT), ^{
        NSArray *sortedArr = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            Item *item1 = obj1;
            Item *item2 = obj2;
            NSDate *date1 = [_fm attributeOfPath:item1.fullPath][NSFileModificationDate];
            NSDate *date2 = [_fm attributeOfPath:item2.fullPath][NSFileModificationDate];
            return [date2 compare:date1];
        }];
        NSDictionary *last = nil;
        trashArray = [NSMutableArray array];
        for (Item *i in sortedArr) {
            NSString* fullPath=[trashWorkspace() stringByAppendingPathComponent:i.path];
            NSDate *date = [_fm attributeOfPath:fullPath][NSFileModificationDate];
            if (last == nil || ![last[@"date"] isEqualToString:date.date]) {
                last = @{@"date":date.date,@"items":[@[] mutableCopy]};
                [trashArray addObject:last];
            }
            [last[@"items"] addObject:i];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            stopLoadingAnimationOnParent(self.view);
            if (_fm.currentItem == nil) {
                _fm.currentItem = [trashArray.firstObject[@"items"] firstObject];
            }
            [self.tableview reloadData];
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return trashArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [trashArray[section][@"items"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 190.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"HomeTableViewCell" owner:self options:nil][0];
    }
        
    Item *item = trashArray[indexPath.section][@"items"][indexPath.row];
    cell.item = item;
    cell.isTrash=YES;
    return cell;

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"      " handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:@"确认要清除吗？" preferredStyle:UIAlertControllerStyleAlert];
        [alertVc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
        [alertVc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            Item *i=trashArray[indexPath.section][@"items"][indexPath.row];
            [i removeFromParent];
            NSString *fullPath=[trashWorkspace() stringByAppendingPathComponent:i.path];
            [_fm deleteFile:fullPath];
            [trashArray[indexPath.section][@"items"] removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }]];
        [self presentViewController:alertVc animated:YES completion:nil];
        NSLog(@"%ld%ld",(long)indexPath.section,(long)indexPath.section);
    }];
    deleteAction.backgroundColor = FOURTH_BGCOLOR;
    
    UITableViewRowAction *collectAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"      " handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
    }];
    collectAction.backgroundColor = THEME_BGCOLOR;

    return @[deleteAction, collectAction];
}

- (IBAction)goback:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
