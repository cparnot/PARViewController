//  PARObjectObserver.h
//  PARViewController
//  Copyright 2010, 2011, 2012 Mekentosj BV. All rights reserved.


@interface PARObjectObserver : NSObject
{
	__unsafe_unretained id observedObject;
	__unsafe_unretained id delegate;
	SEL callbackSelector;
	NSArray *observedKeys;
	BOOL callbackMainThreadOnly;
}

@property (readonly, assign) id observedObject;
@property (readonly, retain) NSArray *observedKeys;

+ (PARObjectObserver *)observerWithDelegate:(id)delegate selector:(SEL)callbackSelector observedKeys:(NSArray *)observedKeys observedObject:(id)observedObject;

// in GC environments, call this method when the observer is no longer needed (but not in the `finalize` method)
// in non-GC, you can still call it, but it's also automatically done in dealloc
- (void)invalidate;

// forces callback on main thread -- default = YES
@property BOOL callbackMainThreadOnly;

@end

// callback methods can use any of the following signatures (0, 1 or 2 arguments), but can otherwise use any name
@interface NSObject (PARObjectObserverDelegate)
- (void)valueDidChange;
- (void)valueDidChangeForKey:(NSString *)key;
- (void)valueDidChangeForKey:(NSString *)key observedObject:(id)observedObject;
@end