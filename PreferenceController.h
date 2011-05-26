//
//  PreferenceController.h
//  Velocity
//
//  Created by Mike Wille on 9/30/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppController;

@interface PreferenceController : NSWindowController {
	IBOutlet NSTextField *hostField;
	IBOutlet NSTextField *usernameField;
	IBOutlet NSTextField *passwordField;
	IBOutlet NSPopUpButton *preferredOrg;
	IBOutlet NSPopUpButton *preferredVolume;
	IBOutlet NSButton *createGroupCheckbox;
	
	IBOutlet AppController *appController;
}

- (IBAction)saveSettings:(id)sender;
- (IBAction)cancel:(id)sender;
- (void)setAppController:(id)controller;

@end
