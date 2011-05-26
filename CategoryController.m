//
//  CategoryController.m
//  Velocity
//
//  Created by Mike Wille on 9/29/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import "CategoryController.h"
#import "GroupController.h"
#import "CategoryTreeNode.h"
#import "ImageAndTextCell.h"
#import "NSArray_Extensions.h"
#import "NSOutlineView_Extensions.h"

#define GROUP_ICON					@"Category.png"
#define COLUMNID_IS_EXPANDABLE	 	@"IsExpandableColumn"
#define COLUMNID_NAME				@"CategoryName"
#define COLUMNID_NODE_KIND			@"NodeKindColumn"

// Conveniences for accessing nodes, or the data in the node.
// We always have to cast so this makes it a bit easier.
#define NODE(n)				((CategoryTreeNode*)n)
#define NODE_DATA(n) 		((CategoryData*)[NODE((n)) nodeData])
#define SAFENODE(n) 		((CategoryTreeNode*)((n)?(n):(catTree)))

@implementation CategoryController

- (void)awakeFromNib
{
	NSTableColumn *tableColumn = nil;
	ImageAndTextCell *imageAndTextCell = nil;
	
	tableColumn = [categoryOutlineView tableColumnWithIdentifier: COLUMNID_NAME];
	imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
	[imageAndTextCell setEditable: YES];
	[imageAndTextCell setStringValue:@"First Category"];
	[imageAndTextCell setImage:[NSImage imageNamed:@"Internet Folder.tiff"]];
	[tableColumn setDataCell:imageAndTextCell];	
}

- (void)outlineViewAction:(id)olv
{
    // This message is sent from the groupOutlineView as it's action (see the connection in IB).
	NSArray *selectedNodes = [self selectedNodes];
    
    if([selectedNodes count] > 1)
		NSLog(@"Multiple Rows Selected");
		
    else if ([selectedNodes count] == 1) {
		CategoryData *cat = NODE_DATA([selectedNodes objectAtIndex:0]);
		NSLog(@"Category: %@ Index: %d", [cat name], [categoryOutlineView selectedRow]);
		//[groupController setGroupCat:[cat name] withID:[cat catID]];
		[groupController setGroupCatIndex:[categoryOutlineView selectedRow]];
    } else 
		NSLog(@"Nothing Selected");
	
}

- (void)selectCatAtIndex:(int)index
{
	NSLog(@"[CatController selectCatAtIndex] Selecting category at index: %d", index);
	[categoryOutlineView selectRow:index byExtendingSelection:NO];
}

// ================================================================
// Accessors for dragging and highlighting...
// ================================================================

- (NSArray *)selectedNodes { return [categoryOutlineView allSelectedItems]; }

- (void)setCatList:(NSArray *)catList
{
	NSLog(@"Creating new category tree...");
	catTree = [CategoryTreeNode treeFromArray:catList];
	[CategoryTreeNode dump:catTree depth:0];
	[categoryOutlineView reloadData];
}

- (id)outlineView:(NSOutlineView *)olv child:(int)index ofItem:(id)item
{
    return [SAFENODE(item) childAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)olv isItemExpandable:(id)item
{
    return [NODE_DATA(item) isGroup];
}

- (int)outlineView:(NSOutlineView *)olv numberOfChildrenOfItem:(id)item
{
    return [SAFENODE(item) numberOfChildren];
}

- (id)outlineView:(NSOutlineView *)olv objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    id objectValue = nil;
    
    // The return value from this method is used to configure the state of the items cell via setObjectValue:
    if([[tableColumn identifier] isEqualToString: COLUMNID_NAME]) {
		objectValue = [NODE_DATA(item) name];
		
    } else if([[tableColumn identifier] isEqualToString: COLUMNID_IS_EXPANDABLE] && [NODE_DATA(item) isGroup]) {
		// Here, object value will be used to set the state of a check box.
		objectValue = [NSNumber numberWithBool: [NODE_DATA(item) isExpandable]];
		
    } else if([[tableColumn identifier] isEqualToString: COLUMNID_NODE_KIND]) {
		objectValue = ([NODE_DATA(item) isLeaf] ? @"Leaf" : @"Group");
    }
    
    return objectValue;
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{    
    if ([[tableColumn identifier] isEqualToString: COLUMNID_NAME]) {
		// Make sure the image and text cell has an image.  If not, give it something random.
		if (item && ![NODE_DATA(item) iconRep]) 
			[NODE_DATA(item) setIconRep: [NSImage imageNamed:@"Internet Folder.tiff"]];
		
		// Set the image of the cell...
		[(ImageAndTextCell*)cell setImage: [NODE_DATA(item) iconRep]];

		// Set the text of the cell...
		[(ImageAndTextCell*)cell setStringValue: [cell stringValue]];

    } else if ([[tableColumn identifier] isEqualToString: COLUMNID_IS_EXPANDABLE]) {
		[cell setEnabled: [NODE_DATA(item) isGroup]];

    } else if ([[tableColumn identifier] isEqualToString: COLUMNID_NODE_KIND]) {
		// Don't do anything unusual for the kind column.
    }
}

@end
