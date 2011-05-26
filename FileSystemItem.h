//
//  FileSystemItem.h
//  Velocity
//
//  Created by Mike Wille on 9/13/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FileSystemItem : NSObject
{
    NSString *relativePath;
	NSString *fullPath;
    FileSystemItem *parent;
    NSMutableArray *children;
	NSImage *icon;
	NSDictionary *attributes;
}

+ (FileSystemItem *)rootItem:(NSString *)rootPath;
- (id)initWithPath:(NSString *)path parent:(FileSystemItem *)obj;
- (int)numberOfChildren;// Returns -1 for leaf nodes
- (FileSystemItem *)childAtIndex:(int)n;// Invalid to call on leaf nodes
- (NSString *)fullPath;
- (NSString *)relativePath;
- (void)setIcon:(NSImage *)aIcon;
- (NSImage *)icon;

- (NSString *)lastModified;
- (unsigned long long)fileSize;

@end