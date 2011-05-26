//
//  FileSystemItem.m
//  Velocity
//
//  Created by Mike Wille on 9/13/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import "FileSystemItem.h"
//#import "NSFileManager.h"

@implementation FileSystemItem

static FileSystemItem *rootItem = nil;
#define IsALeafNode ((id)-1)

+ (FileSystemItem *)rootItem:(NSString *)rootPath
{
	// if we are just starting up...
	if(rootItem == nil) {
		//NSLog(@"FileSystemItem:Startup call");
		rootItem = [[FileSystemItem alloc] initWithPath:rootPath parent:nil];
	
	// if we have changed the root...
	} else if(![[rootItem fullPath] isEqualToString:rootPath]) {
		//NSLog(@"FileSystemItem:We are changing to a new root: %@ from %@", rootPath, [rootItem fullPath]);
		[rootItem release];
		//NSLog(@"Released the old rootItem.");
		rootItem = [[FileSystemItem alloc] initWithPath:rootPath parent:nil];
		//NSLog(@"Created new rootItem.");
	} else {
		//NSLog(@"FileSystemItem:Existing root is good.");
	}
	// return the possibly newly initialized node...
	return rootItem;
}

- (id)initWithPath:(NSString *)path parent:(FileSystemItem *)obj
{
	if(self = [super init]) {
		//NSLog(@"FileSystemItem:initWithPath:%@", path);
		fullPath = [path retain];
		relativePath = [[path lastPathComponent] copy];
		parent = obj;
		NSFileManager *fileManager = [NSFileManager defaultManager];
		attributes = [fileManager fileAttributesAtPath:path traverseLink:YES];
	}
	return self;
}

- (NSArray *)children
{
	if(children == NULL) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		BOOL isDir, valid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
		
		NSString *fixedPath;
		if(![fullPath hasSuffix:@"/"]) {
			fixedPath = [NSString stringWithFormat:@"%@/", fullPath];
		} else {
			fixedPath = fullPath;
		}
		
		if(valid && isDir) {
			NSArray *array = [fileManager directoryContentsAtPath:fullPath];
			int counter, numChildren = [array count];
			children = [[NSMutableArray alloc] initWithCapacity:numChildren];
			
			for(counter = 0; counter < numChildren; counter++) {
				if([[[array objectAtIndex:counter] description] hasPrefix:@"."])
					continue;
					
				FileSystemItem *newChild = [[FileSystemItem alloc] initWithPath:[NSString stringWithFormat:@"%@%@", fixedPath, [array objectAtIndex:counter]] parent:self];
				[children addObject:newChild];
				[newChild release];
			}
		} else {
			children = IsALeafNode;
		}
	}
	return children;
}

- (NSString *)relativePath
{
	return relativePath;
}

- (NSString *)fullPath
{
	return fullPath;
}

- (FileSystemItem *)childAtIndex:(int)n
{
	return [[self children] objectAtIndex:n];
}

- (int)numberOfChildren
{
	id temp = [self children];
	return (temp == IsALeafNode) ? (-1) : [temp count];
}

- (void)setIcon:(NSImage *)aIcon
{
	[aIcon retain];
	[icon release];
	icon = aIcon;
}

- (NSImage *)icon
{
	return icon;
}

- (NSString *)lastModified
{
	return [[attributes fileModificationDate] description];
}

- (unsigned long long)fileSize
{
	return [attributes fileSize];
}

- (NSString *)description
{
	return relativePath;
}	

- (void)dealloc
{
	//NSLog(@"Dealloc'ing: %@", relativePath);
	if(children != IsALeafNode)
		[children release];
	
	[relativePath release];
	// MEMORY LEAK!!!  However, leaving the below in causes a BAD_ACCESS_ERROR ????
	//if(attributes)
		//[attributes release];
	[super dealloc];
}

@end
