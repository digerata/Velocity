//
//  CatEntry.m
//  Velocity
//
//  Created by Mike Wille on 9/29/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import "CatEntry.h"


@implementation CatEntry

- (id)init {
	self = [super init];
	return self;
}

- (void)dealloc {
	[catID release];
	[catName release];
	[super dealloc];
}

- (void)setCatID:(NSString *)newID
{
	[newID retain];
	[catID release];
	catID = newID;
}

- (NSString *)catID
{
	return catID;
}

- (void)setCatName:(NSString *)newName
{
	[newName retain];
	[catName release];
	catName = newName;
}

- (NSString *)catName
{
	return catName;
}

- (void)setDepth:(int)newDepth
{
	depth = newDepth;
}

- (int)depth
{	
	return depth;
}	


@end
