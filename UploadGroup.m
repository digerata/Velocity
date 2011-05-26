//
//  UploadGroup.m
//  Velocity
//
//  Created by Mike Wille on 9/21/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import "UploadGroup.h"


@implementation UploadGroup

- (id)init
{
	name = nil;
	orgID = nil;
	catID = nil;
}

- (void)dealloc
{
	[name release];
	[orgID release];
	[catID release];
	[super dealloc];
}

- (void)setName:(NSString *)aName
{
	[aName retain];
	[name release];
	name = aName;
}

- (NSString *)name
{
	return name;
}

- (void)setOrgID:(NSString *)aOrgID
{
	[aOrgID retain];
	[orgID release];
	orgID = aOrgID;
}

- (NSString *)orgID
{
	return orgID;
}

- (void)setCatID:(NSString *)aCatID
{
	[aCatID retain];
	[catID release];
	catID = aCatID;
}

- (NSString *)catID
{
	return catID;
}


@end
