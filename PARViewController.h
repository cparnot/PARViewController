//  PARViewController.h
//  PARViewController
//  Copyright 2010, 2011 Mekentosj BV. All rights reserved.

#import <Cocoa/Cocoa.h>

/*
 
 NSViewController base subclass that ensures automatic insertion into the responder chain
 
 USAGE
 
 use as the base subclass, and don't worry about the respnder chain anymore: the view controller is guaranteed to be automatically inserted between the controlled NSView and the next responder that it would normally have in the absence of the view controller
 
 ----------------------------------------------------------------------
 before:  responder X  -->  view  -->  Responder Y
 ----------------------------------------------------------------------
 after:   responder X  -->  view  -->  view controller -->  Responder Y
 ----------------------------------------------------------------------
 
 
 NOTES
 
 - The view will not be in the responder chain unless it overrides `acceptsFirstResponder` to return YES
 and the controller will not be in the responder chain if the view is not in the responder chain.
 see: http://katidev.com/blog/2008/07/24/simple-nsviewcontroller-sample-projects/
 
 - The view will still end up in the responder chain if one of the subviews responds YES to `acceptsFirstResponder`, for example if it contains an NSTableView
 
 */


@class PARObjectObserver;

@interface PARViewController : NSViewController {
	PARObjectObserver *nextResponderObserver;
}

// default implementation commits editing of current field editor if the window is key and if a field editor is up
// subclasses can override this method to perform other actions
- (IBAction)endEditing:(id)sender;

@end

// if a subclass implements this optional method, PARViewController will automatically add an observer to the view frame, and the method will be called when the frame is changed
@interface PARViewController (PARViewControllerFrameObserver)
- (void)viewFrameDidChange;
@end
