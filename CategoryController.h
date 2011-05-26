//
//  CategoryController.h
//  Velocity
//
//  Created by Mike Wille on 9/29/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppController;
@class GroupController;
@class CategoryData;
@class CategoryTreeNode;

@interface CategoryController : NSObject {
	// The group tree
	CategoryTreeNode *catTree;
	
	IBOutlet NSOutlineView *categoryOutlineView;
	IBOutlet AppController *appController;
	IBOutlet GroupController *groupController;
	
	// the currently selected group.
	CategoryData *curCategory;
}

- (void)outlineViewAction:(id)sender;

//- (BOOL)allowOnDropOnGroup;
//- (BOOL)allowOnDropOnLeaf;
//- (BOOL)allowBetweenDrop;

- (NSArray *)selectedNodes;

- (void)setCatList:(NSArray *)catList;

- (void)selectCatAtIndex:(int)index;

@end
