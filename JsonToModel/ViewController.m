//
//  MasterViewController.m
//  JsonToModel
//
//  Created by 孙宇 on 16/8/1.
//  Copyright © 2016年 孙宇. All rights reserved.
//

#import "ViewController.h"
#import "JSONFineTuningCellModel.h"
#import "JSONSourceCellModel.h"
#import "JSONTypeCellModel.h"
#import "SYSourceListCell.h"
#import "ZHFileManager.h"
#import "AFNetworking.h"
#import "CreatPropert.h"

@interface ViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) NSString *dataString;

@property (nonatomic,strong)NSMutableArray *dataArr;

@property (nonatomic,assign)BOOL fold;
@property (nonatomic,assign)BOOL isPost;

@property (nonatomic,retain)NSDictionary *dict;
@property (nonatomic,retain)NSArray *arr;

@property (nonatomic,copy)NSString *filePath;
@property (nonatomic,copy)NSString *savaPath;

@end

@implementation ViewController

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr=[NSMutableArray array];
    }
    return _dataArr;
}

- (void)setData{
    
    [self.dataArr removeAllObjects];
    
    NSArray *sources=@[@"url",@"json字符串",@"plist文件"];
    NSMutableArray *JSONSourceModels=[NSMutableArray array];
    for (NSInteger i=0; i<sources.count; i++) {
        JSONSourceCellModel *JSONSourceModel=[JSONSourceCellModel new];
        JSONSourceModel.title=sources[i];
        [JSONSourceModels addObject:JSONSourceModel];
    }
    [self.dataArr addObject:JSONSourceModels];
    
    
    JSONTypeCellModel *JSONTypeModel=[JSONTypeCellModel new];
    JSONTypeModel.selectIndex=3;
    [self.dataArr addObject:@[JSONTypeModel]];
    
    NSArray *fineTunings=@[@"NSNull转NSString",@"NSNumber转NSString",@"NSDate转NSString"];
    NSMutableArray *JSONFineTuningModels=[NSMutableArray array];
    for (NSInteger i=0; i<fineTunings.count; i++) {
        JSONFineTuningCellModel *JSONFineTuningModel=[JSONFineTuningCellModel new];
        JSONFineTuningModel.title=fineTunings[i];
        JSONFineTuningModel.row=i+1;
        JSONFineTuningModel.isSelect=YES;
        [JSONFineTuningModels addObject:JSONFineTuningModel];
    }
    [self.dataArr addObject:JSONFineTuningModels];
    
    fineTunings=@[@"自动归档"];
    JSONFineTuningModels=[NSMutableArray array];
    for (NSInteger i=0; i<fineTunings.count; i++) {
        JSONFineTuningCellModel *JSONFineTuningModel=[JSONFineTuningCellModel new];
        JSONFineTuningModel.title=fineTunings[i];
        JSONFineTuningModel.row=i+1;
        JSONFineTuningModel.isSelect=YES;
        [JSONFineTuningModels addObject:JSONFineTuningModel];
    }
    [self.dataArr addObject:JSONFineTuningModels];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self setData];
    
    self.sourceList.delegate = self;
    self.sourceList.dataSource = self;
    
}

#pragma mark - NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (self.dataArr.count == 0) {
        return 0;
    }
    return [self.dataArr[0] count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 20;
}



- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    JSONSourceCellModel *modelObjct=self.dataArr[0][row];
    
    static NSString *indentifier = @"left";
    SYSourceListCell *cell = [tableView makeViewWithIdentifier:indentifier owner:self];
        
    cell.textField.stringValue = modelObjct.title;
    
    if (modelObjct.isSelect) {
        cell.textField.textColor = [NSColor greenColor];
    }else{
        cell.textField.textColor = [NSColor blackColor];
    }
    
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableView = notification.object;
    
    for (NSInteger i = 0; i < [self.dataArr[0] count]; i++) {
        BOOL isSelect = [tableView isRowSelected:i];
        JSONSourceCellModel *modelObjct=self.dataArr[0][i];
        
        modelObjct.isSelect = isSelect;
        
        if (isSelect) {
            JSONSourceCellModel *model=modelObjct;
            
            __block NSTextView *textView = _sourceTextView.documentView;
            
            __block NSString *message = @"请添加源数据";
            if([model.title isEqualToString:@"url"]){
                message = @"请把 网络url 填写在输入框中";
            }else if([model.title isEqualToString:@"json字符串"]){
                message = @"请把 json字符串 填写在输入框中";
            }else if([model.title isEqualToString:@"plist文件"]){
                message = @"请把 plist文件路径 填写在输入框中";
            }
            
            if (textView.string.length == 0) {
                NSAlert *alert = [[NSAlert alloc]init];
                alert.messageText = message;
                [alert addButtonWithTitle:@"确定"];
                [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
                }];
            }else {
                NSString *text = [textView.string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [self checkData:text withType:message];
            }
            
        }
    }
}


- (void)checkData:(NSString *)data withType:(NSString *)type
{
    if([type rangeOfString:@"json"].location!=NSNotFound){
        //检验这个json格式数据
        NSString *strJson=data;
        NSDictionary *dictTemp;
        NSArray *arrTemp;
        dictTemp=[NSJSONSerialization JSONObjectWithData:[strJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if(dictTemp==nil){
            arrTemp=[NSJSONSerialization JSONObjectWithData:[strJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            if(arrTemp==nil){
                [self showAlertWithText:@"Json数据有误"];
                return;
            }
        }
        for (JSONSourceCellModel * JSONSourceModel in self.dataArr[0]) {
            if ([JSONSourceModel.title isEqual:@"json字符串"]) {
                JSONSourceModel.isSelect=YES;
            }else{
                JSONSourceModel.isSelect=NO;
            }
        }
        _dataString = data;
    }else if([type rangeOfString:@"plist"].location!=NSNotFound){
        //检验这个plist文件路径
        if ([ZHFileManager fileExistsAtPath:data]==NO) {
            [self showAlertWithText:@"plist文件路径不存在!"];
            return;
        }
        for (JSONSourceCellModel * JSONSourceModel in self.dataArr[0]) {
            if ([JSONSourceModel.title isEqual:@"plist文件"]) {
                JSONSourceModel.isSelect=YES;
            }else{
                JSONSourceModel.isSelect=NO;
            }
        }
        _dataString = data;
    }
    
    
    if ([type rangeOfString:@"url"].location!=NSNotFound) {
        
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"选择请求方式";
        [alert addButtonWithTitle:@"GET"];
        [alert addButtonWithTitle:@"POST"];
        [alert addButtonWithTitle:@"取消"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            
            NSLog(@"%ld", returnCode);
            switch (returnCode) {
                case 1001:  //POST
                {
                    //POST
                    self.isPost=YES;
                    for (JSONSourceCellModel * JSONSourceModel in self.dataArr[0]) {
                        if ([JSONSourceModel.title isEqual:@"url"]) {
                            JSONSourceModel.isSelect=YES;
                        }else{
                            JSONSourceModel.isSelect=NO;
                        }
                    }
                    [self.sourceList reloadData];
                }
                    break;
                case 1000:  //GET
                {
                    //GET
                    self.isPost=NO;
                    for (JSONSourceCellModel * JSONSourceModel in self.dataArr[0]) {
                        if ([JSONSourceModel.title isEqual:@"url"]) {
                            JSONSourceModel.isSelect=YES;
                        }else{
                            JSONSourceModel.isSelect=NO;
                        }
                    }
                    [self.sourceList reloadData];
                }
                    break;
            }
            
        }];
        _dataString = data;
        
    }else{
        [self.sourceList reloadData];
    }
}


#pragma mark --相关操作函数
- (void)JsonAction:(NSString *)JsonDataStr NSNULL:(BOOL)NSNULL NSNUMBER:(BOOL)NSNUMBER NSDATE:(BOOL)NSDATE guidang:(BOOL)guidang{
    //判断保存路径是否存在
    if(self.savaPath.length>0){
        //判断用户是否直接保存到了桌面
        if([self.savaPath isEqualToString:[NSHomeDirectory() stringByAppendingString:@"/Desktop/"]]||[self.savaPath isEqualToString:[NSHomeDirectory() stringByAppendingString:@"/Desktop"]]){
            [self showAlertWithText:@"请不要文件直接存在桌面上!"];
            return;
        }
        if([self.savaPath hasSuffix:@"/"]==NO){
            NSString *tmp=self.savaPath;
            self.savaPath=[tmp stringByAppendingString:@"/"];
        }
        NSString *strJson=JsonDataStr;
        _dict=[NSJSONSerialization JSONObjectWithData:[strJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if(_dict==nil){
            _arr=[NSJSONSerialization JSONObjectWithData:[strJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            if(_arr==nil){
                [self showAlertWithText:@"Json数据有误"];
                return;
            }
        }
        [self succeesNSNULL:NSNULL NSNUMBER:NSNUMBER NSDATE:NSDATE guidang:guidang];
        if(_dict!=nil){
            [self JsonToPlistWithFilePath:self.filePath withDicOrArr:_dict];
        }else if(_arr!=nil){
            [self JsonToPlistWithFilePath:self.filePath withDicOrArr:_arr];
        }
    }else{
        [self showAlertWithText:@"保存路径不能为空"];
    }
    [self removeData];
}

- (void)localFileToModelWithFilePath:(NSString *)filePath NSNULL:(BOOL)NSNULL NSNUMBER:(BOOL)NSNUMBER NSDATE:(BOOL)NSDATE guidang:(BOOL)guidang{
    //删除原先的文件夹
    [self deleteOldDirectory];
    
    //判断保存路径是否存在
    if(self.savaPath.length>0){
        //判断用户是否直接保存到了桌面
        if([self.savaPath isEqualToString:[NSHomeDirectory() stringByAppendingString:@"/Desktop/"]]||[self.savaPath isEqualToString:[NSHomeDirectory() stringByAppendingString:@"/Desktop"]]){
            [self showAlertWithText:@"请不要文件直接存在桌面上!"];
            return;
        }
        if([self.savaPath hasSuffix:@"/"]==NO){
            NSString *tmp=self.savaPath;
            self.savaPath=[tmp stringByAppendingString:@"/"];
        }
        _dict=[NSDictionary dictionaryWithContentsOfFile:filePath];;
        if(_dict==nil){
            _arr=[NSArray arrayWithContentsOfFile:filePath];
            if(_arr==nil){
                [self showAlertWithText:@"Json数据有误"];
                return;
            }
        }
        [self succeesNSNULL:NSNULL NSNUMBER:NSNUMBER NSDATE:NSDATE guidang:guidang];
        if(_dict!=nil){
            [self JsonToPlistWithFilePath:self.filePath withDicOrArr:_dict];
        }else if(_arr!=nil){
            [self JsonToPlistWithFilePath:self.filePath withDicOrArr:_arr];
        }
    }else{
        [self showAlertWithText:@"保存路径不能为空"];
    }
    [self removeData];
}

- (void)auto_creat:(NSString *)url NSNULL:(BOOL)NSNULL NSNUMBER:(BOOL)NSNUMBER NSDATE:(BOOL)NSDATE guidang:(BOOL)guidang{
    
    if([self judgURL:url]==NO){
        [self showAlertWithText:@"网址存在%?控制符"];
        return;
    }
    //判断保存路径是否存在
    if(self.savaPath.length>0){
        //判断用户是否直接保存到了桌面
        if([self.savaPath isEqualToString:[NSHomeDirectory() stringByAppendingString:@"/Desktop/"]]||[self.savaPath isEqualToString:[NSHomeDirectory() stringByAppendingString:@"/Desktop"]]){
            [self showAlertWithText:@"请不要文件直接存在桌面上"];
            return;
        }
        if([self.savaPath hasSuffix:@"/"]==NO){
            NSString *tmp=self.savaPath;
            self.savaPath=[tmp stringByAppendingString:@"/"];
        }
        
        //GET请求
        if (self.isPost==NO) {
            //开始请求数据
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSString *chineseUrl=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            //GET请求
            [manager GET:chineseUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                _dict=responseObject;
                if([responseObject isKindOfClass:[NSDictionary class]]){
                    _dict=responseObject;
                    if(_dict==nil){
                        [self showAlertWithText:@"请求的网路数据有误"];
                        return ;
                    }
                }
                else if([responseObject isKindOfClass:[NSArray class]]){
                    _arr=responseObject;
                    if(_arr==nil){
                        [self showAlertWithText:@"请求的网路数据有误"];
                        return ;
                    }
                }
                [self succeesNSNULL:NSNULL NSNUMBER:NSNUMBER NSDATE:NSDATE guidang:guidang];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self showAlertWithText:@"请检查网址"];
                return;
            }];
        }
        //POST请求
        else if (self.isPost==YES){
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            if ([url rangeOfString:@"?"].location!=NSNotFound) {
                NSString *realUrl=[url substringToIndex:[url rangeOfString:@"?"].location];
                NSString *chineseUrl=[realUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *parameters=[self getDicParameters:[url substringFromIndex:[url rangeOfString:@"?"].location+1]];
                //POST请求
                [manager POST:chineseUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    _dict=responseObject;
                    if([responseObject isKindOfClass:[NSDictionary class]]){
                        _dict=responseObject;
                        if(_dict==nil){
                            [self showAlertWithText:@"请求的网路数据有误"];
                            return ;
                        }
                    }
                    else if([responseObject isKindOfClass:[NSArray class]]){
                        _arr=responseObject;
                        if(_arr==nil){
                            [self showAlertWithText:@"请求的网路数据有误"];
                            return ;
                        }
                    }
                    [self succeesNSNULL:NSNULL NSNUMBER:NSNUMBER NSDATE:NSDATE guidang:guidang];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [self showAlertWithText:@"请检查网址"];
                    return;
                }];
            }else{
                NSString *chineseUrl=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                //GET请求
                [manager GET:chineseUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    _dict=responseObject;
                    if([responseObject isKindOfClass:[NSDictionary class]]){
                        _dict=responseObject;
                        if(_dict==nil){
                            [self showAlertWithText:@"请求的网路数据有误"];
                            return ;
                        }
                    }
                    else if([responseObject isKindOfClass:[NSArray class]]){
                        _arr=responseObject;
                        if(_arr==nil){
                            [self showAlertWithText:@"请求的网路数据有误"];
                            return ;
                        }
                    }
                    [self succeesNSNULL:NSNULL NSNUMBER:NSNUMBER NSDATE:NSDATE guidang:guidang];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [self showAlertWithText:@"请检查网址"];
                    return;
                }];
            }
        }
        
    }else{
        [self showAlertWithText:@"保存路径不能为空"];
    }
    [self removeData];
}


- (void)JsonToPlistWithFilePath:(NSString *)FilepPath withDicOrArr:(id)dicOrArr{
    NSFileManager *fm=[NSFileManager defaultManager];
    [fm createFileAtPath:FilepPath contents:nil attributes:nil];
    if([fm fileExistsAtPath:FilepPath]){
        if([dicOrArr isKindOfClass:[NSArray class]]){
            NSArray *arr=(NSArray *)dicOrArr;
            [arr writeToFile:FilepPath atomically:YES];
        }else if([dicOrArr isKindOfClass:[NSDictionary class]]){
            NSDictionary *dicM=(NSDictionary *)dicOrArr;
            [dicM writeToFile:FilepPath atomically:YES];
        }
    }
}

- (BOOL)exsistStr:(NSString *)str InURL:(NSString *)url{
    if([url rangeOfString:str].location!=NSNotFound)
        return YES;
    else return NO;
}
- (BOOL)judgURL:(NSString *)url{
    if([self exsistStr:@"%d" InURL:url]||[self exsistStr:@"%s" InURL:url]||[self exsistStr:@"%c" InURL:url]||[self exsistStr:@"%f" InURL:url]||[self exsistStr:@"%hhd" InURL:url]||[self exsistStr:@"%ld" InURL:url])//等等,可以加
        return NO;
    return YES;
}
- (NSDictionary *)getDicParameters:(NSString *)Parameters{
    //例如:   username=ceshi&password=123456
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    
    NSArray *parametersArr=[Parameters componentsSeparatedByString:@"&"];
    
    for (NSString *eachParameters in parametersArr) {
        NSArray *subParametersArr=[eachParameters componentsSeparatedByString:@"="];
        [dicM setValue:subParametersArr[1] forKey:subParametersArr[0]];
    }
    NSLog(@"dicM=%@",dicM);
    return dicM;
}

- (void) deleteOldDirectory{
    //删除原先的文件夹
    BOOL yes=YES;
    if([[NSFileManager defaultManager]fileExistsAtPath:self.savaPath isDirectory:&yes]){
        [[NSFileManager defaultManager]removeItemAtPath:self.savaPath error:nil];
    }
}
- (void)succeesNSNULL:(BOOL)NSNULL NSNUMBER:(BOOL)NSNUMBER NSDATE:(BOOL)NSDATE guidang:(BOOL)guidang{
    if(_dict!=nil){
        //删除原先的文件夹
        [self deleteOldDirectory];
        [CreatPropert clearTextWithModelName:self.modelName.stringValue withGiveData:[self returnModelTypeNSInteger]];
        [CreatPropert creatProperty:_dict fileName:self.modelName.stringValue WithContext:@"" savePath:self.savaPath withNSNULL:NSNULL withNSDATE:NSDATE withNSNUMBER:NSNUMBER withGiveData:[self returnModelTypeNSInteger] withModelName:self.modelName.stringValue withFatherClass:@"" needEcoding:guidang];
        [CreatPropert saveTextWithModelName:self.modelName.stringValue savePath:self.savaPath];
        [self showAlertWithText:@"生成成功,请打开文件夹"];
        [self JsonToPlistWithFilePath:self.filePath];
    }
    else if(_arr!=nil){
        //删除原先的文件夹
        [self deleteOldDirectory];
        [CreatPropert clearTextWithModelName:self.modelName.stringValue withGiveData:[self returnModelTypeNSInteger]];
        [CreatPropert creatProperty:_arr fileName:self.modelName.stringValue WithContext:@"" savePath:self.savaPath withNSNULL:NSNULL withNSDATE:NSDATE withNSNUMBER:NSNUMBER withGiveData:[self returnModelTypeNSInteger] withModelName:self.modelName.stringValue withFatherClass:@"" needEcoding:guidang];
        [CreatPropert saveTextWithModelName:self.modelName.stringValue savePath:self.savaPath];
        [self showAlertWithText:@"生成成功,请打开文件夹"];
        [self JsonToPlistWithFilePath:self.filePath];
    }
    else [self showAlertWithText:@"生成失败"];
    
    //    [FMDBCreat writeToFileWithFilePath:self.savaPath];
}

- (NSInteger)returnModelTypeNSInteger{
    JSONTypeCellModel * JSONSourceModel=self.dataArr[1][0];
    return JSONSourceModel.selectIndex+1;
}

- (void)JsonToPlistWithFilePath:(NSString *)FilepPath{
    NSFileManager *fm=[NSFileManager defaultManager];
    [fm createFileAtPath:FilepPath contents:nil attributes:nil];
    if ([fm fileExistsAtPath:FilepPath]) {
        if (_dict!=nil) {
            NSMutableDictionary *temp_dic=[NSMutableDictionary dictionaryWithDictionary:_dict];
            [[self getUseableObjectWithOldObject:temp_dic] writeToFile:FilepPath atomically:YES];
        }else if(_arr!=nil){
            NSMutableArray *temp_arr=[NSMutableArray arrayWithArray:_arr];
            [[self getUseableObjectWithOldObject:temp_arr] writeToFile:FilepPath atomically:YES];
        }
    }
}

/**因为有的字段为NULL导致数组或者字典不能正常的保存*/
- (id)getUseableObjectWithOldObject:(id)oldObj{
    
    if([oldObj isKindOfClass:[NSDictionary class]]){//如果obj对象是字典
        oldObj=[NSMutableDictionary dictionaryWithDictionary:oldObj];
        id objtemp;
        for (NSInteger i=0; i<[oldObj allKeys].count; i++) {//开始遍历字典里面的键值对
            objtemp=[oldObj allKeys][i];
            
            if ([oldObj[objtemp] isKindOfClass:[NSString class]]) {
                if (((NSString *)oldObj[objtemp]).length==0) {
                    [oldObj setValue:@"" forKey:objtemp];
                }
            }
            else if([oldObj[objtemp] isKindOfClass:[NSArray class]]){//如果字典里面是数组
                
                oldObj[objtemp]=[self getUseableObjectWithOldObject:oldObj[objtemp]];
            }
            else if ([oldObj[objtemp] isKindOfClass:[NSDictionary class]]){//如果字典里面是字典
                oldObj[objtemp]=[self getUseableObjectWithOldObject:oldObj[objtemp]];
            }
            else if ([oldObj[objtemp] isKindOfClass:[NSNull class]]){//如果字典里面是nsnull
                [oldObj setValue:@"" forKey:objtemp];
            }
            else if([oldObj[objtemp] isKindOfClass:[NSData class]]){//如果字典里面是NSData
                [oldObj setValue:@"NSData" forKey:objtemp];
            }
            else if([oldObj[objtemp] isKindOfClass:[NSDate class]]){//如果字典里面是NSDate
                [oldObj setValue:[NSString stringWithFormat:@"NSDate:%@",oldObj[objtemp]] forKey:objtemp];
                
            }
        }
    }
    else if([oldObj isKindOfClass:[NSArray class]]){//如果obj对象是数组
        oldObj=[NSMutableArray arrayWithArray:oldObj];
        id objtemp;
        for (NSInteger i=0; i<[oldObj count]; i++) {
            @autoreleasepool {
                objtemp=oldObj[i];
                objtemp=[self getUseableObjectWithOldObject:objtemp];
            }
        }
    }
    return oldObj;
}

- (void)removeData{
    self.arr=[NSArray array];
    self.dict=[NSDictionary dictionary];
}

- (NSString *)getCurDateString{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH时mm分ss秒"];
    return [formatter stringFromDate:[NSDate date]];
}



- (void)showAlertWithText:(NSString *)messageText
{
    NSAlert *alert = [[NSAlert alloc]init];
    alert.messageText = messageText;
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
    }];
}


/**
 *  创建按钮事件
 */
- (IBAction)onCreateClick:(id)sender {
    
    if (self.modelName.stringValue.length<=0) {
        [self showAlertWithText:@"请填写model的名字"];
        return;
    }
    
    NSInteger selectIndex=-1;
    NSInteger index=0;
    for (JSONSourceCellModel * JSONSourceModel in self.dataArr[0]) {
        if (JSONSourceModel.isSelect) {
            selectIndex=index;
            break;
        }
        index++;
    }
    
    if (selectIndex==-1) {
        [self showAlertWithText:@"请选择数据来源"];
        return;
    }
    
    //加载一些初始化数据
    NSString *macPath=[ZHFileManager getMacDesktop];
    NSString *fileDirectory=[self getCurDateString];
    fileDirectory = [fileDirectory stringByAppendingString:@"代码生成"];
    macPath = [macPath stringByAppendingPathComponent:fileDirectory];
    self.filePath=[macPath stringByAppendingPathComponent:[self.modelName.stringValue stringByAppendingString:@".plist"]];
    self.savaPath=macPath;
    
    self.arr=[NSArray array];
    self.dict=[NSDictionary dictionary];
    
    BOOL NSNULL,NSNUMBER,NSDATE,guidang;
    JSONFineTuningCellModel *model_NSNULL=self.dataArr[2][0];
    NSNULL=model_NSNULL.isSelect;
    JSONFineTuningCellModel *model_NSNUMBER=self.dataArr[2][1];
    NSNUMBER=model_NSNUMBER.isSelect;
    JSONFineTuningCellModel *model_NSDATE=self.dataArr[2][2];
    NSDATE=model_NSDATE.isSelect;
    
    JSONFineTuningCellModel *model_guidang=self.dataArr[3][0];
    guidang=model_guidang.isSelect;
    
    if (selectIndex==0) {//url
        [self auto_creat:_dataString NSNULL:NSNULL NSNUMBER:NSNUMBER NSDATE:NSDATE guidang:guidang];
    }else if (selectIndex==1){//json
        [self JsonAction:_dataString NSNULL:NSNULL NSNUMBER:NSNUMBER NSDATE:NSDATE guidang:guidang];
    }else if(selectIndex==2){//plist
        [self localFileToModelWithFilePath:_dataString NSNULL:NSNULL NSNUMBER:NSNUMBER NSDATE:NSDATE guidang:guidang];
    }
    
}


/**
 *  生成模式按钮事件
 *
 *  @param sender MVC 100  JSModel 101  字符 102   YYModel 103
 */
- (IBAction)onPatternClick:(id)sender {
    
    for (NSInteger i = 0; i < 4; i++) {
        NSButton *button = [self.view viewWithTag:i+100];
        button.state = 0;
    }
    
    NSButton *button = sender;
    button.state = 1;
    
    JSONTypeCellModel *model = self.dataArr[1][0];
    model.selectIndex = button.tag-100;
}

/**
 *  强转调控按钮点击事件
 */
- (IBAction)onNullToNSStringClick:(id)sender {
    NSButton *button = sender;
    JSONFineTuningCellModel *model = self.dataArr[2][0];
    model.isSelect = button.state;
}
- (IBAction)onNSNumberToNSStringClick:(id)sender {
    NSButton *button = sender;
    JSONFineTuningCellModel *model = self.dataArr[2][1];
    model.isSelect = button.state;
}
- (IBAction)onNSDateToNSStringClick:(id)sender {
    NSButton *button = sender;
    JSONFineTuningCellModel *model = self.dataArr[2][2];
    model.isSelect = button.state;
}

/**
 *  自动归档按钮事件
 */
- (IBAction)onArchiveClick:(id)sender {
    
    JSONFineTuningCellModel *model = self.dataArr[3][0];
    model.isSelect = [sender state];
}

@end
