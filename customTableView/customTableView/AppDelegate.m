//
//  AppDelegate.m
//  customTableView
//
//  Created by tanjk on 15/10/14.
//  Copyright (c) 2015年 iFunia. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

#pragma mark NSApplicationDelegate
-(void)configTableview
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    PRTableColumn *cln = [[PRTableColumn alloc] initWithIdentifer:@"column title 1" width:100.0f];
    cln.title = @"title 1";
    [self.tableView addColumn:cln];
    
    cln = [[PRTableColumn alloc] initWithIdentifer:@"column title 2"];
    cln.title = @"title 2";
    [self.tableView addColumn:cln];
    
    cln = [[PRTableColumn alloc] initWithIdentifer:@"column title 3"];
    cln.title = @"title 3";
    [self.tableView addColumn:cln];
    
    cln = [[PRTableColumn alloc] initWithIdentifer:@"column title 4"];
    cln.title = @"title 4";
    [self.tableView addColumn:cln];
    
    
    cln = [[PRTableColumn alloc] initWithIdentifer:@"column title 5"];
    cln.title = @"title 5";
    [self.tableView addColumn:cln];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [self configTableview];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


-(IBAction)showCheckState:(id)sender
{
    if([sender state] == NSOnState)
        self.tableView.useCheckSelected = YES;
    else
        self.tableView.useCheckSelected = NO;
}

-(IBAction)showLeadImage:(id)sender
{
    if([sender state] == NSOnState)
        self.tableView.useLeadImageface = YES;
    else
        self.tableView.useLeadImageface = NO;
}

#pragma mark PRTableViewDataSource
-(NSUInteger)numberOfItems:(PRTableView *)sender
{
    return 10000000;
}

-(NSString *)objectValueAtRow:(NSUInteger)rowIndex withColumnIdentifier:(NSString *)identifer tableView:(PRTableView *)sender
{
    return @"Custom tableview";
}

/*NSOnState, NSOffState, NSMixedState**/
-(NSInteger)checkStateAtRow:(NSUInteger)rowIndex tableView:(PRTableView *)sender
{
    switch (rowIndex%2) {
        case 0: return NSOnState;
        case 1: return NSOffState;
        default: return NSMixedState;
    }
}

-(void)writeCheckState:(NSInteger)state atRow:(NSUInteger)rowIndex tableView:(PRTableView *)sender
{
    //write state to datasource
}

-(NSImage *)leadImageAtRow:(NSUInteger)rowIndex tableView:(PRTableView *)sender
{
    return [NSImage imageNamed:@"imgLead.png"];
}

#pragma mark PRTableviewDelegate
-(void)selectedChanged:(PRTableView *)sender
{
    //
}
@end
