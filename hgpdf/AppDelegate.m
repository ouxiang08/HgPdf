//
//  AppDelegate.m
//  hgpdf
//
//  Created by harry on 13-7-31.
//  Copyright (c) 2013年 harry. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "UIImage+Thumb.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    ViewController *vc = [[ViewController alloc] init];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:vc];
    navCtrl.navigationBarHidden = YES;
    if ([self.window respondsToSelector:@selector(setRootViewController:)]) {
        self.window.rootViewController = navCtrl;
    } else {
        [self.window addSubview:navCtrl.view];
    }
    //扫描文件夹目录
    [self refreshFileData];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self refreshFileData];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"hgpdf" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"hgpdf.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void)refreshFileData{
    NSError *error;
    
    NSMutableArray *menuNameArr = [[NSMutableArray alloc] initWithObjects:@"全部文档浏览",@"汉高粘合剂",@"通用工业",@"工业粘合剂",@"汽车_航空_钢铁应用",@"民用及工匠建筑类应用",@"电子",@"汉高调查问卷入口", nil];
    
    NSManagedObjectContext *managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    NSString* docPath = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
    
    NSMutableArray *filearr = [[NSMutableArray alloc] init];
    
    for (int i=1; i<[menuNameArr count]-1; i++) {
        NSString* path = [NSString stringWithFormat: @"%@/%@", docPath, [menuNameArr objectAtIndex:i]];
        
        //判断文件夹是否存在
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            NSURL *fu = [NSURL fileURLWithPath:path];
            BOOL success = [fu setResourceValue: [NSNumber numberWithBool: YES]
                                         forKey: NSURLIsExcludedFromBackupKey error: &error];
            if(!success){
                NSLog(@"Error excluding %@ from backup %@", [fu lastPathComponent], error);
            }else{
                NSLog(@"Success excluding %@ from backup", [fu lastPathComponent]);
            }
        }
        
        
        
        //扫瞄该文件夹内容
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        for (int j=0; j<[files count]; j++) {
            NSString *filename = [files objectAtIndex:j];
            NSString *ext = [[filename pathExtension] lowercaseString];
            if ([ext isEqualToString:@"pdf"]) {
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"HgFiles"];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"dirname=%d && filename=%@",i,filename];
                NSArray *theModelsArray = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
                if ([theModelsArray count]==0) {
                    HgFiles *hgfile = [NSEntityDescription insertNewObjectForEntityForName:@"HgFiles" inManagedObjectContext:managedObjectContext];
                    hgfile.filename = filename;
                    hgfile.dirname = [NSNumber numberWithInt:i];
                    
                    NSFileManager* fm = [NSFileManager defaultManager];
                    NSDictionary* attrs = [fm attributesOfItemAtPath:path error:nil];
                    
                    if (attrs != nil) {
                        hgfile.createtime = (NSDate*)[attrs objectForKey: NSFileCreationDate];
                    }
                    
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    
                    NSString *tmpfile = [self  md5:[NSString stringWithFormat:@"%@%@",hgfile.createtime,hgfile.filename]];
                    NSString *fullpath = [documentsDirectory stringByAppendingPathComponent:tmpfile];
                    
                    
                    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
                        [filearr addObject:hgfile];
                    }
                    
                  
                }
            }
        }
        
        
        //根目录下的
        NSArray *files2 = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docPath error:nil];
        for (int j=0; j<[files2 count]; j++) {
            NSString *filename = [files2 objectAtIndex:j];
            NSString *ext = [[filename pathExtension] lowercaseString];
            if (![self fileIsDirectory:filename] && [ext isEqualToString:@"pdf"]) {
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"HgFiles"];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"dirname=%d && filename=%@",0,filename];
                NSArray *theModelsArray = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
                if ([theModelsArray count]==0) {
                    HgFiles *hgfile = [NSEntityDescription insertNewObjectForEntityForName:@"HgFiles" inManagedObjectContext:managedObjectContext];
                    hgfile.filename = filename;
                    hgfile.dirname = [NSNumber numberWithInt:0];
                    
                    NSFileManager* fm = [NSFileManager defaultManager];
                    NSDictionary* attrs = [fm attributesOfItemAtPath:path error:nil];
                    
                    if (attrs != nil) {
                        hgfile.createtime = (NSDate*)[attrs objectForKey: NSFileCreationDate];
                    }
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    
                    NSString *tmpfile = [self  md5:[NSString stringWithFormat:@"%@%@",hgfile.createtime,hgfile.filename]];
                    NSString *fullpath = [documentsDirectory stringByAppendingPathComponent:tmpfile];
                    
                    
                    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
                        [filearr addObject:hgfile];
                    }
                    
                    
                }
            }
        }
    }
    
    for (int i=0; i<[filearr count]; i++) {
        [NSThread sleepForTimeInterval:1];
        [NSThread detachNewThreadSelector:@selector(createImage:) toTarget:self withObject:[filearr objectAtIndex:i]];
    }
    
}

- (BOOL)fileIsDirectory:(NSString *)path {
	BOOL isdir = NO;
	[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isdir];
	return isdir;
}


- (void)createImage:(HgFiles *)data{
    //UIImage *img = [self getPdfThumbnail:path];
    //UIImage *img;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *tmpfile = [self md5:[NSString stringWithFormat:@"%@%@",data.createtime,data.filename]];
    NSString *fullpath = [documentsDirectory stringByAppendingPathComponent:tmpfile];
    
    NSLog(@"creating:%@",fullpath);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath])
    {
        NSLog(@"is in creating....");
        NSString* docPath = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
        NSString *path = [NSString stringWithFormat:@"%@/%@/%@",docPath,data.dirname ,data.filename];
        if ([data.dirname intValue]==0) {
            path = [NSString stringWithFormat:@"%@/%@",docPath,data.filename];
        }
        
        UIImage *thumbImage=[self getPdfThumbnail:path];
        
        UIImage *thb2 = [thumbImage scaleToSize:CGSizeMake(223, 286)];
        
        NSData *imagedata =UIImagePNGRepresentation(thb2);
        
        [imagedata writeToFile:fullpath atomically:YES];
    }
    //img = [UIImage imageWithContentsOfFile:fullpath];
    
    
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




@end
