//
//  BookView.m
//  hgpdf
//
//  Created by harry on 13-8-3.
//  Copyright (c) 2013年 harry. All rights reserved.
//

#import "BookView.h"
#import <CommonCrypto/CommonDigest.h>
#import "UIImage+Thumb.h"

@implementation BookView

- (id)initWithFrame:(CGRect)frame data:(HgFiles *)data
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        float width = 112;
        
        //UIImage *img = [self getPdfThumbnail:path];
        
        
        
        UIImage *img = [UIImage imageNamed:@"booksmaple.png"];
        _imgvBook = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 112, img.size.height)];
        _imgvBook.backgroundColor = [UIColor whiteColor];
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *tmpfile = [self md5:[NSString stringWithFormat:@"%@%@",data.createtime,data.filename]];
        NSString *fullpath = [documentsDirectory stringByAppendingPathComponent:tmpfile];

        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
            _imgvBook.image = [UIImage imageWithContentsOfFile:fullpath];
        }else{
            [NSThread sleepForTimeInterval:0.8];
            NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(createImage:) object:data];
            [thread start];
        }
        [self addSubview:_imgvBook];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_imgvBook.frame.origin.x,
                                                                   _imgvBook.frame.origin.y+_imgvBook.frame.size.height+5,
                                                                   width,15)];
        label.adjustsFontSizeToFitWidth = NO;
        label.textAlignment = NSTextAlignmentCenter;
        label.opaque = NO;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:12];
        label.text = data.filename;
        [self addSubview:label];
        
        UIImage *img2 = [UIImage imageNamed:@"unselected.png"];
        _radio = [[UIImageView alloc] initWithFrame:CGRectMake(5,5, img2.size.width, img2.size.height)];
        _radio.image = img2;
        _radio.hidden = YES;
        [self addSubview:_radio];
        _isSelected = NO;
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(setCanSelectedOn)
//                                                     name:@"BOOKCANSELECTON" object:nil];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(setCanSelectedOff)
//                                                     name:@"BOOKCANSELECTOFF" object:nil];
    }
    return self;
}

- (void)createImage:(HgFiles *)data{
    //UIImage *img = [self getPdfThumbnail:path];
    UIImage *img;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *tmpfile = [self md5:[NSString stringWithFormat:@"%@%@",data.createtime,data.filename]];
    NSString *fullpath = [documentsDirectory stringByAppendingPathComponent:tmpfile];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath])
    {
        NSString* docPath = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
        NSString *path = [NSString stringWithFormat:@"%@/%@/%@",docPath,data.dirname ,data.filename];
        if ([data.dirname intValue]==0) {
            path = [NSString stringWithFormat:@"%@/%@",docPath,data.filename];
        }
        
        UIImage *thumbImage=[self getPdfThumbnail:path];
        
        UIImage *thb2 = [thumbImage scaleToSize:CGSizeMake(224, 286)];
        
        NSData *imagedata =UIImagePNGRepresentation(thb2);
        
        [imagedata writeToFile:fullpath atomically:YES];
    }
    img = [UIImage imageWithContentsOfFile:fullpath];
    
    _imgvBook.image = img;
}

-(NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[32];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

#pragma mark - Functions
- (UIImage *)getPdfThumbnail:(NSString *)finalPath{
    
    CFStringRef path = CFStringCreateWithCString(NULL, [finalPath UTF8String], kCFStringEncodingUTF8);
	CFURLRef url = CFURLCreateWithFileSystemPath(NULL, path, kCFURLPOSIXPathStyle, 0);
    CGPDFDocumentRef documentRef = CGPDFDocumentCreateWithURL(url);
//
//    
//    CGPDFPageRef page;
//    
//    CGRect aRect = CGRectMake(0, 0, 112, 144); // thumbnail size
//    UIGraphicsBeginImageContext(aRect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    UIImage* thumbnailImage;
//    
//    
//    
//    CGContextSaveGState(context);
//    CGContextTranslateCTM(context, 0.0, aRect.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//    
//    CGContextSetGrayFillColor(context, 1.0, 1.0);
//    CGContextFillRect(context, aRect);
//    
//    
//    // Grab the first PDF page
//    page = CGPDFDocumentGetPage(pdf, 1);
//    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, aRect, 0, true);
//    // And apply the transform.
//    CGContextConcatCTM(context, pdfTransform);
//    
//    CGContextDrawPDFPage(context, page);
//    
//    // Create the new UIImage from the context
//    thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    //Use thumbnailImage (e.g. drawing, saving it to a file, etc)
//    
//    CGContextRestoreGState(context);
//    
//    
//    
//    UIGraphicsEndImageContext();
//    CGPDFDocumentRelease(pdf);
//    
//    return thumbnailImage;
    
    
    
//    CGPDFPageRef pageRef = CGPDFDocumentGetPage(documentRef, 1);
//    CGRect pageRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
//    
//    UIGraphicsBeginImageContext(pageRect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextTranslateCTM(context, CGRectGetMinX(pageRect),CGRectGetMaxY(pageRect));
//    CGContextScaleCTM(context, 1, -1);
//    CGContextTranslateCTM(context, -(pageRect.origin.x), -(pageRect.origin.y));
//    CGContextDrawPDFPage(context, pageRef);
//    
//    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return finalImage;
    
    
    
 

    
    //取得指定页面的内容
    UIImage *image;
    CGPDFPageRef page = CGPDFDocumentGetPage(documentRef,1);
    if (page) {
        CGRect pageSize = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);//(595.276,807.874)
        //CGContextRef作成
        CGContextRef outContext =CGBitmapContextCreate(NULL,pageSize.size.width,pageSize.size.height,8,0,CGColorSpaceCreateDeviceRGB(),kCGImageAlphaPremultipliedLast);
        if (outContext)
        {
            //缩略图表示用image的输出
            CGContextDrawPDFPage(outContext, page);
            CGImageRef pdfImageRef = CGBitmapContextCreateImage(outContext);
            CGContextRelease(outContext);
            image = [UIImage imageWithCGImage:pdfImageRef];
            
            CGImageRelease(pdfImageRef);

        }
    }
    return image;
}





- (void)setCanSelectedOn{
    _radio.hidden = NO;
}

- (void)setCanSelectedOff{
    _radio.hidden = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    _canSelect = [self.delegate canSelected];
    //if (_canSelect) {
        if (_isSelected) {
            UIImage *img2 = [UIImage imageNamed:@"unselected.png"];
            _radio.image = img2;
        }else{
            UIImage *img2 = [UIImage imageNamed:@"selected.png"];
            _radio.image = img2;
        }
        
        _isSelected = !_isSelected;
        
        [self.delegate didSelect:_seqid status:_isSelected];
    //}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
