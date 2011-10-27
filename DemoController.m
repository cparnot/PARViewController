//  MTViewController
//  Copyright 2010 Mekentosj BV. All rights reserved.

#import "DemoController.h"

/*
 
 The view controller is the controller for an NSBox, which containts 4 lines of text, all NSTextField. One of the lines is "selected" (blue background).
 
 All of the following events (click, keys, and menu items) are directly handled by the view controller, thanks to its automatic insertion in the responder chain after the NSBox:
 
	- The user can click in the box to select a line (the box then becomes the first responder)
	- When the box is first responder, the controller can respond to the up and down keys
	- When the box is first responder, the controller respond to first-responder actions from the application menu
 
 */

@implementation DemoController

@synthesize selectedIndex;

#pragma mark Drawing = based on `selectedIndex`

- (void)refresh
{
	NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));

	[[line0 cell] setDrawsBackground:NO];
	[[line1 cell] setDrawsBackground:NO]; 
	[[line2 cell] setDrawsBackground:NO];
	[[line3 cell] setDrawsBackground:NO];

	// only the marked line gets the colored background
	[[allLines objectAtIndex:selectedIndex] setDrawsBackground:YES];
}

- (NSUInteger)selectedIndex
{
    return selectedIndex;
}

- (void)setSelectedIndex:(NSUInteger)newValue
{
	NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
	NSLog(@"new value = %ld", newValue);
	if (newValue > 3)
		newValue = 3;
	
	if (newValue != selectedIndex) {
		[[[self undoManager] prepareWithInvocationTarget:self] setSelectedIndex:selectedIndex];
		selectedIndex = newValue;
		[self refresh];
    }
}


- (void)awakeFromNib
{
	allLines = [[NSArray alloc] initWithObjects:line0, line1, line2, line3, nil];
	[line0 setStringValue:@"Hello"];
	[line1 setStringValue:@"Brave"];
	[line2 setStringValue:@"New"];
	[line3 setStringValue:@"World"];
	self.selectedIndex = 0;
	[self refresh];
}


// called for instance when the window is resized and the NSBox moves or resizes as a result
- (void)viewFrameDidChange
{
	NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
}

- (NSUndoManager *)undoManager
{
	if (undoManager == nil)
		undoManager = [[NSUndoManager alloc] init];
	return undoManager;
}


#if ! __has_feature(objc_arc)
- (void)dealloc
{
	[line0 release];
	[line1 release];
	[line2 release];
	[line3 release];
	[allLines release];
	[undoManager release];
	[super dealloc];
}
#endif

#pragma mark Mouse events

- (void)mouseDown:(NSEvent *)theEvent
{
	NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));

	// mark the line that was clicked
	NSPoint locationInSuperview = [[[self view] superview] convertPoint:[theEvent locationInWindow] fromView:nil];
	NSView *clickedView = [[self view] hitTest:locationInSuperview];
	NSUInteger clickedIndex = [allLines indexOfObject:clickedView];
	if (clickedIndex != NSNotFound)
		self.selectedIndex = clickedIndex;
	
	// make the box view the first responder so it will now respond to key events and actions sent to nil
	[[[self view] window] makeFirstResponder:[self view]];
}


#pragma mark Keyboard events

- (void)moveUp:(id)sender
{
	NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
	[self selectPrevious:sender];
}

- (void)moveDown:(id)sender
{
	NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
	[self selectNext:sender];
}


#pragma mark Actions

- (IBAction)selectPrevious:(id)sender
{
	NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
	if (self.selectedIndex > 0)
		self.selectedIndex = selectedIndex - 1;
}

- (IBAction)selectNext:(id)sender
{
	NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
	self.selectedIndex = selectedIndex + 1;
}

- (IBAction)undo:(id)sender
{
	NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
	[[self undoManager] undo];
}

- (IBAction)redo:(id)sender
{
	NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
	[[self undoManager] redo];
}

@end
