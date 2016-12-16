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


#define SideMenu_x 250
#define SideMenu_Width 250

static NSString *cellIdentifier = @"homeTableViewCell";

@interface HomeTableViewController ()<UITextFieldDelegate>{
    NSMutableArray *dataArray;
    BOOL needReload;
    NSString *searchWord;

}

@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *rightMenu;
@property (weak, nonatomic) IBOutlet UIView *leftMenu;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (nonatomic,assign)  FileManager *fm;
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
    [_searchField setValue: THIRD_FONTCOLOR forKeyPath:@"_placeholderLabel.textColor"];
    _searchField.layer.cornerRadius=4;
    _searchField.delegate=self;
    
    UIView *addnoteView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    addnoteView.backgroundColor=THIRD_BGCOLOR;
    UIButton *addbtn=[[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-36)/2, (100-36)/2, 36, 36)];
    [addbtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [addbtn addTarget:self action:@selector(addnote) forControlEvents:UIControlEventTouchUpInside];
    [addnoteView addSubview:addbtn];
    _tableView.tableHeaderView=addnoteView;
    needReload = YES;
    [self reload];
}

-(void)viewWillAppear:(BOOL)animated{
    [self reload];
    [self.navigationController setNavigationBarHidden:YES];
    self.tableView.contentOffset=CGPointMake(-20, 0 );
    [_tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.tableView removeObserver:self forKeyPath:@"contentOffset" context:nil];
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


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSLog(@"%f",_tableView.contentOffset.y);
    if(_tableView.contentOffset.y<-20.){
        self.tableView.contentInset=UIEdgeInsetsMake(120, 0, 0, 0);
    }
    if(_tableView.contentOffset.y>-20.){
        self.tableView.contentInset=UIEdgeInsetsMake(20, 0, 0, 0);
    }
}

-(void)addnote{
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

- (IBAction)moveToRightSide:(id)sender {
    [self animateHomeViewToSide:CGRectMake(SideMenu_x,0,SCREEN_WIDTH,SCREEN_HEIGHT) menu:_leftMenu rect:CGRectMake(0, 0, SideMenu_Width, SCREEN_HEIGHT)];
}
- (IBAction)moveToLeftSide:(id)sender {
    [self animateHomeViewToSide:CGRectMake(-SideMenu_x,0,SCREEN_WIDTH,SCREEN_HEIGHT) menu:_rightMenu rect:CGRectMake(SCREEN_WIDTH-SideMenu_Width, 0, SideMenu_Width, SCREEN_HEIGHT)];
}

// animate home view to side rect
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

// restore view location
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
    return dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataArray[section][@"items"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 190.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"HomeTableViewCell" owner:self options:nil][0];
    }
    
    Item *item = dataArray[indexPath.section][@"items"][indexPath.row];
    cell.item = item;    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"      " handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
    }];
    deleteAction.backgroundColor = FOURTH_BGCOLOR;
    UITableViewRowAction *collectAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"      " handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
    }];
    collectAction.backgroundColor = THEME_BGCOLOR;
    UITableViewRowAction *shareAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"      " handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
    }];
    shareAction.backgroundColor = THEME_BGCOLOR;
    return @[deleteAction, collectAction,shareAction];
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Item *i = dataArray[indexPath.section][@"items"][indexPath.row];
    _fm.currentItem = i;
    EditViewController *vc=[[EditViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
