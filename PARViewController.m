//  PARViewController
//  Author: Charles Parnot
//  Licensed under the terms of the BSD License, as specified in the file 'LICENSE-BSD.txt' included with this distribution

#import "PARViewController.h"
#import "PARObjectObserver.h"

// NSViewController base subclass that ensures automatic insertion into the responder chain
// this is achieved simply by doing KVO on the nextResponder value for the controlled view, encapsulated in the PARViewObserver helper class

@interface PARViewController()
@property (readwrite, retain) PARObjectObserver *nextResponderObserver;
@property (assign, nonatomic) BOOL viewWindowObservationRemoved;
@end

@implementation PARViewController

@synthesize nextResponderObserver;

- (void)dealloc
{
    // Remove self.view.window KVO
    [self removeViewWindowObservation];
    
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

- (void)removeViewWindowObservation
{
    if (!self.viewWindowObservationRemoved)
    {
        [self removeObserver:self forKeyPath:@"view.window"];
        self.viewWindowObservationRemoved = YES;
    }
}

- (void)setView:(NSView *)newView
{
    if (self.view == newView)
    {
        return;
    }
    
    // Remove self.view.window KVO
    [self removeViewWindowObservation];
    
    [super setView:newView];
	[self patchResponderChain];
	[self.nextResponderObserver invalidate];
	if (newView != nil)
    {
		self.nextResponderObserver = [PARObjectObserver observerWithDelegate:self selector:@selector(nextResponderDidChange) observedKeys:@[@"nextResponder"] observedObject:[self view]];
    }
    
    // Add self.view.window KVO
    [self addObserver:self
           forKeyPath:@"view.window"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:nil];

	// optionally observe the view frame
	if ([self respondsToSelector:@selector(viewFrameDidChange)])
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:nil];
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

