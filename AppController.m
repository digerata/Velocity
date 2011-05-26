//
//  AppController.m
//  Velocity
//
//  Created by Mike Wille on 9/13/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import "AppController.h"
#import "FileController.h"
#import "NSOutlineView_Extensions.h"

@implementation AppController

// ================================================================
// Controller intialization...
// ================================================================

- (id)init
{
	self = [super init];
	return self;
}

- (void)dealloc
{
	[volumes dealloc];
	[super dealloc];
}

- (void)awakeFromNib
{
}

- (NSImage *)_iconForFilePath:(NSString *)path
{
    NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:path];
	[image setSize:NSMakeSize(16, 16)];
	return image;
}

- (void)createVolumeMenu
{
	NSMenuItem *newItem;
	NSMenu *popupMenu;
	int counter;
	
	NSString *username = NSUserName();
	NSString *home = [NSString stringWithFormat:@"%@%@%@", @"/Users/", username, @"/"];
	NSString *desktop = [NSString stringWithFormat:@"%@%@", home, @"Desktop/"];
	NSString *documents = [NSString stringWithFormat:@"%@%@", home, @"Documents/"];
	NSString *pictures = [NSString stringWithFormat:@"%@%@", home, @"Pictures/"];
	NSString *movies = [NSString stringWithFormat:@"%@%@", home, @"Movies/"];
	NSString *music = [NSString stringWithFormat:@"%@%@", home, @"Music/"];

	volumes = [[[NSWorkspace sharedWorkspace] mountedLocalVolumePaths] mutableCopy];

	[volumes addObject:home];
	[volumes addObject:desktop];
	[volumes addObject:documents];
	[volumes addObject:pictures];
	[volumes addObject:movies];
	[volumes addObject:music];
		
	popupMenu = [[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"Volumes"];

	[volumeSelect removeAllItems];
	for(counter = 0; counter < [volumes count] - 1; counter++) {
		NSString *path = [volumes objectAtIndex:counter];
		NSString *name = [path lastPathComponent];
		NSLog(@"Have Volume: %@", path);
		// If we are past local volumes, add a separator.
		if([name isEqualToString:@"mwille"]) {
			[popupMenu addItem:[NSMenuItem separatorItem]];
		}
		newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:name action:NULL keyEquivalent:@""];
		[newItem setImage:[self _iconForFilePath:path]];
		[newItem setTag:counter];
		[newItem setTarget:self];
		[newItem setAction:@selector(changeDir:)];
		[popupMenu addItem:newItem];
		//[volumeSelect addItemWithTitle:[volumes objectAtIndex:counter]];
		[newItem release];
		//[path release];
	}	
		
	[volumeSelect setMenu:popupMenu];
}

- (void)changeDir:(id)sender
{
	NSLog(@"Changing Root to: %@", [volumes objectAtIndex:[sender tag]]);
	[fileController changeRoot:[volumes objectAtIndex:[sender tag]]];
}

- (void)loadImage:(NSString *)fileName
{
	if([drawer state] == NSDrawerOpenState) {
		NSLog(@"LoadImage from %@", fileName);
		NSImage *image = [[NSImage alloc] initByReferencingFile:fileName];
		[imageView setImage:image];
		[imageView setNeedsDisplay:YES];
		[image release];
		NSLog(@"Image set.");
	} else {
		NSLog(@"Drawer closed, not loading image.");
	}
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    // The creation of new menus for the menu bar should be done in applicationWillFinishLaunching.
    [self createVolumeMenu];
}



@end