//
//  HomeTableViewController.m
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import "HomeTableViewController.h"
#import "HomeTableViewCell.h"
#import "EditViewController.h"
#import "Item.h"
#import "FileManager.h"
#import "PathUtils.h"
#import "Configure.h"
#import "SetupViewController.h"
#import "CommonUseViewController.h"
#import "ImportViewController.h"
#import "GroupTableViewCell.h"

#define SideMenu_x 250
#define SideMenu_Width 250

static NSString *cellIdentifier = @"homeTableViewCell";
static NSString *groupcellIdentifier = @"groupTableViewCell";

@interface HomeTableViewController ()<UITextFieldDelegate>{
    NSMutableArray *dataArray;
    BOOL needReload;
    NSString *searchWord;
    Item *root;
}

@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (strong, nonatomic) IBOutlet UIView *rightMenu;
@property (weak, nonatomic) IBOutlet UIView *leftMenu;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstant;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *groupTableView;
@property (nonatomic,assign) FileManager *fm;
@property (nonatomic,copy) Item *parent;
@property (nonatomic,assign) CGPoint offset;
@property (nonatomic,assign) BOOL flag;

@end


@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"笔记";
    _fm = [FileManager sharedManager];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    self.groupTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    if ([self.groupTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.groupTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.groupTableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.groupTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [_searchField setValue: THIRD_FONTCOLOR forKeyPath:@"_placeholderLabel.textColor"];
    _searchField.layer.cornerRadius=4;
    _searchField.delegate=self;
    
    UIView *addnoteView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    addnoteView.backgroundColor=THIRD_BGCOLOR;
    UIButton *addbtn=[[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-36)/2, (100-36)/2, 36, 36)];
    [addbtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [addnoteView addSubview:addbtn];
    _tableView.tableHeaderView=addnoteView;
    needReload = YES;
    [self reload];
}

-(void)viewWillAppear:(BOOL)animated{
    [self reload];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)reload
{
    if (needReload == NO) {
        return;
    }
    needReload = NO;
    [_fm createCloudWorkspace];
    [_fm createLocalWorkspace];
    [self listNoteWithSortOption:[Configure sharedConfigure].sortOption];
    if (![[NSFileManager defaultManager] fileExistsAtPath:_fm.currentItem.fullPath]) {
        _fm.currentItem = nil;
    }
}

- (void)listNoteWithSortOption:(NSInteger)sortOption
{
    NSPredicate *pre = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        Item *i = evaluatedObject;
        if (i.type == FileTypeText) {
            return YES;
        }
        return NO;
    }];
    Item *local = _fm.local;
    Item *cloud = _fm.cloud;
    NSArray *localArray = nil;
    NSArray *cloudArray = nil;
    NSMutableArray *arr = [NSMutableArray array];
    if (searchWord.length == 0) {
        localArray = [local.items filteredArrayUsingPredicate:pre];
        cloudArray = [cloud.items filteredArrayUsingPredicate:pre];
    }else {
        localArray = [[local searchResult:searchWord] filteredArrayUsingPredicate:pre];
        cloudArray = [[cloud searchResult:searchWord] filteredArrayUsingPredicate:pre];
    }
    [arr addObjectsFromArray:localArray];
    [arr addObjectsFromArray:cloudArray];
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
        dataArray = [NSMutableArray array];
        for (Item *i in sortedArr) {
            NSDate *date = [_fm attributeOfPath:i.fullPath][NSFileModificationDate];
            if (last == nil || ![last[@"date"] isEqualToString:date.date]) {
                last = @{@"date":date.date,@"items":[@[] mutableCopy]};
                [dataArray addObject:last];
            }
            [last[@"items"] addObject:i];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            stopLoadingAnimationOnParent(self.view);
            if (_fm.currentItem == nil) {
                _fm.currentItem = [dataArray.firstObject[@"items"] firstObject];
            }
            [self.tableView reloadData];
        });
    });
}


#pragma mark - 添加笔记

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_tableView == scrollView) {
        CGFloat yOffset = scrollView.contentOffset.y;
        if (yOffset <-120) {
            [self addnote];
        }
    }
}

-(void)addnote{
    needReload = YES;
    if ([Configure sharedConfigure].defaultParent == nil) {
        [Configure sharedConfigure].defaultParent = _fm.local;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[Configure sharedConfigure].defaultParent.fullPath]) {
        [Configure sharedConfigure].defaultParent = _fm.local;
    }
    _parent = [Configure sharedConfigure].defaultParent;
    NSString *name = @"1";
    if (name.length == 0) {
        name = ZHLS(@"Untitled");
    }
    name = [name stringByAppendingString:@".md"];
    
    NSString *path = name;
    if (!_parent.root) {
        path = [_parent.path stringByAppendingPathComponent:name];
    }
    Item *i = [[Item alloc]init];
    i.path = path;
    i.open = YES;
    i.cloud = _parent.cloud;
    if ([self.parent.items containsObject:i]) {
        
    }
    NSString *ret = [[FileManager sharedManager] createFile:i.fullPath Content:[NSData data]];
    if (ret.length == 0) {
        showToast(ZHLS(@"DuplicateError"));
        return;
    }
    NSString *prePath = i.cloud ? cloudWorkspace() : localWorkspace();
    i.path = [ret stringByReplacingOccurrencesOfString:prePath withString:@""];
    [_parent addChild:i];
    _fm.currentItem = i;
    EditViewController *vc=[[EditViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 显示侧边栏

- (IBAction)moveToRightSide:(id)sender {
    [self animateHomeViewToSide:CGRectMake(SideMenu_x,0,SCREEN_WIDTH,SCREEN_HEIGHT) menu:_leftMenu rect:CGRectMake(0, 0, SideMenu_Width, SCREEN_HEIGHT)];
}

- (IBAction)moveToLeftSide:(id)sender {
    [self animateHomeViewToSide:CGRectMake(-SideMenu_x,0,SCREEN_WIDTH,SCREEN_HEIGHT) menu:_rightMenu rect:CGRectMake(SCREEN_WIDTH-SideMenu_Width, 0, SideMenu_Width, SCREEN_HEIGHT)];
}

- (void)animateHomeViewToSide:(CGRect)newViewRect menu:(UIView *)menu rect:(CGRect)viewrect{
    [UIView animateWithDuration:0.2
                     animations:^{
                         _centerView.frame = newViewRect;
                         menu.frame=viewrect;
                     }
                     completion:^(BOOL finished){
                         UIControl *overView = [[UIControl alloc] init];
                         overView.tag = 10086;
                         overView.backgroundColor = [UIColor clearColor];//放置一个透明的View在Home最上方
                         overView.frame = _centerView.frame;
                         [overView addTarget:self action:@selector(restoreViewLocation) forControlEvents:UIControlEventTouchDown];
                         [[[UIApplication sharedApplication] keyWindow] addSubview:overView];
                     }];
}

- (void)restoreViewLocation{
    [UIView animateWithDuration:0.3
                     animations:^{
                         _centerView.frame = CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
                         _rightMenu.frame=CGRectMake(SCREEN_WIDTH, 0,SideMenu_Width,SCREEN_HEIGHT);
                         _leftMenu.frame=CGRectMake(-SideMenu_x, 0,SideMenu_Width,SCREEN_HEIGHT);
                     }
                     completion:^(BOOL finished){
                         UIControl *overView = (UIControl *)[[[UIApplication sharedApplication] keyWindow] viewWithTag:10086];
                         [overView removeFromSuperview];
                     }];
}


- (IBAction)setEdit:(id)sender {
    SetupViewController *vc=[[SetupViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)setCommon:(id)sender {
    CommonUseViewController *vc=[[CommonUseViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)importAndExport:(id)sender {
    ImportViewController *vc=[[ImportViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{

}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    searchWord = _searchField.text;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [_searchField resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView.tag==100){
        return dataArray.count;
    }
    else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView.tag==100){
        return [dataArray[section][@"items"] count];
    }
    else{
        return dataArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.tag==100){
        return 190.f;
    }
    else{
        return 90.f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView.tag==100){
        HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"HomeTableViewCell" owner:self options:nil][0];
        }
        
        Item *item = dataArray[indexPath.section][@"items"][indexPath.row];
        cell.item = item;
        return cell;
    }
    else{
        GroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"GroupTableViewCell" owner:self options:nil][0];
        }
        
        Item *item = dataArray[indexPath.section][@"items"][indexPath.row];
        cell.item = item;
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.tag==100){
        return YES;
    }
    else{
        return NO;
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView.tag==100){
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"      " handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:@"确认要删除吗？" preferredStyle:UIAlertControllerStyleAlert];
            [alertVc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
            [alertVc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                Item *i=dataArray[indexPath.section][@"items"][indexPath.row];
                [i removeFromParent];
                [_fm deleteFile:i.fullPath];
                [dataArray[indexPath.section][@"items"] removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }]];
            [self presentViewController:alertVc animated:YES completion:nil];
            NSLog(@"%ld%ld",(long)indexPath.section,(long)indexPath.section);
        }];
        
        deleteAction.backgroundColor = FOURTH_BGCOLOR;
        UITableViewRowAction *collectAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"      " handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        }];
        collectAction.backgroundColor = THEME_BGCOLOR;
        UITableViewRowAction *shareAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"      " handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        }];
        shareAction.backgroundColor = THEME_BGCOLOR;
        return @[deleteAction, collectAction,shareAction];
    }
    else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.tag==100){
        Item *i = dataArray[indexPath.section][@"items"][indexPath.row];
        _fm.currentItem = i;
        needReload = YES;
        EditViewController *vc=[[EditViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        return;
    }
}


@end
