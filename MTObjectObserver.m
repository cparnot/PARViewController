//  MTObjectObserver.m
//  MTViewController
//  Copyright 2010, 2011, 2012 Mekentosj BV. All rights reserved.

#import "MTObjectObserver.h"

// thread-assertion macros can be defined outside of this file
#ifndef MainThreadOrReturn
#define MainThreadOrReturn() do {} while(0)
#endif

#ifndef SecondaryThreadOrReturn
#define SecondaryThreadOrReturn() do {} while(0)
#endif


@interface MTObjectObserver ()
@property (assign) id delegate;
@property (assign) id observedObject;
@property (retain) NSArray *observedKeys;
@end


@implementation MTObjectObserver

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

+ (MTObjectObserver *)observerWithDelegate:(id)notifiedObject selector:(SEL)callback observedKeys:(NSArray *)keys observedObject:(id)object
{
	MTObjectObserver *newObserver = [[MTObjectObserver alloc] initWithDelegate:notifiedObject selector:callback observedKeys:keys observedObject:object];
    
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

// compiling with ARC
#if __has_feature(objc_arc)
- (void)dealloc
{
	[self invalidate];
    observedObject = nil;
    delegate = nil;
}

// compiling without ARC
#else
- (void)dealloc
{
	[self invalidate];
    observedObject = nil;
    delegate = nil;
    [super dealloc];
}
#endif


@end
