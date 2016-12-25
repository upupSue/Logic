//
//  PreviewViewController.m
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import "PreviewViewController.h"
#import "EditViewController.h"
#import "FileManager.h"
#import "HoedownHelper.h"
#import "Item.h"
#import "Configure.h"
#import "PDFPageRender.h"

@interface PreviewViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;

@end

@implementation PreviewViewController
{
    Item *item;
    FileManager *fm;
    NSString *htmlString;
    UIPopoverPresentationController *popVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    fm = [FileManager sharedManager];
    _webView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLayoutSubviews{
    if (item == nil) {
        [self loadFile];
    }
}

- (void)loadFile
{
    item = fm.currentItem;
    if (item == nil) {
        [_webView loadHTMLString:@"" baseURL:nil];
        return;
    }
    NSString *path = item.fullPath;
    _webView.hidden = NO;
    _imageView.hidden = YES;
    beginLoadingAnimationOnParent(ZHLS(@"Loading"), self.webView);
    dispatch_async(dispatch_queue_create("preview_queue", DISPATCH_QUEUE_CONCURRENT), ^{
        hoedown_renderer *render = CreateHTMLRenderer();
        NSString *markdown = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSString *html = HTMLFromMarkdown(markdown, HOEDOWN_EXT_BLOCK|HOEDOWN_EXT_SPAN|HOEDOWN_EXT_FLAGS, YES, @"", render, CreateHTMLTOCRenderer());
        NSString *formatHtmlFile = [[NSBundle mainBundle] pathForResource:@"format" ofType:@"html"];
        NSString *format = [NSString stringWithContentsOfFile:formatHtmlFile encoding:NSUTF8StringEncoding error:nil];
        NSString *styleFile = [[NSBundle mainBundle] pathForResource:[Configure sharedConfigure].style ofType:@"css"];
        NSString *style = [NSString stringWithContentsOfFile:styleFile encoding:NSUTF8StringEncoding error:nil];
        htmlString = [[format stringByReplacingOccurrencesOfString:@"#_html_place_holder_#" withString:html] stringByReplacingOccurrencesOfString:@"#_style_place_holder_#" withString:style];
        dispatch_async(dispatch_get_main_queue(), ^{
            _webView.scalesPageToFit = NO;
            NSLog(@"%@",htmlString);
            [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:path]];
        });
    });
}

- (void)exportFile:(NSURL*)url
{
    NSArray *objectsToShare = @[url];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludedActivities = @[
                                    UIActivityTypePostToTwitter,
                                    UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr
                                    ];
    controller.excludedActivityTypes = excludedActivities;
    
    if (kDevicePad) {
        popVc = controller.popoverPresentationController;
        popVc.barButtonItem = self.navigationItem.rightBarButtonItem;
        popVc.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:controller animated:YES completion:nil];
    }];
}

- (NSData*)createPDF{
    PDFPageRender *render = [[PDFPageRender alloc]init];
    return [render renderPDFFromHtmlString:htmlString];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    stopLoadingAnimationOnParent(self.webView);
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    stopLoadingAnimationOnParent(self.webView);
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)dealloc
{
    if (kDevicePad) {
        [fm removeObserver:self forKeyPath:@"currentItem" context:NULL];
    }
    [Configure sharedConfigure].useTimes += 1;
    if (![ZHLS(@"About") isEqualToString:@"关于"]) {
        return;
    }
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)export:(id)sender {
    void(^clickedBlock)(NSInteger) = ^(NSInteger index) {
        NSURL *url = nil;
        if (index == 0){
            url = [NSURL fileURLWithPath:[documentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"/temp/%@.html",[fm currentItem].name]]];
            if (htmlString) {
                [htmlString writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
        }else if(index == 1){
            url = [NSURL fileURLWithPath:[documentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"/temp/%@.pdf",[fm currentItem].name]]];
            
            NSData *data = [self createPDF];
            [data writeToURL:url atomically:YES];
        }else if(index == 2){
            url = [NSURL fileURLWithPath:item.fullPath];
        }
        if (url) {
            [self exportFile:url];
        }
    };
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:ZHLS(@"ExportAs") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:ZHLS(@"WebPage"),ZHLS(@"PDF"),ZHLS(@"Markdown"), nil];
    sheet.clickedButton = clickedBlock;
    [sheet showInView:self.view];
}

- (IBAction)collect:(UIButton *)sender {
    if(sender.selected){
        sender.selected=NO;
    }
    else{
        sender.selected=YES;
    }
}

- (IBAction)goedit:(id)sender {
    if(self.isEditView){
        EditViewController *vc = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        vc.isPreView=0;
        [self.navigationController popToViewController:vc animated:true];
    }
    else{
        EditViewController *vc=[[EditViewController alloc]init];
        vc.isPreView=1;
        [self.navigationController pushViewController:vc animated:YES];}
    }
@end
