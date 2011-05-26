//
//  PreferenceController.m
//  Velocity
//
//  Created by Mike Wille on 9/30/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import "PreferenceController.h"
#import "AppController.h"


@implementation PreferenceController

- (id)init
{
	NSLog(@"Init of preference controller");
	self = [super initWithWindowNibName:@"Preferences"];
	return self;
}

- (void)windowDidLoad
{
	NSLog(@"Nib file is loaded");
	NSDictionary *info = [appController getConnectionInfo];
	[usernameField setStringValue:[info objectForKey:@"username"]];
	[passwordField setStringValue:[info objectForKey:@"password"]];
	[hostField setStringValue:[info objectForKey:@"host"]];
}

-(IBAction)showWindow:(id)sender
{
	[super showWindow:sender];
}

- (IBAction)saveSettings:(id)sender
{
	[appController setConnectionInfo:[usernameField stringValue] password:[passwordField stringValue] host:[hostField stringValue]];
	NSLog(@"Saved settings...");
	[self close];
}

- (IBAction)cancel:(id)sender
{
	[self close];
}

- (void)setAppController:(id)controller
{
	appController = controller;
}

@end
