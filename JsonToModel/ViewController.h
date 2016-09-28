//
//  MasterViewController.h
//  JsonToModel
//
//  Created by 孙宇 on 16/8/1.
//  Copyright © 2016年 孙宇. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController


@property (weak) IBOutlet NSScrollView *sourceTextView;

/**
 *  modelmingcehng
 */
@property (weak) IBOutlet NSTextField *modelName;

/**
 *  创建按钮
 */
@property (weak) IBOutlet NSButton *createButton;

/**
 *  来源列表
 */
@property (weak) IBOutlet NSTableView *sourceList;
//@property (weak) IBOutlet NSTableView *sourceList;

/**
 *  YYModel模式
 */
@property (weak) IBOutlet NSButton *YYModelBtn;

/**
 *  KVC模式
 */
@property (weak) IBOutlet NSButton *KVCBtn;

/**
 *  JSModel模式
 */
@property (weak) IBOutlet NSButton *JSModelBtn;

/**
 *  只取字段
 */
@property (weak) IBOutlet NSButton *columnBtn;

/**
 *  强制调控按钮（默认为打开，不建议关闭）
 */
@property (weak) IBOutlet NSButton *NullBtn;
@property (weak) IBOutlet NSButton *NSNumberBtn;
@property (weak) IBOutlet NSButton *NSDateBtn;

@end
