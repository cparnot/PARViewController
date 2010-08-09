//  MTObjectObserver.m
//  MTViewController
//  Copyright 2010 Mekentosj BV. All rights reserved.

#import "MTObjectObserver.h"

@implementation MTObjectObserver

@synthesize observedObject;
@synthesize observedKeys;
@synthesize callbackMainThreadOnly;

- (id)initWithDelegate:(id)notifiedObject selector:(SEL)callback observedKeys:(NSArray *)keys observedObject:(id)object
{
	self = [super init];
	if ( self != nil ) {
		observedObject = object;
		delegate = notifiedObject;
		callbackSelector = callback;
		observedKeys = [keys retain];
		for (NSString *key in observedKeys)
			[observedObject addObserver:self forKeyPath:key options:0 context:NULL];
		self.callbackMainThreadOnly = YES;
	}
	return self;
}

+ (MTObjectObserver *)observerWithDelegate:(id)notifiedObject selector:(SEL)callback observedKeys:(NSArray *)keys observedObject:(id)object
{
	MTObjectObserver *newObserver = [[[MTObjectObserver alloc] initWithDelegate:notifiedObject selector:callback observedKeys:keys observedObject:object] autorelease];
	return newObserver;
}

- (void)notifyDelegateForKeyPath:(NSString *)key
{
	if (self.callbackMainThreadOnly == YES && [NSThread currentThread] != [NSThread mainThread])
	{
		SecondaryThreadOrReturn()
		[self performSelectorOnMainThread:@selector(notifyDelegateForKeyPath:) withObject:key waitUntilDone:NO];
		return;
	}
	
	if (self.callbackMainThreadOnly)
		MainThreadOrReturn()
	
	if ([delegate respondsToSelector:callbackSelector])
	{
		NSUInteger argumentCount = [[delegate methodSignatureForSelector:callbackSelector] numberOfArguments];
		if ( argumentCount == 2 )
			[delegate performSelector:callbackSelector];
		else if ( argumentCount == 3 )
			[delegate performSelector:callbackSelector withObject:key];
		else if ( argumentCount == 4 )
			[delegate performSelector:callbackSelector withObject:key withObject:observedObject];
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
	[observedKeys release];
	observedKeys = nil;
	callbackSelector = NULL;
	delegate = nil;
	observedObject = nil;
}

- (void)dealloc
{
	// maybe unsafe outside of main thread?
	[self invalidate];
	[super dealloc];
}

@end
