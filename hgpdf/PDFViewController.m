//
//  PDFViewController.m
//  huishieda
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 yongjun. All rights reserved.
//

#import "PDFViewController.h"

@interface PDFViewController ()
@property (nonatomic,strong)UIWebView *aWebView;
@end

@implementation PDFViewController
@synthesize filename;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Creates an instance of a UIWebView
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.title = [filename lastPathComponent];

    _aWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)];
    if (!_island) {
        _aWebView.frame = CGRectMake(0, 0, 768, 1024);
    }
    // Sets the scale of web content the first time it is displayed in a web view
    
    _aWebView.scalesPageToFit = YES;
    
    [_aWebView setDelegate:self];
    
    
    //Create a URL object.
    //NSString *thePath=[[NSBundle mainBundle] pathForResource:filename ofType:@"pdf"];
    //NSLog(@"file:%@",thePath);
    NSURL *urlString = [NSURL fileURLWithPath:filename isDirectory:FALSE];

    //URL Requst Object

    NSURLRequest *requestObj = [NSURLRequest requestWithURL:urlString];


    //load the URL into the web view.
    
    [_aWebView loadRequest:requestObj];

    [self.view addSubview:_aWebView];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}



#pragma mark - 方向
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft||interfaceOrientation==UIInterfaceOrientationLandscapeRight) {
        _aWebView.frame = CGRectMake(0, 0, 1024,768);
    }
    
    if (interfaceOrientation==UIInterfaceOrientationPortrait||interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
        _aWebView.frame = CGRectMake(0, 0, 768, 1024);
    }
    return YES;
}


-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate{
    return YES;
}


//视图旋转方向发生改变时会自动调用
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"视图旋转方向发生改变时会自动调用");
    NSLog(@"%d",[[UIApplication sharedApplication] statusBarOrientation]);
    if ([[UIApplication sharedApplication] statusBarOrientation]==UIInterfaceOrientationLandscapeLeft||
        [[UIApplication sharedApplication] statusBarOrientation]==UIInterfaceOrientationLandscapeRight) {
        _aWebView.frame = CGRectMake(0, 0, 1024,768);
    }else{
        _aWebView.frame = CGRectMake(0, 0, 768,1024);
    }
}


@end
