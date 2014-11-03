//
//  HgFiles.h
//  hgpdf
//
//  Created by harry on 13-8-1.
//  Copyright (c) 2013年 harry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HgFiles : NSManagedObject

@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSDate * createtime;
@property (nonatomic, retain) NSDate * viewedtime;
@property (nonatomic, retain) NSNumber * dirname;

@end
