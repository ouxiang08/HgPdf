//
//  BookView.h
//  hgpdf
//
//  Created by harry on 13-8-3.
//  Copyright (c) 2013年 harry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HgFiles.h"
@protocol BookViewDelegate <NSObject>
- (BOOL)canSelected;
- (void)didSelect:(int )seqid status:(BOOL)status;
@end

@interface BookView : UIView
@property(nonatomic,assign)BOOL isSelected;
@property(nonatomic,assign)BOOL canSelect;
@property(nonatomic,assign)int seqid;

@property(nonatomic,strong)UIImageView *radio;
@property(nonatomic,weak)id <BookViewDelegate> delegate;
@property(nonatomic,strong)UIImageView *imgvBook;

- (id)initWithFrame:(CGRect)frame data:(HgFiles *)data;
- (void)setCanSelectedOn;
- (void)setCanSelectedOff;
@end
