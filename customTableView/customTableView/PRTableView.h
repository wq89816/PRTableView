//
//  PRTableView.h
//  customTableView
//
//  Created by tanjk on 15/10/14.
//  Copyright (c) 2015年 iFunia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PRTableView;

@protocol PRTableViewDelegate <NSObject>
@optional
-(void)selectedChanged:(PRTableView *)sender;
@end

@protocol PRTableViewDataSource <NSObject>
-(NSUInteger)numberOfItems:(PRTableView *)sender;
-(NSString *)objectValueAtRow:(NSUInteger)rowIndex withColumnIdentifier:(NSString *)identifer tableView:(PRTableView *)sender;

@optional
/*NSOnState, NSOffState, NSMixedState**/
-(NSInteger)checkStateAtRow:(NSUInteger)rowIndex tableView:(PRTableView *)sender;
-(void)writeCheckState:(NSInteger)state atRow:(NSUInteger)rowIndex tableView:(PRTableView *)sender;
-(NSImage *)leadImageAtRow:(NSUInteger)rowIndex tableView:(PRTableView *)sender;

@end

#pragma mark PRTableColumn
@interface PRTableColumn: NSObject
-(id)initWithIdentifer:(NSString *)identifer;
-(id)initWithIdentifer:(NSString *)identifer width:(CGFloat)w;
@property(readwrite) NSString* title;
@property(readwrite) CGFloat width;
@property(readonly) NSString *identifer;
@end

@interface PRTableView : NSView
#pragma mark Colomn method
-(void)addColumn:(PRTableColumn *)cln;
-(void)removeColumnByIdentfier:(NSString *)identifer;
-(void)removeColumn:(PRTableColumn *)cln;
-(PRTableColumn *)columnWithIdentifer:(NSString *)identifer;
-(void)clearColumn;

#pragma mark common perporty
@property(readwrite) id<PRTableViewDataSource> dataSource;
@property(readwrite) id<PRTableViewDelegate> delegate;
@property(readwrite) CGFloat rowHeight;
@property(readwrite) CGFloat headerHeight;
@property(readwrite) BOOL useCheckSelected;
@property(readwrite) BOOL useMixedCheckState;
@property(readwrite) BOOL useLeadImageface;
/*only effect mouse click*/
@property(readwrite) BOOL canMultiSelected;
-(NSIndexSet *)rowsOfCheckSelected;
-(NSIndexSet *)rowsOfMouseSelected;

#pragma mark refresh Data
-(void)reloadData;
@end
