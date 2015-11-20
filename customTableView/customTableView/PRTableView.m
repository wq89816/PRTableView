//
//  PRTableView.m
//  customTableView
//
//  Created by tanjk on 15/10/14.
//  Copyright (c) 2015年 iFunia. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "PRTableView.h"
static const CGFloat PRDefaultWidth=100.0f;
static const CGFloat PRDefaultHeight=100.f;
static const CGFloat PRDefaultMargin=8.0f;
static const CGFloat PRDefaultCheckStateWidth=20.0f;
static const CGFloat PRDefaultLeadImageWidth=28.0f;
static const CGFloat PRDefaultRowHeight=20.0f;
static const CGFloat PRDefaultHeaderHeight=30.0f;

#pragma mark PRTableColumn
@implementation PRTableColumn
{
    NSString *_identfier;
    NSString *_title;
    CGFloat _width;
}
@synthesize identifer=_identfier;
@synthesize title=_title;
@synthesize width=_width;

-(id)init
{
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd 'at' HH-mm-ss"];
    NSString *identifer = [NSString stringWithFormat:@"%@(%d)", [df stringFromDate:[NSDate date]], SSRandomIntBetween(1, 100)];
    return [self initWithIdentifer: identifer];
}

-(id)initWithIdentifer:(NSString *)identifer
{
    return [self initWithIdentifer:identifer width:PRDefaultWidth];
}

-(id)initWithIdentifer:(NSString *)identifer width:(CGFloat)w
{
    self = [super init];
    if(self){
        _identfier = identifer;
        _title = nil;
        _width = w;
    }
    return self;
}
@end

#pragma mark PRTableView
@implementation PRTableView
{
    NSMutableArray *_columns;
    
    BOOL _useCheckSelected;
    BOOL _canMultiSelected;
    CGFloat _rowHeight;
    CGFloat _headerHeight;
    BOOL _useLeadImageface;
    
    id<PRTableViewDelegate> _delegate;
    id<PRTableViewDataSource> _dataSource;
    
    NSMutableIndexSet *_rowsOfMouseSelected;
    
    NSImage *_imgForContentCache;
    NSImage *_imgForHeaderCache;
}

@synthesize dataSource=_dataSource;
@synthesize delegate=_delegate;
@synthesize useCheckSelected=_useCheckSelected;
@synthesize canMultiSelected=_canMultiSelected;
@synthesize rowHeight=_rowHeight;
@synthesize headerHeight=_headerHeight;
@synthesize useLeadImageface=_useLeadImageface;
-(void)variInit
{
    _useLeadImageface = YES;
    _canMultiSelected = YES;
    _rowHeight = PRDefaultRowHeight;
    _headerHeight = PRDefaultHeaderHeight;
}

-(id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self){
        [self variInit];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if(self){
        [self variInit];
    }
    return self;
}

-(id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if(self){
        [self variInit];
    }
    return self;
}

-(void)setDataSource:(id<PRTableViewDataSource>)ds
{
    if(ds != _dataSource){
        _dataSource = ds;
        [self reloadData];
    }
}

-(id<PRTableViewDataSource>)dataSource
{
    return _dataSource;
}

-(BOOL)useCheckSelected
{
    return _useCheckSelected;
}

-(void)setUseCheckSelected:(BOOL)use
{
    if(_useCheckSelected != use){
        _useCheckSelected = use;
        [self reloadData];
    }
}

-(BOOL)useLeadImageface
{
    return _useLeadImageface;
}

-(void)setUseLeadImageface:(BOOL)use
{
    if(_useLeadImageface != use){
        _useLeadImageface = use;
        [self reloadData];
    }
}

-(BOOL)isFlipped
{
    return YES;
}

-(void)superViewBoundsChanged:(NSNotification *)notify
{
    if([[notify name] isEqualToString:NSViewBoundsDidChangeNotification]){
        [self reloadData];
    }else if([[notify name] isEqualToString:NSViewFrameDidChangeNotification]){
        [self reloadData];
    }
}

-(void)awakeFromNib
{
    if(self.superview != nil){
        [self.superview setPostsBoundsChangedNotifications:YES];
        [self.superview setPostsFrameChangedNotifications:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(superViewBoundsChanged:) name:NSViewFrameDidChangeNotification
                                                   object:self.superview];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(superViewBoundsChanged:)
                                                     name:NSViewBoundsDidChangeNotification
                                                   object:self.superview];
        
    }
}

-(CGFloat)minimalWidth
{
    NSView *superView = [self superview];
    if(superView == nil)
        return PRDefaultWidth;
    return superView.frame.size.width;
}

-(CGFloat)minimalHeight
{
    NSView *superView = [self superview];
    if(superView == nil)
        return PRDefaultHeight;
    return superView.frame.size.height;
}

-(void)updateFrame
{
    NSRect frm = [self frame];
    CGFloat w = [self totalColumnWidth];
    CGFloat mW = [self minimalWidth];
    w = MAX(mW, w);
    
    CGFloat h = [self displayDataHeight];
    CGFloat mH = [self minimalHeight];
    h = MAX(mH, h);
    
    frm.size.width = w;
    frm.size.height = h;
    [self setFrame:frm];
}

-(CGFloat)displayDataHeight
{
    NSUInteger c = [self.dataSource numberOfItems:self];
    return (c+1)*self.rowHeight+self.headerHeight;
}

-(void)reloadData
{
    [self updateFrame];
    [self setNeedsDisplay:YES];
}

#pragma mark frame of section
-(NSRect)frameOfHeader
{
    NSRect vRect = self.visibleRect;
    NSRect bds = self.bounds;
    return NSMakeRect(vRect.origin.x, vRect.origin.y, bds.size.width, self.headerHeight);
}

-(CGFloat)margin
{
    return PRDefaultMargin;
}

-(NSSize)sizeOfCheckState
{
    return NSMakeSize(PRDefaultCheckStateWidth, self.rowHeight);
}

-(NSSize)sizeOfLeadImage
{
    return NSMakeSize(PRDefaultLeadImageWidth, self.rowHeight);
}

-(NSRect)frameOfCheckStateAtRow:(NSUInteger)rowIndex
{
    NSRect rc = [self frameOfRow:rowIndex];
    NSSize sz = [self sizeOfCheckState];
    return NSMakeRect(rc.origin.x+[self margin], rc.origin.y, sz.width, sz.height);
}

-(NSRect)frameOfLeadImageAtRow:(NSUInteger)rowIndex
{
    NSRect rc = [self frameOfRow:rowIndex];
    CGFloat offset = [self margin];
    if(self.useCheckSelected){
        offset += [self sizeOfCheckState].width;
    }
    NSSize sz = [self sizeOfLeadImage];
    return NSMakeRect(rc.origin.x+offset, rc.origin.y, sz.width, sz.height);
}

-(CGFloat)offsetOfColumn:(PRTableColumn *)cln
{
    NSUInteger idx = [_columns indexOfObject:cln];
    CGFloat offset = self.bounds.origin.x+[self margin];
    if(self.useCheckSelected){
        offset += [self sizeOfCheckState].width;
    }
    if(self.useLeadImageface){
        offset += [self sizeOfLeadImage].width;
    }
    for (NSUInteger i = 0; i < idx; i++) {
        PRTableColumn *tmp = [_columns objectAtIndex:i];
        offset += tmp.width;
    }
    return offset;
}

-(NSRect)frameOfColumnHeader:(PRTableColumn *)cln
{
    NSRect rc = [self frameOfHeader];
    CGFloat offset = [self offsetOfColumn:cln];
    return NSMakeRect(offset, rc.origin.y, cln.width, rc.size.height);
}

-(NSRect)frameOfRow:(NSUInteger)rowIdx
{
    NSRect bds  = self.bounds;
    return NSMakeRect(bds.origin.x, bds.origin.y+self.headerHeight+rowIdx*self.rowHeight,
                      bds.size.width, self.rowHeight);
}

-(NSRect)frameOfColumn:(PRTableColumn *)cln atRow:(NSUInteger)idx
{
    CGFloat offset = [self offsetOfColumn:cln];
    NSRect rowRc =[self frameOfRow:idx];
    return NSMakeRect(offset, rowRc.origin.y, cln.width, rowRc.size.height);
}

-(NSRect)centerSize:(NSSize)sz inRect:(NSRect)rc
{
    CGFloat x = (rc.size.width-sz.width)/2.0f+rc.origin.x;
    CGFloat y = (rc.size.height-sz.height)/2.0f+rc.origin.y;
    return NSMakeRect(x, y, sz.width, sz.height);
}

-(NSRect)stretchSize:(NSSize)sz toRect:(NSRect)rc
{
    if (sz.width*rc.size.height > sz.height*rc.size.width) {
        CGFloat th = sz.height*rc.size.width/sz.width;
        return NSMakeRect(rc.origin.x, rc.origin.y+(rc.size.height-th)/2.0f, rc.size.width, th);
    }else{
        CGFloat tw = sz.width*rc.size.height/sz.height;
        return NSMakeRect(rc.origin.x+(rc.size.width - tw)/2.0f, rc.origin.y, tw, rc.size.height);
    }
}

-(NSInteger)itemIndexAtPoint:(NSPoint)pt
{
    for (NSUInteger i = 0; i < [self.dataSource numberOfItems:self]; i++) {
        NSRect rc = [self frameOfRow:i];
        if(NSPointInRect(pt, rc)){
            return i;
        }
    }
    return -1;
}

-(PRTableColumn *)columnAtPoint:(NSPoint)pt
{
    CGFloat offset = [self margin];
    if (self.useCheckSelected) {
        offset += [self sizeOfCheckState].width;
    }else{
        offset = 0.0f;
    }
    
    for (PRTableColumn *cln in _columns) {
        if(pt.x > offset && pt.x < offset+cln.width){
            return cln;
        }else{
            offset += cln.width;
        }
    }
    return nil;
}

-(NSInteger)nextChectState:(NSInteger)curState
{
    switch (curState) {
        case NSOffState: return NSOnState;
        case NSOnState: return self.useMixedCheckState?NSMixedState:NSOffState;
        case NSMixedState: return NSOffState;
        default: return NSOnState;
    }
}

#pragma mark table view face
-(NSDictionary *)fontAttributeForHeader
{
    NSFont *ft = [NSFont fontWithName:@"Helvetica Bold" size:18.0f];
    NSColor *clr = [NSColor colorWithDeviceRed:1.0f green:204.0f/255.0f blue:128.0f/255.0f alpha:1.0f];
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:ft, clr, nil]
                                       forKeys:[NSArray arrayWithObjects:NSFontAttributeName, NSForegroundColorAttributeName,nil]];
}

-(NSDictionary *)fontAttributeForBody
{
    NSFont *ft = [NSFont fontWithName:@"Helvetica Light" size:16.0f];
    NSColor *clr = [NSColor colorWithDeviceRed:1.0f green:204.0f/255.0f blue:128.0f/255.0f alpha:1.0f];
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:ft, clr, nil]
                                       forKeys:[NSArray arrayWithObjects:NSFontAttributeName, NSForegroundColorAttributeName,nil]];
}

-(NSDictionary *)fontAttributeForBodySelected
{
    return [self fontAttributeForBody];
}

-(NSColor *)backgroundColorForSelected
{
    return [NSColor colorWithDeviceRed:34.0f/255.0f green:34.f/255.0f blue:84.0f/255.0f alpha:1.0f];
}

-(NSColor *)backgroundColor
{
    return [NSColor colorWithDeviceRed:17.0f/255.0f green:17.0f/255.0f blue:42.0f/255.0f alpha:1.0f];
}

-(NSColor *)headerBackgroundColor
{
    return [NSColor colorWithDeviceRed:39.0f/225.0f green:38.0f/255.0f
                                  blue:36.0f/255.0f alpha:1.0f];
}

-(NSColor *)mouseSelectedBackgroundColor
{
    return [NSColor colorWithDeviceRed:139.0f/225.0f green:138.0f/255.0f
                                  blue:136.0f/255.0f alpha:.5f];
}

-(NSColor *)headerFrameColor
{
    return [NSColor colorWithDeviceRed:97.0f/225.0f green:75.0f/255.0f
                                  blue:42.0f/255.0f alpha:1.0f];
}

-(CGFloat)gridWidth
{
    return 1.0f;
}

-(NSColor *)gridColor
{
    return [NSColor colorWithDeviceRed:237/255.0f green:187.0f/255.0f
                                  blue:112.0f/255.0f alpha:1.0f];
}

#pragma mark draw table view
-(void)drawHeader:(NSRect)dirtyRect
{
    NSRect frmHeader = [self frameOfHeader];
    if (NSIntersectsRect(dirtyRect, [self frameOfHeader])) {
        [[self headerBackgroundColor] set];
        NSRectFill(frmHeader);
        
        [[self headerFrameColor] set];
        NSFrameRect(frmHeader);
        
        for (PRTableColumn *cln in _columns) {
            NSRect frmCln = [self frameOfColumnHeader:cln];
            if(NSIntersectsRect(dirtyRect, frmCln)){
                //draw split line
                
                
                //draw title in rect.
                NSDictionary *ftAttrs = [self fontAttributeForHeader];
                [self drawString:cln.title withAttribute:ftAttrs inCenterRect:frmCln];
                //NSSize sz = [cln.title sizeWithAttributes:ftAttrs];
                //[cln.title drawInRect:[self centerSize:sz inRect:frmCln]
                //       withAttributes:ftAttrs];
            }
        }
    }
}

-(void)drawGrid:(NSRect)dirtyRect
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSUInteger rowIndexStart = (dirtyRect.origin.y-self.headerHeight)/self.rowHeight;
    if(dirtyRect.origin.y < self.headerHeight) rowIndexStart = 0;
    NSUInteger rowIndexEnd = (dirtyRect.origin.y+dirtyRect.size.height - self.headerHeight)/self.rowHeight + 1;
    
    NSRect bds = self.bounds;
    for (NSUInteger rowIndex = rowIndexStart; rowIndex < rowIndexEnd; rowIndex++) {
        CGFloat rowHeight = bds.origin.y + self.headerHeight + rowIndex * self.rowHeight;
        [path moveToPoint:NSMakePoint(dirtyRect.origin.x, rowHeight)];
        [path lineToPoint:NSMakePoint(dirtyRect.origin.x+dirtyRect.size.width, rowHeight)];
    }
    
    for (PRTableColumn *cln in _columns) {
        CGFloat offset = [self offsetOfColumn:cln];
        if([_columns.firstObject isEqualTo:cln]){
            continue;
        }
        if(offset < dirtyRect.origin.x || offset > dirtyRect.origin.x+dirtyRect.size.width){
            continue;
        }else{
            [path moveToPoint:NSMakePoint(offset, dirtyRect.origin.y)];
            [path lineToPoint:NSMakePoint(offset, dirtyRect.origin.y+dirtyRect.size.height)];
            
            if([_columns.lastObject isEqualTo:cln]){
                [path moveToPoint:NSMakePoint(offset+cln.width, dirtyRect.origin.y)];
                [path lineToPoint:NSMakePoint(offset+cln.width, dirtyRect.origin.y+dirtyRect.size.height)];
            }
        }
    }
    [[self gridColor] set];
    [path setLineWidth:[self gridWidth]];
    [path stroke];
}

-(void)drawContentCheckState:(NSInteger)state inRect:(NSRect)rc
{
    NSImage *img = [NSImage imageNamed:@"onState"];
    switch (state) {
        case NSOnState:
            img = [NSImage imageNamed:@"onState"];
            break;
        case NSMixedState:
            img = [NSImage imageNamed:@"mixedState"];
            break;
        default:
            img = [NSImage imageNamed:@"offState"];
            break;
    }
    
    CGFloat dx = [self margin]/2.0f;
    NSRect tRect = [self stretchSize:img.size toRect:NSInsetRect(rc, dx, dx)];
    [img drawInRect:tRect];
}

-(void)drawString:(NSString *)str withAttribute:(NSDictionary *)attrs inCenterRect:(NSRect)rc
{
    NSRect rect = [self centerSize:[str sizeWithAttributes:attrs] inRect:rc];
    if (rect.origin.x < rc.origin.x) {
        rect.origin.x = rc.origin.x;
    }
    if(rect.size.width > rc.size.width){
        rect.size.width = rc.size.width;
    }
    [str drawWithRect:rect options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:attrs];
}

-(void)drawContentItem:(NSUInteger)idx inRect:(NSRect)rc withDirtyRect:(NSRect)dirtyRect
{
    if([self isSelectedRow:idx]){
        [[self backgroundColorForSelected] set];
        NSRectFill(rc);
    }
    
    if(self.useCheckSelected){
        NSRect csRect = [self frameOfCheckStateAtRow:idx];
        if(NSIntersectsRect(csRect, dirtyRect)){
            NSInteger state = NSOffState;
            if([self.dataSource respondsToSelector:@selector(checkStateAtRow:tableView:)]){
                state = [self.dataSource checkStateAtRow:idx tableView:self];
            }
            [self drawContentCheckState:state inRect:csRect];
        }
    }
    
    if(self.useLeadImageface){
        NSRect liRect = [self frameOfLeadImageAtRow:idx];
        if(NSIntersectsRect(liRect, dirtyRect)){
            if([self.dataSource respondsToSelector:@selector(leadImageAtRow:tableView:)])
            {
                NSImage *img = [self.dataSource leadImageAtRow:idx tableView:self];
                if(img != nil){
                    CGFloat dx = [self margin]/2.0f;
                    NSRect tRect = [self stretchSize:img.size toRect: NSInsetRect(liRect, dx, dx)];
                    [img drawInRect:tRect];
                }
            }
        }
    }
    
    for (PRTableColumn *cln in _columns) {
        NSRect tFrm = [self frameOfColumn:cln atRow:idx];
        if(NSIntersectsRect(tFrm, dirtyRect)){
            NSString *title = [self.dataSource objectValueAtRow:idx
                                           withColumnIdentifier:cln.identifer
                                                      tableView:self];
            NSDictionary *ftAttr = [self fontAttributeForBody];
            if([self isSelectedRow:idx]){
                ftAttr = [self fontAttributeForBodySelected];
            }
            [self drawString:title withAttribute:ftAttr inCenterRect:tFrm];
        }
    }
}

-(void)drawContent:(NSRect)dirtyRect
{
    //NSUInteger c  = [self.dataSource numberOfItems:self];
    NSUInteger startIdx = dirtyRect.origin.y/self.rowHeight-1;
    NSUInteger endIdx = (dirtyRect.origin.y+dirtyRect.size.height)/self.rowHeight+1;
    for (NSUInteger i = startIdx; i < endIdx; i++) {
        NSRect frm = [self frameOfRow:i];
        if(NSIntersectsRect(frm, dirtyRect)){
            [self drawContentItem:i inRect:frm
                    withDirtyRect:dirtyRect];
        }
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    //draw background
    [[self backgroundColor] set];
    NSRectFill(self.visibleRect);
        
    //draw grid
    [self drawGrid:self.visibleRect];
        
    //draw Content
    [self drawContent:self.visibleRect];

    //draw header
    [self drawHeader:self.visibleRect];
}

#pragma mark selection manager
-(NSMutableIndexSet *)mutableRowsOfMouseSelected
{
    if(_rowsOfMouseSelected == nil)
        _rowsOfMouseSelected = [[NSMutableIndexSet alloc] init];
    
    return _rowsOfMouseSelected;
}

-(NSIndexSet *)rowsOfCheckSelected
{
    NSMutableIndexSet *idx = [NSMutableIndexSet indexSet];
    if([self.dataSource respondsToSelector:@selector(checkStateAtRow:tableView:)]){
        for (NSUInteger i = 0; i < [self.dataSource numberOfItems:self]; i++) {
            if([self.dataSource checkStateAtRow:i tableView:self] == NSOnState)
                [idx addIndex:i];
        }
    }
    return idx;
}

-(NSIndexSet *)rowsOfMouseSelected
{
    return [self mutableRowsOfMouseSelected];
}

-(BOOL)isSelectedRow:(NSUInteger)idx
{
    return [[self mutableRowsOfMouseSelected] containsIndex:idx];
}

#pragma mark mouse action
-(void)mouseDown:(NSEvent *)theEvent
{
    NSPoint pt = [theEvent locationInWindow];
    pt = [self convertPoint:pt fromView:nil];
    NSInteger rowIndx = [self itemIndexAtPoint:pt];
    if(rowIndx < 0){
        if(NSPointInRect(pt, [self frameOfHeader])){
            //
        }else{
            [[self mutableRowsOfMouseSelected] removeAllIndexes];
            [self setNeedsDisplay:YES];
        }
    }else{
        PRTableColumn *cln = [self columnAtPoint:pt];
        if(cln == nil){
            if(self.useCheckSelected && NSPointInRect(pt, [self frameOfCheckStateAtRow:rowIndx])){
                if([self.dataSource respondsToSelector:@selector(writeCheckState:atRow:tableView:)]){
                    NSInteger curState = [self.dataSource checkStateAtRow:rowIndx tableView:self];
                    [self.dataSource writeCheckState:[self nextChectState:curState] atRow:rowIndx tableView:self];
                }
            }else{
                [[self mutableRowsOfMouseSelected] removeAllIndexes];
            }
            [self setNeedsDisplay:YES];
        }else{
            BOOL needRedraw = NO;
            if([self canMultiSelected]){
                if([theEvent modifierFlags]&NSCommandKeyMask ){
                    if(![self isSelectedRow:rowIndx]){
                        [[self mutableRowsOfMouseSelected] addIndex:rowIndx];
                        needRedraw = YES;
                    }
                }else if([theEvent modifierFlags]&NSShiftKeyMask){
                    NSUInteger firstSelected = [[self rowsOfMouseSelected] firstIndex];
                    NSUInteger lastSelected = [[self rowsOfMouseSelected] lastIndex];
                    if(rowIndx < firstSelected){
                        [[self mutableRowsOfMouseSelected] addIndexesInRange:NSMakeRange(rowIndx, firstSelected-rowIndx)];
                        needRedraw = YES;
                    }else if(rowIndx > lastSelected){
                        [[self mutableRowsOfMouseSelected] addIndexesInRange:NSMakeRange(lastSelected+1, rowIndx-lastSelected-1)];
                        needRedraw = YES;
                    }else if(rowIndx > firstSelected && rowIndx < lastSelected){
                        [[self mutableRowsOfMouseSelected] addIndexesInRange:NSMakeRange(rowIndx, lastSelected-rowIndx)];
                        needRedraw = YES;
                    }
                }else{
                    if(![self isSelectedRow:rowIndx]){
                        [[self mutableRowsOfMouseSelected] removeAllIndexes];
                        [[self mutableRowsOfMouseSelected] addIndex:rowIndx];
                        needRedraw = YES;
                    }
                }
            }else{
                if(![self isSelectedRow:rowIndx]){
                    [[self mutableRowsOfMouseSelected] removeAllIndexes];
                    [[self mutableRowsOfMouseSelected] addIndex:rowIndx];
                    needRedraw = YES;
                }
            }
            if(needRedraw){
                [self setNeedsDisplay:YES];
            }
        }
    }
}

#pragma mark Table Column Operation
-(CGFloat)totalColumnWidth
{
    CGFloat w = 0.0f;
    for (PRTableColumn *cln in _columns) {
        w += cln.width;
    }
    w += [self margin];
    if(self.useCheckSelected)
        w += [self sizeOfCheckState].width;
    if(self.useLeadImageface)
        w += [self sizeOfLeadImage].width;
    return w;
}

-(BOOL)columnExist:(PRTableColumn *)cln
{
    if (cln == nil) {
        return NO;
    }
    
    for (PRTableColumn *ele in _columns) {
        if ([[ele identifer] isEqualToString:cln.identifer]) {
            return YES;
        }
    }
    return NO;
}

-(void)addColumn:(PRTableColumn *)cln
{
    if(_columns == nil){
        _columns = [[NSMutableArray alloc] initWithCapacity:4];
    }
    
    if(![self columnExist:cln]){
        [_columns addObject:cln];
    }
    
    [self reloadData];
}

-(PRTableColumn *)columnWithIdentifer:(NSString *)identifer
{
    for (PRTableColumn *cln in _columns) {
        if([cln.identifer isEqualToString:identifer])
            return cln;
    }
    return nil;
}

-(void)removeColumnByIdentfier:(NSString *)identifer
{
    [self removeColumn:[self columnWithIdentifer:identifer]];
}

-(void)removeColumn:(PRTableColumn *)cln
{
    if ([self columnExist:cln]) {
        [_columns removeObject:cln];
        [self reloadData];
    }
}

-(void)clearColumn
{
    [_columns removeAllObjects];
    [self reloadData];
}
@end
