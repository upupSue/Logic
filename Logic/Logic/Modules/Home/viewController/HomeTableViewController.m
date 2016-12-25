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
#import "SetupViewController.h"
#import "CommonUseViewController.h"
#import "ImportViewController.h"
#import "GroupTableViewCell.h"
#import "TrashViewController.h"
#import "NewGroupView.h"
#import "Item.h"
#import "FileManager.h"
#import "PathUtils.h"
#import "Configure.h"
#import "UIImageView+WebCache.h"


static NSString *cellIdentifier = @"homeTableViewCell";
static NSString *groupcellIdentifier = @"groupTableViewCell";

@interface HomeTableViewController ()<UITextFieldDelegate>{
    NSMutableArray *noteArray;
    NSMutableArray *fileArray;
    NSMutableArray *colorArray;
    NSMutableArray *imageList;

    BOOL needReload;
    NSString *searchWord;
    NewGroupView *newGroupView;
}

@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (strong, nonatomic) IBOutlet UIView *rightMenu;
@property (weak, nonatomic) IBOutlet UIView *leftMenu;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *groupTableView;
@property (nonatomic,assign) FileManager *fm;
@property (nonatomic,copy) Item *root;

@property (weak, nonatomic) IBOutlet UIImageView *testImg;
@end


@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"笔记";
    _fm = [FileManager sharedManager];
    _root = _fm.local;
    needReload = YES;
    
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
    
    UIView *addgroupView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 250, 90)];
    addgroupView.backgroundColor=THEME_BGCOLOR;
    UIButton *addgroupbtn=[[UIButton alloc]initWithFrame:CGRectMake(15, 0, 220, 80)];
    [addgroupbtn setImage:[UIImage imageNamed:@"addgroup"] forState:UIControlStateNormal];
    [addgroupbtn addTarget:self action:@selector(addGroup) forControlEvents:UIControlEventTouchUpInside];
    [addgroupView addSubview:addgroupbtn];
    _groupTableView.tableFooterView=addgroupView;
    
    [self loadfolderColor];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
    [self loadFile];
    [self loadImage];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadFile
{
    if (needReload == NO) {
        return;
    }
    needReload = NO;
    fileArray = [NSMutableArray array];
    NSMutableArray *arr=[NSMutableArray array];
    NSPredicate *preFolder = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        Item *i = evaluatedObject;
        if (i.type == FileTypeFolder) {
            return YES;
        }
        return NO;
    }];
    arr = _fm.local.itemsCanReach.mutableCopy;
    fileArray=[arr filteredArrayUsingPredicate:preFolder];
    
    
    
    NSPredicate *preNote = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        Item *i = evaluatedObject;
        if (i.type == FileTypeText) {
            return YES;
        }
        return NO;
    }];
    Item *local = _root;
    NSArray *localArray = nil;
    if (searchWord.length == 0) {
        localArray = [local.items filteredArrayUsingPredicate:preNote];
    }else {
        localArray = [[local searchResult:searchWord] filteredArrayUsingPredicate:preNote];
    }
    [self listNoteWithSortOption:[Configure sharedConfigure].sortOption arr:localArray];
    if (![[NSFileManager defaultManager] fileExistsAtPath:_fm.currentItem.fullPath]) {
        _fm.currentItem = nil;
    }
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
        noteArray = [NSMutableArray array];
        for (Item *i in sortedArr) {
            NSDate *date = [_fm attributeOfPath:i.fullPath][NSFileModificationDate];
            if (last == nil || ![last[@"date"] isEqualToString:date.date]) {
                last = @{@"date":date.date,@"items":[@[] mutableCopy]};
                [noteArray addObject:last];
            }
            [last[@"items"] addObject:i];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            stopLoadingAnimationOnParent(self.view);
            if (_fm.currentItem == nil) {
                _fm.currentItem = [noteArray.firstObject[@"items"] firstObject];
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
    
    EditViewController *vc=[[EditViewController alloc]init];
    vc.parentItem=_root;
    _fm.currentItem = nil;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 显示侧边栏

- (IBAction)moveToRightSide:(id)sender {
    [self animateHomeViewToSide:CGRectMake(250,0,SCREEN_WIDTH,SCREEN_HEIGHT) menu:_leftMenu rect:CGRectMake(0, 0, 250, SCREEN_HEIGHT)];
}

- (IBAction)moveToLeftSide:(id)sender {
    [self animateHomeViewToSide:CGRectMake(-250,0,SCREEN_WIDTH,SCREEN_HEIGHT) menu:_rightMenu rect:CGRectMake(SCREEN_WIDTH-250, 0, 250, SCREEN_HEIGHT)];
}

- (IBAction)moveToTrash:(id)sender {
    TrashViewController *vc =[[TrashViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
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
                         _rightMenu.frame=CGRectMake(SCREEN_WIDTH, 0,250,SCREEN_HEIGHT);
                         _leftMenu.frame=CGRectMake(-250, 0,250,SCREEN_HEIGHT);
                     }
                     completion:^(BOOL finished){
                         UIControl *overView = (UIControl *)[[[UIApplication sharedApplication] keyWindow] viewWithTag:10086];
                         [overView removeFromSuperview];
                     }];
}


- (IBAction)setEdit:(id)sender {
    SetupViewController *vc=[[SetupViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)setCommon:(id)sender {
    CommonUseViewController *vc=[[CommonUseViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)importAndExport:(id)sender {
    ImportViewController *vc=[[ImportViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{

}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    searchWord = _searchField.text;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [_searchField resignFirstResponder];
    [newGroupView.nameTxtField resignFirstResponder];
    [newGroupView.tagTxtField resignFirstResponder];
}

-(void)addGroup{
    newGroupView=[[NewGroupView alloc]initWithSureBlock:^{
        needReload = YES;
        
        NSString *name = newGroupView.grpName;
        if (name.length == 0) {
            name = ZHLS(@"UntitledFolder");
        }
        NSString *path = name;
        if (!_root.root) {
            path = [_root.path stringByAppendingPathComponent:name];
        }
        Item *i = [[Item alloc]init];
        i.path = path;
        i.open = YES;
        i.cloud = _root.cloud;
        if ([self.root.items containsObject:i]) {
            
        }
        NSString *ret = [[FileManager sharedManager] createFolder:i.fullPath];
        
        if (ret.length == 0) {
            showToast(ZHLS(@"DuplicateError"));
            return;
        }
        
        NSString *prePath = i.cloud ? cloudWorkspace() : localWorkspace();
        i.path = [ret stringByReplacingOccurrencesOfString:prePath withString:@""];
        
        [_root addChild:i];
        [self insertfolderColor:newGroupView.grpColor name:newGroupView.grpName];
        [self loadFile];
//        [self.groupTableView reloadData];
    }];
    [newGroupView showAtView:self.view];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView.tag==100){
        return noteArray.count;
    }
    else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView.tag==100){
        return [noteArray[section][@"items"] count];
    }
    else{
        return fileArray.count+1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.tag==100){
        Item *item = noteArray[indexPath.section][@"items"][indexPath.row];
        NSMutableArray *imgArr=[NSMutableArray array];
        for(NSDictionary *dic in imageList){
            NSString *noteName=dic[@"noteName"];
            if([noteName isEqualToString:item.name]){
                [imgArr addObject:dic];
            }
        }
        if(imgArr.count==0){
            return 95.f;
        }
        return 195.f;
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
        Item *item = noteArray[indexPath.section][@"items"][indexPath.row];
        cell.item = item;
        NSMutableArray *imgArr=[NSMutableArray array];
        for(NSDictionary *dic in imageList){
            NSString *noteName=dic[@"noteName"];
            if([noteName isEqualToString:item.name]){
                [imgArr addObject:dic];
            }
        }
        switch (imgArr.count) {
            case 0:
                cell.imgView.hidden=YES;

                break;
            case 1:
                [cell.img1 sd_setImageWithURL:[NSURL URLWithString:imgArr[0][@"imageUrl"]] placeholderImage:[UIImage imageNamed:@""]];
                break;
            case 2:
                [cell.img1 sd_setImageWithURL:[NSURL URLWithString:imgArr[0][@"imageUrl"]] placeholderImage:[UIImage imageNamed:@""]];
                [cell.img2 sd_setImageWithURL:[NSURL URLWithString:imgArr[1][@"imageUrl"]] placeholderImage:[UIImage imageNamed:@""]];
                break;
            case 3:
                [cell.img1 sd_setImageWithURL:[NSURL URLWithString:imgArr[0][@"imageUrl"]] placeholderImage:[UIImage imageNamed:@""]];
                [cell.img2 sd_setImageWithURL:[NSURL URLWithString:imgArr[1][@"imageUrl"]] placeholderImage:[UIImage imageNamed:@""]];
                [cell.img3 sd_setImageWithURL:[NSURL URLWithString:imgArr[2][@"imageUrl"]] placeholderImage:[UIImage imageNamed:@""]];
                break;
            default:
                break;
        }
        return cell;
    }
    else{
        GroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"GroupTableViewCell" owner:self options:nil][0];
        }
        if(indexPath.row==0){
            cell.taglabel.text=@"全部笔记";
        }
        else{
            Item *item = fileArray[indexPath.row-1];
            cell.item = item;
            cell.taglabel.text=[item.path componentsSeparatedByString:@"/"].lastObject;
            cell.tagView.backgroundColor=[UIColor colorWithRGBString:colorArray.count <indexPath.row+1 ?  @"33898e": colorArray[indexPath.row][@"folderColor"]];
        }

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
                Item *i=noteArray[indexPath.section][@"items"][indexPath.row];
                [i removeFromParent];
                [_fm moveFiletoTrash:i];
                [noteArray[indexPath.section][@"items"] removeObjectAtIndex:indexPath.row];
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
        Item *i = noteArray[indexPath.section][@"items"][indexPath.row];
        _fm.currentItem = i;
        needReload = YES;
        EditViewController *vc=[[EditViewController alloc]init];
        vc.isPreView=0;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        if(indexPath.row==0){
            needReload=YES;
            _root = _fm.local;
            [self loadFile];
            return;
        }
        NSArray *children;
        _root = fileArray[indexPath.row-1];
        Item *i = fileArray[indexPath.row-1];
        i.open=YES;
        children = [i itemsCanReach];
        [self listNoteWithSortOption:[Configure sharedConfigure].sortOption arr:children];
        [_tableView reloadData];
        return;
    }
}

-(void)loadfolderColor{
    colorArray = [[NSMutableArray alloc]init];
    [HandlerBusiness ServiceWithApicode:ApiCodeGetFolderColor Parameters:nil Success:^(id data , id msg){
        colorArray = data;
        [_groupTableView reloadData];
    }Failed:^(NSInteger code ,id errorMsg){
        NSLog(@"请求失败---%@", errorMsg);
    }Complete:^{

    }];
}

-(void)loadImage{
    imageList = [[NSMutableArray alloc]init];
    [HandlerBusiness ServiceWithApicode:ApiCodeGetImage Parameters:nil Success:^(id data , id msg){
        imageList = data;
        [_tableView reloadData];
    }Failed:^(NSInteger code ,id errorMsg){
        NSLog(@"请求失败---%@", errorMsg);
    }Complete:^{
        
    }];
}

-(void)insertfolderColor:(NSString *)color name:(NSString*)folderName{
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc]init];
    [parameter setObject:folderName forKey:@"folderName"];
    [parameter setObject:color forKey:@"folderColor"];
    
    [HandlerBusiness ServiceWithApicode:ApiCodeInsertFolderColor Parameters:parameter Success:^(id data , id msg){
        [_groupTableView reloadData];
    }Failed:^(NSInteger code ,id errorMsg){
        [self loadfolderColor];
    }Complete:^{
        
    }];
}

@end
