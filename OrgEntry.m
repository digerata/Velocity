//
//  OrgEntry.m
//  Velocity
//
//  Created by Mike Wille on 9/27/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import "OrgEntry.h"


@implementation OrgEntry

- (void)dealloc
{
	if(orgName)
		[orgName release];
		
	if(orgID)
		[orgID release];
}

- (NSString *)orgName
{
	return orgName;
}

- (void)setOrgName:(NSString *)name
{
	[name retain];
	[orgName release];
	orgName = name;
}

- (NSString *)orgID
{
	return orgID;
}

- (void)setOrgID:(NSString *)aID
{
	[aID retain];
	[orgID release];
	orgID = aID;
}

@end
