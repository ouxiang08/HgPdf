//
//  ViewController.m
//  hgpdf
//
//  Created by harry on 13-7-31.
//  Copyright (c) 2013年 harry. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "HgFiles.h"
#import "PDFViewController.h"

@interface ViewController ()
@property(nonatomic,strong) UIImageView *bgimgv;
@property(nonatomic,strong) UIScrollView *scl;

@property(nonatomic,strong) UIButton *btSortName;
@property(nonatomic,strong) UIButton *btSortCreate;
@property(nonatomic,strong) UIButton *btSortRead;
@property(nonatomic,strong) UIButton *btListThumb;
@property(nonatomic,strong) UIButton *btListTable;

@property(nonatomic,strong) UIButton *btEdit;

@property(nonatomic,assign) int selectedIndex;
@property(nonatomic,strong) NSMutableArray *menuArr;
@property(nonatomic,strong) NSArray *menuNameArr;
@property(nonatomic,strong) NSArray *menuNameTextArr;
@property(nonatomic,strong) NSMutableArray *filesArr;
@property(nonatomic,strong) NSMutableArray *filesSelectedArr;
@property(nonatomic,strong) UILabel *lblTitle;

//编辑状态下的控件
@property(nonatomic,strong) UIButton *btMove;
@property(nonatomic,strong) UIButton *btDelete;
@property(nonatomic,strong) UILabel *lblSelectCnt;
@property(nonatomic,strong) UIImageView *imgvSeprate;

@property(nonatomic,strong) UIButton *btOutLink;

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,assign) BOOL island;
@property(nonatomic,assign) BOOL isthumbmode;
@property(nonatomic,assign) BOOL isEdit;
@property(nonatomic,assign) BOOL isMoveStatus;//已点击移动
@property(nonatomic,assign) int sorttype;//1 名称 2创建日期 3查看日期
@property(nonatomic,assign) int listtype;//1 缩略图 2列表
@end

@implementation ViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([[UIApplication sharedApplication] statusBarOrientation]==UIInterfaceOrientationLandscapeLeft ||
        [[UIApplication sharedApplication] statusBarOrientation]==UIInterfaceOrientationLandscapeRight) {
        _island = YES;
    }else{
        _island = NO;
    }
        
    [self changeStatus];
    
    
}

- (NSString *)transToTitle:(NSString *)oldtitle{
    return [oldtitle stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    _filesSelectedArr = [[NSMutableArray alloc] init];
    _filesArr = [[NSMutableArray alloc] init];

	// Do any additional setup after loading the view.
    _selectedIndex = 0;
    _isthumbmode = YES;
    _isEdit = NO;
    _sorttype = 1;
    _listtype = 1;
    _isMoveStatus = NO;
    _menuNameArr = [[NSMutableArray alloc] initWithObjects:@"全部文档",@"汉高粘合剂",@"通用工业",@"工业粘合剂",@"汽车_航空_钢铁应用",@"民用及工匠建筑类应用",@"电子",@"汉高调查问卷入口", nil];
    
    _menuNameTextArr = [[NSMutableArray alloc] initWithObjects:@"全部文档 All Files",@"汉高粘合剂 Henkel Adhesive Technologies",@"通用工业 General Industry",@"工业粘合剂 Packaging and Consumer Goods",@"汽车/航空/钢铁应用 Transport and Metal",@"民用及工匠建筑类应用 Consumer,Craftsmen and Building",@"电子 Electronics",@"汉高调查问卷入口 Questionnaire", nil];

    _bgimgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [self.view addSubview:_bgimgv];
    
    _lblTitle = [[UILabel alloc] init];
    _lblTitle.adjustsFontSizeToFitWidth = NO;
    _lblTitle.textAlignment = NSTextAlignmentCenter;
    _lblTitle.opaque = NO;
    _lblTitle.backgroundColor = [UIColor clearColor];
    _lblTitle.textColor = [UIColor whiteColor];
    _lblTitle.font = [UIFont boldSystemFontOfSize:20];
    _lblTitle.text = [_menuNameTextArr objectAtIndex:0];
    [self.view addSubview:_lblTitle];
    
    
    //排序按钮
    _btSortName = [UIButton buttonWithType:UIButtonTypeCustom];
    _btSortName.tag=1;
    [_btSortName addTarget:self action:@selector(setSort:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btSortName];
    
    _btSortCreate = [UIButton buttonWithType:UIButtonTypeCustom];
    _btSortCreate.tag=2;
    [_btSortCreate addTarget:self action:@selector(setSort:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btSortCreate];
    
    _btSortRead = [UIButton buttonWithType:UIButtonTypeCustom];
    _btSortRead.tag=3;
    [_btSortRead addTarget:self action:@selector(setSort:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btSortRead];
    
    //列表模式
    _btListThumb = [UIButton buttonWithType:UIButtonTypeCustom];
    _btListThumb.tag=1;
    [_btListThumb addTarget:self action:@selector(setList:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btListThumb];
    
    _btListTable = [UIButton buttonWithType:UIButtonTypeCustom];
    _btListTable.tag=2;
    [_btListTable addTarget:self action:@selector(setList:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btListTable];
    
    //操作按钮
    _btEdit = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btEdit addTarget:self action:@selector(doEdit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btEdit];
    
    
    //菜单
    _menuArr = [[NSMutableArray alloc] init];
    for (int i=0; i<[_menuNameArr count]; i++) {
        UIButton *bt =  [UIButton buttonWithType:UIButtonTypeCustom];
        bt.tag=i;
        [bt addTarget:self action:@selector(selecteMenu:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:bt];
        [_menuArr addObject:bt];
    }
    
    
    _scl = [[UIScrollView alloc] init];
    //_scl.backgroundColor = [UIColor redColor];
    [self.view addSubview:_scl];
    
    
    //编辑相关按钮
//    _btDelete = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *deleteimg = [UIImage imageNamed:@"bt_delete.png"];
//    [_btDelete setImage:deleteimg forState:UIControlStateNormal];
//    [_btDelete addTarget:self action:@selector(doDelete) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_btDelete];
    
    UIImage *sepimg = [UIImage imageNamed:@"seperate.png"];
    _imgvSeprate = [[UIImageView alloc] init];
    _imgvSeprate.image = sepimg;
    [self.view addSubview:_imgvSeprate];
    
    _btMove = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *moveimg = [UIImage imageNamed:@"bt_move.png"];
    [_btMove setImage:moveimg forState:UIControlStateNormal];
    [_btMove addTarget:self action:@selector(doMove) forControlEvents:UIControlEventTouchUpInside];    
    [self.view addSubview:_btMove];
    
    
    _lblSelectCnt = [[UILabel alloc] init];
    _lblSelectCnt.adjustsFontSizeToFitWidth = NO;
    _lblSelectCnt.textAlignment = NSTextAlignmentLeft;
    _lblSelectCnt.opaque = NO;
    _lblSelectCnt.backgroundColor = [UIColor clearColor];
    _lblSelectCnt.textColor = [UIColor blackColor];
    _lblSelectCnt.font = [UIFont boldSystemFontOfSize:14];
    [self.view addSubview:_lblSelectCnt];
    
    _btMove.hidden = YES;
    //_btDelete.hidden = YES;
    _lblSelectCnt.hidden = YES;
    _imgvSeprate.hidden = YES;
    
    
    _btOutLink = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *linkimg = [UIImage imageNamed:@"linkto.png"];
    [_btOutLink setImage:linkimg forState:UIControlStateNormal];
    [_btOutLink addTarget:self action:@selector(clickLink) forControlEvents:UIControlEventTouchUpInside];
    _btOutLink.hidden = YES;
    _btOutLink.contentMode = UIViewContentModeCenter;
    [self.view addSubview:_btOutLink];
    
    
    
    
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 62;
    _tableView.hidden = YES;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = [[UIView alloc]init];
    [self.view addSubview:_tableView];

    [self initFilesArr];
}


#pragma mark - Methods
- (void)clickLink{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.henkel-questionnaire.cn"]];
}

- (void)doMove{
    
    NSString *hint = @"";
    if ([_filesSelectedArr count]==0) {
        hint = @"请选择要移动的文件";
        UIAlertView *sAlert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:hint
                                                        delegate:nil
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:nil,nil];
        [sAlert show];
    }else{
        hint = [NSString stringWithFormat:@"你确定要移动这%d个文件吗？",[_filesSelectedArr count]];
        UIAlertView *sAlert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:hint
                                                        delegate:self
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:@"取消",nil];
        sAlert.tag = 1;
        [sAlert show];
    }
    
   
}

- (void)doDelete{
    
    if ([_filesSelectedArr count]==0) {
        NSString *hint = @"请选择要删除的文件";
        UIAlertView *sAlert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:hint
                                                        delegate:nil
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:nil,nil];
        [sAlert show];
    }else{
        NSString *hint = [NSString stringWithFormat:@"你确定要删除这%d个文件吗？",[_filesSelectedArr count]];
        UIAlertView *sAlert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:hint
                                                        delegate:self
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:@"取消",nil];
        sAlert.tag = 2;
        [sAlert show];
    }
    
   
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        if (alertView.tag==1) {
            _isMoveStatus = YES;
        }
        if (alertView.tag==2) {
            for (int i=0; i<[_filesSelectedArr count]; i++) {
                HgFiles *file = [_filesSelectedArr objectAtIndex:i];
                NSString* docPath = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
                NSString *path = [NSString stringWithFormat:@"%@/%@/%@",docPath,[_menuNameArr objectAtIndex:[file.dirname intValue]] ,file.filename];
                if ([file.dirname intValue]==0) {
                    path = [NSString stringWithFormat:@"%@/%@",docPath,file.filename];
                }
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                
                NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
                NSManagedObject *eventToDelete = [context objectWithID:[file objectID]];
                [context deleteObject:eventToDelete];
                NSError *error;
                if (![context save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
            }
            NSString *hint = [NSString stringWithFormat:@"已删除%d个文件。",[_filesSelectedArr count]];
            UIAlertView *sAlert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                             message:hint
                                                            delegate:nil
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil,nil];
            [sAlert show];
            
            [_filesArr removeObjectsInArray:_filesSelectedArr];
            [_filesSelectedArr removeAllObjects];
            [self reloadPdfs];
            
            [self doEdit];
        }
    }
}

- (void)doEdit{
    if (_selectedIndex<5) {
        if (_isEdit) {
            [_btEdit setImage:[UIImage imageNamed:@"bt_edit.png"] forState:UIControlStateNormal];
            
            _btMove.hidden = YES;
            //_btDelete.hidden = YES;
            _lblSelectCnt.hidden = YES;
            _imgvSeprate.hidden = YES;
            
            _btSortName.hidden = NO;
            _btSortCreate.hidden = NO;
            _btSortRead.hidden = NO;
            _btListThumb.hidden = NO;
            _btListTable.hidden = NO;
            
            [_filesSelectedArr removeAllObjects];
            [_tableView reloadData];
            
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"BOOKCANSELECTOFF" object:nil];
            
            NSArray *subviews = [_scl subviews];
            
            for (int i=0; i<[subviews count]; i++) {
                if ([[subviews objectAtIndex:i] isKindOfClass:[BookView class]]) {
                    BookView *bv = [subviews objectAtIndex:i];
                    [bv setCanSelectedOff];
                }
            }
            
        }else{
            [_btEdit setImage:[UIImage imageNamed:@"bt_confirm.png"] forState:UIControlStateNormal];
            
            _btMove.hidden = NO;
            //_btDelete.hidden = NO;
            _lblSelectCnt.hidden = NO;
            _imgvSeprate.hidden = NO;
            
            _btSortName.hidden = YES;
            _btSortCreate.hidden = YES;
            _btSortRead.hidden = YES;
            _btListThumb.hidden = YES;
            _btListTable.hidden = YES;
            
            [_tableView reloadData];
            _lblSelectCnt.text = [NSString stringWithFormat:@"选择Choose：%d个文件Files",[_filesSelectedArr count]];

            
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"BOOKCANSELECTON" object:nil];
            
            
            NSArray *subviews = [_scl subviews];
            
            for (int i=0; i<[subviews count]; i++) {
                if ([[subviews objectAtIndex:i] isKindOfClass:[BookView class]]) {
                    BookView *bv = [subviews objectAtIndex:i];
                    [bv setCanSelectedOn];
                }
            }
            
        }
        _isEdit=!_isEdit;

    }
}

- (void)setSort:(UIButton *)seq{
     if (_sorttype!=seq.tag) {
         _sorttype = seq.tag;
         
         NSString *side = @"v";
         if (_island) {
             side = @"h";
         }
         
        NSString *imgname = [NSString stringWithFormat:@"bt_sortbyfilename_%@%@.png",side,(_sorttype==1)?@"_selected":@""];
        UIImage *sortFileImg = [UIImage imageNamed:imgname];
        [_btSortName setImage:sortFileImg forState:UIControlStateNormal];
        
        
        NSString *imgname2 = [NSString stringWithFormat:@"bt_sortbycreate_%@%@.png",side,(_sorttype==2)?@"_selected":@""];
        UIImage *sortCreateImg = [UIImage imageNamed:imgname2];
        [_btSortCreate setImage:sortCreateImg forState:UIControlStateNormal];
        
        NSString *imgname3 = [NSString stringWithFormat:@"bt_sortbyreadtime_%@%@.png",side,(_sorttype==3)?@"_selected":@""];
        UIImage *sortReadImg = [UIImage imageNamed:imgname3];
        [_btSortRead setImage:sortReadImg forState:UIControlStateNormal];
         
         [self initFilesArr];
         [self reloadPdfs];
     }
    
    
}

- (void)setList:(UIButton *)seq{
    if (_selectedIndex<5) {
        if (_listtype!=seq.tag) {
            _listtype = seq.tag;
            
            NSString *imgname4 = [NSString stringWithFormat:@"bt_list_%@.png",(_listtype==1)?@"on":@"off"];
            UIImage *listThumbImg = [UIImage imageNamed:imgname4];
            [_btListThumb setImage:listThumbImg forState:UIControlStateNormal];
            
            NSString *imgname5 = [NSString stringWithFormat:@"bt_thumb_%@.png",(_listtype==1)?@"on":@"off"];
            UIImage *listTableImg = [UIImage imageNamed:imgname5];
            [_btListTable setImage:listTableImg forState:UIControlStateNormal];
            
            _isthumbmode = !_isthumbmode;
            
            if (_isthumbmode==YES) {
                _scl.hidden = NO;
                _tableView.hidden = YES;
            }else{
                _scl.hidden = YES;
                _tableView.hidden = NO;
            }
        }
    }
}

- (void)selecteMenu:(UIButton *)seq{
    int btid = seq.tag;
    _lblTitle.text = [self transToTitle:[_menuNameTextArr objectAtIndex:btid]];
    if (_isMoveStatus && btid<[_menuNameArr count]-1) {
        int movedfiles = 0;
        for (int i=0; i<[_filesSelectedArr count]; i++) {
            
            HgFiles *file = [_filesSelectedArr objectAtIndex:i];
            if ([file.dirname intValue]!=btid) {
                movedfiles++;
                NSString* docPath = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
                NSString *frompath = [NSString stringWithFormat:@"%@/%@/%@",docPath,[_menuNameArr objectAtIndex:[file.dirname intValue]] ,file.filename];
                if ([file.dirname intValue]==0) {
                    frompath = [NSString stringWithFormat:@"%@/%@",docPath,file.filename];
                }
                
                NSString *topath = [NSString stringWithFormat:@"%@/%@/%@",docPath,[_menuNameArr objectAtIndex:btid] ,file.filename];
                if (btid==0) {
                    topath = [NSString stringWithFormat:@"%@/%@",docPath,file.filename];
                }
                
                NSError *error;
                if ([[NSFileManager defaultManager] moveItemAtPath:frompath toPath:topath error:&error] != YES){
                    NSLog(@"Unable to move file: %@", [error localizedDescription]);
                }
            
                file.dirname = [NSNumber numberWithInt:btid];
                NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
            
                if (![context save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
            
                [_filesArr removeObject:file];

            }
        }
        NSString *hint = [NSString stringWithFormat:@"已移走%d个文件。",movedfiles];
    
        UIAlertView *sAlert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                     message:hint
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil,nil];
        [sAlert show];
    
        [_filesSelectedArr removeAllObjects];
        _isMoveStatus = NO;
        
        [self doEdit];
        
        [self reloadPdfs];
    }else{
        _selectedIndex = btid;
        [self changeStatus];
        if (btid<[_menuNameArr count]-1) {
            _selectedIndex = btid;
            _btOutLink.hidden = YES;
            [self initFilesArr];
            [self reloadPdfs];
        }else{
            _scl.hidden = YES;
            _tableView.hidden = YES;
            _btOutLink.hidden = NO;
        }
    }
}

- (void)initFilesArr{
    [_filesArr removeAllObjects];
    
//    NSString* docPath = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
//    if (seq>0) {
//        NSString* path = [NSString stringWithFormat: @"%@/%d", docPath, seq];
//        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
//        [_filesArr arrayByAddingObjectsFromArray:files];
//    }else{
//        for (int i=1; i<5; i++) {
//            NSString* path = [NSString stringWithFormat: @"%@/%d", docPath, seq];
//            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
//            [_filesArr addObjectsFromArray:files];
//        }
//        //根目录下的
//        NSArray *files2 = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docPath error:nil];
//        for (int j=0; j<[files2 count]; j++) {
//            NSString *file = [files2 objectAtIndex:j];
//            NSString *ext = [[file pathExtension] lowercaseString];
//            if (![self fileIsDirectory:file] && [ext isEqualToString:@"pdf"]) {
//                [_filesArr addObject:file];
//            }
//        }
//    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"HgFiles"];
    if (_selectedIndex>0) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"dirname=%d",_selectedIndex];
    }
    
    if (_sorttype==1) {
        fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"filename" ascending:YES]];
    }
    if (_sorttype==2) {
        fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createtime" ascending:NO]];
    }
    if (_sorttype==3) {
        fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"viewedtime" ascending:NO]];
        if (_selectedIndex==0) {
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"viewedtime!=nil",@""];
        }else{
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"dirname=%d && viewedtime!=nil",_selectedIndex];
        }
        
    }
    
    NSManagedObjectContext *managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    NSError *error;
    NSArray *theModelsArray = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    [_filesArr addObjectsFromArray:theModelsArray];
    NSLog(@"%@",_filesArr);
    
    [_tableView reloadData];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeStatus{
    
    float sortBtX = 272;
    float sortBtY = 80;
    
    float listBtX = 663;
    
    float editX = 958;
    float editY = 34;
    float screenw = 1024;
    float lblx = 255;

    if (_island) {
        //zuo
        _bgimgv.frame = CGRectMake(0, 0, 1024, 768);
        UIImage *img = [UIImage imageNamed:@"bg.png"];
        _bgimgv.image = img;
        
        _lblTitle.frame = CGRectMake(263, 28, 755, 44);
        _lblTitle.font = [UIFont boldSystemFontOfSize:20];
        
        for (int i=0; i<[_menuArr count]; i++) {
            
            UIImage *selectedImg = [UIImage imageNamed:[NSString stringWithFormat:@"menu%d_selected_h.png",i+1]];
            UIImage *unselectedImg = [UIImage imageNamed:[NSString stringWithFormat:@"menu%d_h.png",i+1]];
            
            UIButton *bt = [_menuArr objectAtIndex:i];
            bt.frame = CGRectMake(19, 117+i*74, selectedImg.size.width, selectedImg.size.height);
            NSLog(@"%d ----",117+i*83);
            if (i==_selectedIndex) {
                [bt setBackgroundImage:selectedImg forState:UIControlStateNormal];
                [bt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }else{
                [bt setBackgroundImage:unselectedImg forState:UIControlStateNormal];
                [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }
        
         listBtX = 925;
         lblx = 266;
                
    }else{
        _bgimgv.frame = CGRectMake(0, 0, 768, 1024);
        UIImage *img = [UIImage imageNamed:@"bg_v.png"];
        _bgimgv.image = img;
        
        _lblTitle.frame = CGRectMake(244, 28, 512, 44);
        _lblTitle.font = [UIFont boldSystemFontOfSize:16];
        
        for (int i=0; i<[_menuArr count]; i++) {
            UIImage *selectedImg = [UIImage imageNamed:[NSString stringWithFormat:@"menu%d_selected_v.png",i+1]];
            UIImage *unselectedImg = [UIImage imageNamed:[NSString stringWithFormat:@"menu%d_v.png",i+1]];
            UIButton *bt = [_menuArr objectAtIndex:i];
            bt.frame = CGRectMake(19, 114+i*83, selectedImg.size.width, selectedImg.size.height);
            if (i==_selectedIndex) {
                [bt setBackgroundImage:selectedImg forState:UIControlStateNormal];
                [bt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }else{
                [bt setBackgroundImage:unselectedImg forState:UIControlStateNormal];
                [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }
        
        sortBtX = 253;
        editX = 685;
        screenw = 768;
    }
    
    NSString *side = @"v";
    if (_island) {
        side = @"h";
    }
    
    NSString *imgname = [NSString stringWithFormat:@"bt_sortbyfilename_%@%@.png",side,(_sorttype==1)?@"_selected":@""];
    UIImage *sortFileImg = [UIImage imageNamed:imgname];
    _btSortName.frame = CGRectMake(sortBtX,sortBtY, sortFileImg.size.width,sortFileImg.size.height);
    [_btSortName setImage:sortFileImg forState:UIControlStateNormal];
    
    
    NSString *imgname2 = [NSString stringWithFormat:@"bt_sortbycreate_%@%@.png",side,(_sorttype==2)?@"_selected":@""];
    UIImage *sortCreateImg = [UIImage imageNamed:imgname2];
    _btSortCreate.frame = CGRectMake(_btSortName.frame.origin.x+_btSortName.frame.size.width,
                                     80, sortCreateImg.size.width,sortCreateImg.size.height);
    [_btSortCreate setImage:sortCreateImg forState:UIControlStateNormal];
    
    NSString *imgname3 = [NSString stringWithFormat:@"bt_sortbyreadtime_%@%@.png",side,(_sorttype==3)?@"_selected":@""];
    UIImage *sortReadImg = [UIImage imageNamed:imgname3];
    _btSortRead.frame = CGRectMake(_btSortCreate.frame.origin.x+_btSortCreate.frame.size.width,
                                   80, sortReadImg.size.width,sortReadImg.size.height);
    [_btSortRead setImage:sortReadImg forState:UIControlStateNormal];
    
    
    NSString *imgname4 = [NSString stringWithFormat:@"bt_list_%@.png",(_listtype==1)?@"on":@"off"];
    UIImage *listThumbImg = [UIImage imageNamed:imgname4];
    _btListThumb.frame = CGRectMake(listBtX,80, listThumbImg.size.width,listThumbImg.size.height);
    [_btListThumb setImage:listThumbImg forState:UIControlStateNormal];
    
    NSString *imgname5 = [NSString stringWithFormat:@"bt_thumb_%@.png",(_listtype==1)?@"on":@"off"];
    UIImage *listTableImg = [UIImage imageNamed:imgname5];
    _btListTable.frame = CGRectMake(_btListThumb.frame.origin.x+_btListThumb.frame.size.width,80, listTableImg.size.width,listTableImg.size.height);
    [_btListTable setImage:listTableImg forState:UIControlStateNormal];
    
    UIImage *editimg = [UIImage imageNamed:@"bt_confirm.png"];
    if (_isEdit) {
        [_btEdit setImage:[UIImage imageNamed:@"bt_confirm.png"] forState:UIControlStateNormal];
    }else{
        [_btEdit setImage:[UIImage imageNamed:@"bt_edit.png"] forState:UIControlStateNormal];
    }
    _btEdit.frame = CGRectMake(editX, editY, editimg.size.width, editimg.size.height);
    
    [self reloadPdfs];

    
    UIImage *linkimg = [UIImage imageNamed:@"linkto.png"];
    _btOutLink.frame = CGRectMake(_scl.frame.origin.x+(_scl.frame.size.width-linkimg.size.width)/2,
                                  _scl.frame.origin.y+(_scl.frame.size.height-linkimg.size.height)/2, linkimg.size.width, linkimg.size.height);

//    UIImage *sepimg = [UIImage imageNamed:@"seperate.png"];
//    UIImage *deleteimg = [UIImage imageNamed:@"bt_delete.png"];
    UIImage *moveimg = [UIImage imageNamed:@"bt_move.png"];
//    _btDelete.frame = CGRectMake(screenw-20-deleteimg.size.width, 84, deleteimg.size.width, deleteimg.size.height);
//    _imgvSeprate.frame = CGRectMake(_btDelete.frame.origin.x-12, 84, sepimg.size.width, sepimg.size.height);
//    _btMove.frame = CGRectMake(_imgvSeprate.frame.origin.x-12-moveimg.size.width, 84, moveimg.size.width, moveimg.size.height);
    _btMove.frame = CGRectMake(screenw-20-moveimg.size.width, 84, moveimg.size.width, moveimg.size.height);
    
    _lblSelectCnt.frame = CGRectMake(lblx, _btListThumb.frame.origin.y+5, 200, 16);

    
}



- (void)reloadPdfs{
    float fromx = 296;
    float fromy = 132;
    float xspan = 146;
    float yspan = 177;
    float width = 112;
    float heigh = 144;
    int imginline = 5;
    float scrw = 693;
    float scrh = 518;
    float tbx = 253;
    float tbw = 753;
    if (!_island) {
        fromx = 292;
        fromy = 146;
        imginline = 3;
        scrw = 403;
        scrh = 820;
        tbx = 244;
        tbw = 512;
    }
    
    [[_scl subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    
    NSString* docPath = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
    int j=0;
    for (int i=0; i<[_filesArr count]; i++) {
        HgFiles *file = [_filesArr objectAtIndex:i];
        
        NSString *path = [NSString stringWithFormat:@"%@/%@/%@",docPath,[_menuNameArr objectAtIndex:[file.dirname intValue]] ,file.filename];
        if ([file.dirname intValue]==0) {
            path = [NSString stringWithFormat:@"%@/%@",docPath,file.filename];
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            //UIImage *img = [self getPdfThumbnail:path];
            
            float x = (j%imginline)*xspan;
            float y = (j/imginline)*yspan;
            
            BookView *bv = [[BookView alloc] initWithFrame:CGRectMake(x, y, width, heigh) data:file];
            bv.seqid = i;
            bv.delegate = self;
            [_scl addSubview:bv];
            
            j++;
        }
    }
    
    _scl.frame = CGRectMake(fromx, fromy, scrw, scrh);
    
    float csw = yspan*(ceil([_filesArr count]/imginline)+1);
    _scl.contentSize = CGSizeMake(scrw, csw);
    
    
    _tableView.frame = CGRectMake(tbx-25, fromy, tbw+50, scrh);
    
    if (_isthumbmode==YES) {
        _scl.hidden = NO;
        _tableView.hidden = YES;
    }else{
        _scl.hidden = YES;
        _tableView.hidden = NO;
    }
    
}

#pragma mark - InterfaceOrientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft||interfaceOrientation==UIInterfaceOrientationLandscapeRight) {
        _island = YES;
    }
    
    if (interfaceOrientation==UIInterfaceOrientationPortrait||interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
        _island = NO;
    }
    [self changeStatus];
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
        _island = YES;
    }else{
        _island = NO;
    }
    [self changeStatus];
}



#pragma mark - Delegate
- (BOOL)canSelected{
    return _isEdit;
}
- (void)didSelect:(int )seqid status:(BOOL)status{
    if (_isEdit) {
        if (status==YES) {
            [_filesSelectedArr addObject:[_filesArr objectAtIndex:seqid]];
        }
        if (status==NO) {
            [_filesSelectedArr removeObject:[_filesArr objectAtIndex:seqid]];
        }
        _lblSelectCnt.text = [NSString stringWithFormat:@"选择Choose：%d个文件Files",[_filesSelectedArr count]];

    }else{
        PDFViewController *gv = [[PDFViewController alloc] initWithNibName:nil bundle:nil];
        HgFiles *file = [_filesArr objectAtIndex:seqid];
        
        file.viewedtime = [NSDate date];
        NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        NSString* docPath = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
        NSString *path = [NSString stringWithFormat:@"%@/%@/%@",docPath,[_menuNameArr objectAtIndex:[file.dirname intValue]] ,file.filename];
        if ([file.dirname intValue]==0) {
            path = [NSString stringWithFormat:@"%@/%@",docPath,file.filename];
        }
        gv.filename = path;
        gv.island = _island;

        [self.navigationController pushViewController:gv animated:YES];
    }
    
    
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_filesArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    if (_isEdit) {
        if ([_filesSelectedArr indexOfObject:[_filesArr objectAtIndex:indexPath.row]]==NSNotFound) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    HgFiles *file = [_filesArr objectAtIndex:indexPath.row];
    cell.textLabel.text = file.filename;
    //cell.detailTextLabel.text = [file.createtime description];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   

    if (_isEdit) {
//        UITableViewCell *tc = [tableView cellForRowAtIndexPath:indexPath];
//        if (tc.selected) {
//            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            [_filesSelectedArr removeObject:[_filesArr objectAtIndex:indexPath.row]];
//        }else{
//            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
//            [_filesSelectedArr addObject:[_filesArr objectAtIndex:indexPath.row]];
//        }
        
        if([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark){
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
             [_filesSelectedArr removeObject:[_filesArr objectAtIndex:indexPath.row]];
        }else{
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            [_filesSelectedArr addObject:[_filesArr objectAtIndex:indexPath.row]];
        }
        _lblSelectCnt.hidden = NO;
        _lblSelectCnt.text = [NSString stringWithFormat:@"选择Choose：%d个文件Files",[_filesSelectedArr count]];
        
    }else{
        PDFViewController *gv = [[PDFViewController alloc] initWithNibName:nil bundle:nil];
        HgFiles *file = [_filesArr objectAtIndex:indexPath.row];
        
        file.viewedtime = [NSDate date];
        NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        
        NSString* docPath = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
        NSString *path = [NSString stringWithFormat:@"%@/%@/%@",docPath,[_menuNameArr objectAtIndex:[file.dirname intValue]] ,file.filename];
        if ([file.dirname intValue]==0) {
            path = [NSString stringWithFormat:@"%@/%@",docPath,file.filename];
        }
        gv.filename = path;
        gv.island = _island;
        [self.navigationController pushViewController:gv animated:YES];
    }
    

}

@end
