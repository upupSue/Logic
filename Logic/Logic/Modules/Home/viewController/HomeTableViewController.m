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

@interface HomeTableViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *rightMenu;
@property (weak, nonatomic) IBOutlet UIView *leftMenu;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (nonatomic,assign)  FileManager         *fm;
@property (nonatomic,copy) Item *parent;


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

}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [_searchField resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 190.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"HomeTableViewCell" owner:self options:nil][0];
    }

    cell.contentLabel.text=@"CFD";
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




@end
