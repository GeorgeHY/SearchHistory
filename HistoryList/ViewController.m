//
//  ViewController.m
//  HistoryList
//
//  Created by GE on 16/1/5.
//  Copyright © 2016年 GE. All rights reserved.
//

#import "ViewController.h"
#import "Model_HisWord.h"

@interface ViewController () <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UIView * searchView;

@property (nonatomic, strong) UITextField * inputTF;

@property (nonatomic, strong) UIButton * searchBtn;

@property (nonatomic, strong) UITableView * hisTV;

@property (nonatomic, strong) NSMutableArray * hisArr;

@property (nonatomic, strong) NSMutableArray * hisDicArr;

@property (nonatomic, strong) NSMutableDictionary * plistData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hisArr = [NSMutableArray array];
    self.hisDicArr = [NSMutableArray array];
    [self getData];
    [self createUI];
    
    
    
}

- (void)getData
{
    //获取历史记录数据
    [self.hisArr  removeAllObjects];
    if ([self judgeFileExist:@"SearchHistory.plist"]) {
        NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [documents stringByAppendingPathComponent:@"SearchHistory.plist"];
        self.plistData = [[NSDictionary dictionaryWithContentsOfFile:path] mutableCopy];
    
        NSLog(@"%@",self.hisArr);
        
        if ([self.plistData objectForKey:@"history"] != nil) {
            self.hisDicArr = [self.plistData objectForKey:@"history"];
            for (NSMutableDictionary * wordDic in self.hisDicArr) {
                Model_HisWord * model = [Model_HisWord changDicToHisWord:wordDic];
                [self.hisArr addObject:model];
                
            }
//
            NSArray * tempArr = [[self.hisArr sortedArrayUsingSelector:@selector(compare:)]mutableCopy];
//            self.hisArr = [[arr sortedArrayUsingSelector:@selector(compare:)]mutableCopy];
            self.hisArr = [tempArr mutableCopy];
            NSLog(@"排序后=%@",self.hisArr);
            //        NSSet * hisSet = [NSSet setWithArray:self.hisArr];
            //
            //        [self.hisArr removeAllObjects];
            //        [self.hisArr addObjectsFromArray:[hisSet allObjects]];
//            //        [self changeArray:self.hisArr orderWithKey:nil ascending:YES];
        }
        [self.hisTV reloadData];
    }else{
        //文件不存在
        NSArray *storeFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *doucumentsDirectiory = [storeFilePath objectAtIndex:0];
        NSString *plistPath =[doucumentsDirectiory stringByAppendingPathComponent:@"SearchHistory.plist"];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchHistory"ofType:@"plist"];
         NSMutableDictionary *activityDics = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
         [activityDics writeToFile:plistPath atomically:YES];
    }
    
    
//    NSLog(@"%@",self.hisArr);
}

- (void)createUI
{
    self.searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 50)];
    
    //输入框
    self.inputTF = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, [UIScreen mainScreen].bounds.size.width - 40 - 40, 30)];
    self.inputTF.delegate = self;
    self.inputTF.layer.borderWidth = 1;
    self.inputTF.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.inputTF.placeholder = @"请输入搜索内容";
    self.inputTF.returnKeyType = UIReturnKeyDone;
    [self.searchView addSubview:self.inputTF];
    
    
    //放大镜按钮
    self.searchBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.inputTF.frame) + 10, 10, 30, 30)];
//    self.searchBtn.backgroundColor = [UIColor redColor];
    [self.searchBtn setImage:[UIImage imageNamed:@"ic_search_small"] forState:UIControlStateNormal];
    self.searchBtn.layer.masksToBounds = YES;
    self.searchBtn.layer.cornerRadius = 2;
    self.searchBtn.layer.borderWidth = 1;
    self.searchBtn.layer.borderColor = [[UIColor blueColor]CGColor];
    [self.searchBtn addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.searchView addSubview:self.searchBtn];
    
    [self.view addSubview:self.searchView];
    
    //历史记录tableview
    self.hisTV = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchView.frame), [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - CGRectGetMaxY(self.searchView.frame))];
    self.hisTV.delegate = self;
    self.hisTV.dataSource = self;
    [self.view addSubview:self.hisTV];
    self.hisTV.hidden = YES;
    /**
     开始隐藏，当输入框称为第一响应者是显示
     有字体输入后继续隐藏
     */
    
}

- (void)searchAction
{
    NSLog(@"搜索");
    if ([@"" isEqualToString:self.inputTF.text]) {
        NSLog(@"请输入文字");
    }else{
        //去重
        
        int duplicateIndex = 999;
        
        for (NSMutableDictionary * hisWordDic in self.hisDicArr) {
            
            Model_HisWord * hisWord = [Model_HisWord changDicToHisWord:hisWordDic];
            
            if ([hisWord.word isEqualToString:self.inputTF.text]) {
                duplicateIndex = [self.hisDicArr indexOfObject:hisWordDic];
            }
        }
        
        if (duplicateIndex != 999) {
            [self.hisDicArr removeObjectAtIndex:duplicateIndex];
            
        }
        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *  nowStr = [formatter stringFromDate:[NSDate date]];
        NSLog(@"nowStr = %@",nowStr);
        Model_HisWord * lastWord = [Model_HisWord hisWordWithSearchDate:nowStr andWord:self.inputTF.text];
        [self.hisDicArr addObject:[lastWord changeModelToDic]];
        [self.hisTV reloadData];
        
        NSLog(@"%@",self.hisDicArr);
        
        

        
        //写入plist
        [self.plistData setObject:self.hisDicArr forKey:@"history"];

        NSString *home = NSHomeDirectory();
        NSString *documents = [home stringByAppendingPathComponent:@"Documents"];
//        NSLog(@"%@",documents);
        NSString *path = [documents stringByAppendingPathComponent:@"SearchHistory.plist"];
        
        [self.plistData writeToFile:path atomically:YES];

        
        
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //搜索历史显示
    [self getData];
    self.hisTV.hidden = NO;
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //开始搜索
    if ([@"" isEqualToString:textField.text]) {
        NSLog(@"请输入文字");
    }else{
        
        //去重
        int duplicateIndex = 999;
        
        for (NSMutableDictionary * hisWordDic in self.hisDicArr) {
            
            Model_HisWord * hisWord = [Model_HisWord changDicToHisWord:hisWordDic];
            
            if ([hisWord.word isEqualToString:self.inputTF.text]) {
                duplicateIndex = [self.hisDicArr indexOfObject:hisWordDic];
            }
        }
        
        if (duplicateIndex != 999) {
            [self.hisDicArr removeObjectAtIndex:duplicateIndex];
            
        }
        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *  nowStr = [formatter stringFromDate:[NSDate date]];
        NSLog(@"nowStr = %@",nowStr);
        Model_HisWord * lastWord = [Model_HisWord hisWordWithSearchDate:nowStr andWord:self.inputTF.text];
        [self.hisDicArr addObject:[lastWord changeModelToDic]];
        [self.hisTV reloadData];
        
        NSLog(@"%@",self.hisDicArr);

        //写入plist
        [self.plistData setObject:self.hisDicArr forKey:@"history"];

        NSString *home = NSHomeDirectory();
        NSString *documents = [home stringByAppendingPathComponent:@"Documents"];
//        NSLog(@"%@",documents);
        NSString *path = [documents stringByAppendingPathComponent:@"SearchHistory.plist"];
        
        [self.plistData writeToFile:path atomically:YES];

        
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //输入文字后历史记录隐藏
    self.hisTV.hidden = YES;
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.hisArr && self.hisArr.count > 0) {
        return self.hisArr.count + 1 ;
    }else{
        return 0;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
    }

    if (self.hisArr && self.hisArr.count >0) {
        if (indexPath.row == self.hisArr.count) {
            cell.contentView.backgroundColor = [UIColor redColor];
            
        }else{
            cell.contentView.backgroundColor = [UIColor whiteColor];
//            NSMutableDictionary * WordDic = self.hisDicArr[indexPath.row];
//            Model_HisWord * curWord = [Model_HisWord changDicToHisWord:WordDic];
            Model_HisWord * curWord = self.hisArr[indexPath.row];
            
            cell.textLabel.text = curWord.word;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //清空历史记录
    if (self.hisDicArr && self.hisDicArr.count >0) {
        if (indexPath.row == self.hisDicArr.count) {
            NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *path = [documents stringByAppendingPathComponent:@"SearchHistory.plist"];
            NSMutableDictionary * data = [[NSDictionary dictionaryWithContentsOfFile:path] mutableCopy];
            [data removeObjectForKey:@"history"];
            [self.hisDicArr removeAllObjects];
            [self.hisArr removeAllObjects];
            [data writeToFile:path atomically:YES];
            [self.hisTV reloadData];
        }
    }
}
#pragma mark - 数组排序
- (void) changeArray:(NSMutableArray *)dicArray orderWithKey:(NSString *)key ascending:(BOOL)yesOrNo{
    
    
    NSSortDescriptor *distanceDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:yesOrNo];

    NSArray *descriptors = [NSArray arrayWithObjects:distanceDescriptor,nil];
    
    [dicArray sortUsingDescriptors:descriptors];
    
    
    
}

#pragma mark - 判断文件是否存在
-(BOOL)judgeFileExist:(NSString * )fileName

{
    
    NSArray *storeFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doucumentsDirectiory = [storeFilePath objectAtIndex:0];
    NSString *plistPath =[doucumentsDirectiory stringByAppendingPathComponent:fileName];
    
    //获取文件路径
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if( [fileManager fileExistsAtPath:plistPath]== NO ) {
        NSLog(@"not exists");
        return NO;
    }else{
        return YES;
    }
}

@end
