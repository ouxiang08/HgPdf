//
//  PDFViewController.h
//  huishieda
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 yongjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFViewController : UIViewController<UIWebViewDelegate>
@property(retain,nonatomic)NSString* filename;
@property(assign,nonatomic)BOOL island;

@end
