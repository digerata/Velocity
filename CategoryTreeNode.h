//
//  CategoryTreeNode.h
//  Velocity
//
//  Created by Mike Wille on 9/29/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "TreeNode.h"

@class CatEntry;

@interface CategoryData : TreeNodeData {
@private
    NSString *name;
    NSImage *iconRep;
	NSString *catID;
    BOOL isLeaf;
    BOOL isExpandable;
}

+ (id)leafDataWithCatEntry:(CatEntry *)cat;
    // Convenience method to return a leaf node with its name set.
    
+ (id)groupDataWithCatEntry:(CatEntry *)cat;
    // Convenience method to return a branch node with its name set.
    
- (void)setName:(NSString*)name;
- (NSString*)name;
- (void)setCatID:(NSString *)catID;
- (NSString *)catID;

- (NSString*)description;

- (void)setIsLeaf:(BOOL)isLeaf;
- (BOOL)isLeaf;
- (BOOL)isGroup;

- (void)setIconRep:(NSImage*)iconRep;
- (NSImage*)iconRep;

- (void)setIsExpandable: (BOOL)checked;
- (BOOL)isExpandable;

@end

@interface CategoryTreeNode : TreeNode {
}

// This is a convenience method to return a tree root of a tree derived from the list returned from the tank
+ (id) treeFromArray:(NSArray *)catList;

+ (id) loadArray:(NSArray *)catList 
			 atIndex:(int *)curIndex 
		   withDepth:(int)curDepth;
	
@end

