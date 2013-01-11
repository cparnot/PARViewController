//  PARViewController
//  Author: Charles Parnot
//  Licensed under the terms of the BSD License, as specified in the file 'LICENSE-BSD.txt' included with this distribution

#import "PARViewController.h"

@interface DemoController : PARViewController {
	IBOutlet NSTextField *line0;
	IBOutlet NSTextField *line1;
	IBOutlet NSTextField *line2;
	IBOutlet NSTextField *line3;
	NSUInteger selectedIndex;
	NSArray *allLines;
	NSUndoManager *undoManager;
}

@property NSUInteger selectedIndex;

- (IBAction)selectPrevious:(id)sender;
- (IBAction)selectNext:(id)sender;

- (NSUndoManager *)undoManager;

@end
