//
//  AppController.h
//  Velocity
//
//  Created by Mike Wille on 9/13/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FileController;
@class GroupController;

@interface AppController : NSObject {
	// this holds the 16 x 16 small icon used in the tree view)
	NSDictionary *fileIconsSmall;
	// this holds the 64 x 64 large icon (used in thumb display)
	NSDictionary *fileIconsLarge;
	// The list of volumes a user can select in the file browser.
	NSMutableArray *volumes;
		
	// File Browser page connections...
	IBOutlet NSPopUpButton *volumeSelect;
	IBOutlet FileController *fileController;

	// Preview drawer connections...
	IBOutlet NSImageView *imageView;
	IBOutlet NSDrawer *drawer;

	// Group info page connections...
	IBOutlet GroupController *groupController;
	IBOutlet NSTextField *groupName;
	IBOutlet NSPopUpButton *orgSelect;
	IBOutlet NSOutlineView *categoryView;
}

- (void)loadImage:(NSString *)fileName;
//- (void)currentlySelectedGroup:(NSString *)groupName;

@end
