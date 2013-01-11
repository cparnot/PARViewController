//  AppDelegate.h
//  PARViewController
//  Copyright 2010 Mekentosj BV. All rights reserved.

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    __unsafe_unretained NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
