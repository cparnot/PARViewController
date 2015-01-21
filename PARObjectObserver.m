//  PARViewController
//  Author: Charles Parnot
//  Licensed under the terms of the BSD License, as specified in the file 'LICENSE-BSD.txt' included with this distribution

#import "PARObjectObserver.h"

// thread-assertion macros can be defined outside of this file
#ifndef MainThreadOrReturn
#define MainThreadOrReturn() do {} while(0)
#endif

#ifndef SecondaryThreadOrReturn
#define SecondaryThreadOrReturn() do {} while(0)
#endif


@interface PARObjectObserver ()
@property (assign) id delegate;
@property (assign) id observedObject;
@property (retain) NSArray *observedKeys;
@end


@implementation PARObjectObserver

@synthesize delegate;
@synthesize observedObject;
@synthesize observedKeys;
@synthesize callbackMainThreadOnly;

- (id)initWithDelegate:(id)notifiedObject selector:(SEL)callback observedKeys:(NSArray *)keys observedObject:(id)object
{
    self = [super init];
	if (self != nil)
    {
		observedObject = object;
		delegate = notifiedObject;
		callbackSelector = callback;
		observedKeys = [keys copy]; // using 'copy' to work with GC/ARC/non-ARC
        
        //-invalidate handles removing this observing, and it's called in -dealloc, this should be safe.
		for (NSString *key in observedKeys)
			[observedObject addObserver:self forKeyPath:key options:0 context:NULL];
		self.callbackMainThreadOnly = YES;
	}
	return self;
}

+ (PARObjectObserver *)observerWithDelegate:(id)notifiedObject selector:(SEL)callback observedKeys:(NSArray *)keys observedObject:(id)object
{
	PARObjectObserver *newObserver = [[PARObjectObserver alloc] initWithDelegate:notifiedObject selector:callback observedKeys:keys observedObject:object];
    
    // `autorelease` is not valid in ARC
#if ! __has_feature(objc_arc)
    [newObserver autorelease];
#endif
    
	return newObserver;
}

- (void)notifyDelegateForKeyPath:(NSString *)key
{
	if (self.callbackMainThreadOnly == YES && [NSThread currentThread] != [NSThread mainThread])
	{
		SecondaryThreadOrReturn();
		[self performSelectorOnMainThread:@selector(notifyDelegateForKeyPath:) withObject:key waitUntilDone:NO];
		return;
	}
	
	if (self.callbackMainThreadOnly)
		MainThreadOrReturn();
	
    // here we do not expect a return result actually, so we should not use `performSelector:` anyway, instead we should use NSInvocation
    // see also issue about using ARC and `performSelector:` http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
	if ([delegate respondsToSelector:callbackSelector])
    {
        NSInvocation *callbackInvocation = [NSInvocation invocationWithMethodSignature:[delegate methodSignatureForSelector:callbackSelector]];
        callbackInvocation.target = delegate;
        callbackInvocation.selector = callbackSelector;
		NSUInteger argumentCount = [[delegate methodSignatureForSelector:callbackSelector] numberOfArguments];
        
        #if __has_feature(objc_arc)
        
        if (argumentCount > 2)
        {
            void *arg = (__bridge void *)key;
            [callbackInvocation setArgument:&arg atIndex:2];
        }
        if (argumentCount > 3)
        {
            void *arg = (__bridge void *)observedObject;
            [callbackInvocation setArgument:&arg atIndex:3];
        }
        if (argumentCount > 4)
        {
            void *arg = (__bridge void *)self;
            [callbackInvocation setArgument:&arg atIndex:4];
        }
        
        #else

        if (argumentCount > 2)
            [callbackInvocation setArgument:&key atIndex:2];
        if (argumentCount > 3)
            [callbackInvocation setArgument:&observedObject atIndex:3];
        if (argumentCount > 4)
            [callbackInvocation setArgument:&self atIndex:4];

        #endif

        [callbackInvocation invoke];
	}
}

- (void)observeValueForKeyPath:(NSString *)key ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self notifyDelegateForKeyPath:key];
}

// why we need this for GC: http://stackoverflow.com/questions/13927/in-cocoa-do-i-need-to-remove-an-object-from-receiving-kvo-notifications-when-deal
- (void)invalidate
{
	for (NSString *key in observedKeys)
		[observedObject removeObserver:self forKeyPath:key];
	self.observedKeys = nil;
	self.delegate = nil;
	self.observedObject = nil;
	callbackSelector = NULL;
}

- (void)dealloc
{
	[self invalidate];
    observedObject = nil;
    delegate = nil;
    
    // Manual memory management:
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
