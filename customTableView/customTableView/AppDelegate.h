//
//  AppDelegate.h
//  customTableView
//
//  Created by tanjk on 15/10/14.
//  Copyright (c) 2015年 iFunia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PRTableView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, PRTableViewDataSource, PRTableViewDelegate>

@property(assign) IBOutlet PRTableView *tableView;
-(IBAction)showCheckState:(id)sender;
-(IBAction)showLeadImage:(id)sender;
@end

