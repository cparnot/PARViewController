//  MTObjectObserver.h
//  MTViewController
//  Copyright 2010 Mekentosj BV. All rights reserved.


@interface MTObjectObserver : NSObject {
	id observedObject;
	id delegate;
	SEL callbackSelector;
	NSArray *observedKeys;
	BOOL callbackMainThreadOnly;
}

@property (readonly, assign) id observedObject;
@property (readonly, retain) NSArray *observedKeys;

+ (MTObjectObserver *)observerWithDelegate:(id)delegate selector:(SEL)callbackSelector observedKeys:(NSArray *)observedKeys observedObject:(id)observedObject;

// in GC environments, call this method on the main thread when the observer is no longer needed (but not in the `finalize` method)
// in non-GC, you can still call it, but it's also automatically done in dealloc
- (void)invalidate;

// forces the callback to occur on main thread -- default = YES
@property BOOL callbackMainThreadOnly;

@end

// signature for the callback method can take up to 2 arguments, but you can pick any naming as long as it fits one of those signatures
@interface NSObject (MTObjectObserverDelegate)
- (void)valueDidChange;
- (void)valueDidChangeForKey:(NSString *)key;
- (void)valueDidChangeForKey:(NSString *)key observedObject:(id)observedObject;
@end