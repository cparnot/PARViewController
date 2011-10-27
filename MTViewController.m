//  MTViewController.m
//  MTViewController
//  Copyright 2010 Mekentosj BV. All rights reserved.

#import "MTViewController.h"
#import "MTObjectObserver.h"

#pragma mark -
#pragma mark MTViewController

// NSViewController base subclass that ensures automatic insertion into the responder chain

// this is achieved simply by doing KVO on the nextResponder value for the controlled view, encapsulated in the MTViewObserver helper class

@interface MTViewController()
@property (readwrite, retain) MTObjectObserver *nextResponderObserver;
@end

@implementation MTViewController

@synthesize nextResponderObserver;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    self.nextResponderObserver = nil;
    #if ! __has_feature(objc_arc)
	[super dealloc];
    #endif
}

- (void)patchResponderChain
{
	// set the view controller in the middle of the responder chain
	// to avoid recursion and responder chain cycle, make sure the controller is not already the next responder of the view
	NSResponder *currentNextResponder = [[self view] nextResponder];
	if (currentNextResponder != nil && currentNextResponder != self)
	{
		[self setNextResponder:currentNextResponder];
		[[self view] setNextResponder:self];
	}
}

- (void)setView:(NSView *)newView
{
	[super setView:newView];
	[self patchResponderChain];
	[self.nextResponderObserver invalidate];
	if (newView != nil)
		self.nextResponderObserver = [MTObjectObserver observerWithDelegate:self selector:@selector(nextResponderDidChange) observedKeys:[NSArray arrayWithObject:@"nextResponder"] observedObject:[self view]];

	// optionally observe the view frame
	if ([self respondsToSelector:@selector(viewFrameDidChange)])
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		if ([self view])
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewFrameDidChange:) name:NSViewFrameDidChangeNotification object:[self view]];
	}
}

- (void)nextResponderDidChange
{
	[self patchResponderChain];
}

//- (void)superviewDidChange
//{
//	NSLog(@"new superview : %@", [[self view] superview]);
//}

- (void)viewFrameDidChange:(NSNotification *)aNotification
{
	if ([self respondsToSelector:@selector(viewFrameDidChange)])
		[self viewFrameDidChange];
}

- (IBAction)endEditing:(id)sender
{
	NSWindow *window = [[self view] window];
	if (window != nil && [window isKeyWindow] == YES)
		[window makeFirstResponder:nil];
}

@end

