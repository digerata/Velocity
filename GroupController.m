//
//  GroupController.m
//  Velocity
//
//  Created by Mike Wille on 9/15/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import "GroupController.h"
#import "GroupTreeNode.h"
#import "ImageAndTextCell.h"
#import "NSArray_Extensions.h"
#import "NSOutlineView_Extensions.h"
#import "AppController.h"
#import "Globals.h"

@interface GroupController (Private)
- (void)_addNewGroup:(GroupTreeNode *)newChild;
- (void)_performDropOperation:(id <NSDraggingInfo>)info onNode:(TreeNode *)parentNode atIndex:(int)childIndex;
- (NSImage *)_iconForFileType:(NSString *)extension;
- (NSImage *)_thumbForFileType:(NSString *)extension;
@end

// ================================================================
// Useful Macros
// ================================================================

#define DragDropSimplePboardType 	@"MyCustomOutlineViewPboardType"
#define INITIAL_GROUPDICT			@"GroupInfo"
#define GROUP_ICON					@"Group.png"
#define COLUMNID_IS_EXPANDABLE	 	@"IsExpandableColumn"
#define COLUMNID_NAME				@"GroupName"
#define COLUMNID_NODE_KIND			@"NodeKindColumn"

// Conveniences for accessing nodes, or the data in the node.
// We always have to cast so this makes it a bit easier.
#define NODE(n)				((GroupTreeNode*)n)
#define NODE_DATA(n) 		((GroupData*)[NODE((n)) nodeData])
#define SAFENODE(n) 		((GroupTreeNode*)((n)?(n):(groups)))

@implementation GroupController

// ================================================================
// Controller intialization...
// ================================================================

- (id)init
{
	// 1. setup groups
	NSDictionary *initData = nil;
	initData = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: INITIAL_GROUPDICT ofType: @"dict"]];
	groups = [[GroupTreeNode treeFromDictionary: initData] retain];
	//groupTreeData = [[GroupTreeNode initWithName:@"Initial Upload" isLeaf:NO] retain];
	// 2. setup filesystem browser
	//...
	return self;
}

- (void)dealloc
{
	[groups release];
	[super dealloc];
}

- (void)awakeFromNib
{
	NSTableColumn *tableColumn = nil;
	ImageAndTextCell *imageAndTextCell = nil;
	NSButtonCell *buttonCell = nil;
	
	
	tableColumn = [groupOutlineView tableColumnWithIdentifier: COLUMNID_NAME];
	imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
	[imageAndTextCell setEditable: YES];
	[imageAndTextCell setStringValue:@"First Group"];
	[imageAndTextCell setImage:[NSImage imageNamed:@"GroupIcon.tiff"]];
	[tableColumn setDataCell:imageAndTextCell];	
	/*
	tableColumn = [groupOutlineView tableColumnWithIdentifier: @"Attributes"];
    buttonCell = [[[NSButtonCell alloc] initTextCell: @""] autorelease];
    [buttonCell setEditable: YES];
    [buttonCell setButtonType: NSSwitchButton];
    [tableColumn setDataCell:buttonCell];
	*/
	[groupOutlineView registerForDraggedTypes:[NSArray arrayWithObjects:NSStringPboardType, NSFilenamesPboardType, nil]];
}

// ================================================================
// Accessors for dragging and highlighting...
// ================================================================

- (NSArray *)draggedNodes   { return draggedNodes; }
- (NSArray *)selectedNodes { return [groupOutlineView allSelectedItems]; }

// ================================================================
// Setup for drap and drop...
// ================================================================

- (BOOL)allowOnDropOnGroup { return YES; }
- (BOOL)allowOnDropOnLeaf  { return NO; }
- (BOOL)allowBetweenDrop   { return YES; }
- (BOOL)onlyAcceptDropOnRoot { return NO; }

// ================================================================
// Target / action methods. (most wired up in IB)
// ================================================================

- (void)addGroup:(id)sender
{
    // Adds a new expandable entry to the current selection, by inserting a new group node.
    [self _addNewGroup: [GroupTreeNode treeNodeWithData: [GroupData groupDataWithName:@"New Upload Group"]]];
}

- (void)outlineViewAction:(id)olv
{
    // This message is sent from the groupOutlineView as it's action (see the connection in IB).
    NSArray *selectedNodes = [self selectedNodes];
    
    if([selectedNodes count]>1)
		NSLog(@"Multiple Rows Selected");
		
    else if ([selectedNodes count]==1) {
		NSLog([NODE_DATA([selectedNodes objectAtIndex:0]) description]);
		[appController loadImage:[NODE_DATA([selectedNodes objectAtIndex:0]) fullPath]];
    } else 
		NSLog(@"Nothing Selected");
}

- (void)deleteSelections:(id)sender
{
    NSArray *selection = [self selectedNodes];
    
    // Tell all of the selected nodes to remove themselves from the model.
    [selection makeObjectsPerformSelector: @selector(removeFromParent)];
    [groupOutlineView deselectAll:nil];
    [groupOutlineView reloadData];
}

// ================================================================
//  NSOutlineView data source methods. (The required ones)
// ================================================================

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

// Optional method: needed to allow editing.
- (void)outlineView:(NSOutlineView *)olv setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if([[tableColumn identifier] isEqualToString: COLUMNID_NAME]) {
		[NODE_DATA(item) setName: object];
		
    } else if ([[tableColumn identifier] isEqualToString: COLUMNID_IS_EXPANDABLE]) {
		[NODE_DATA(item) setIsExpandable: [object boolValue]];
		if (![NODE_DATA(item) isExpandable] && [groupOutlineView isItemExpanded: item]) 
			[groupOutlineView collapseItem: item];
		
    } else if([[tableColumn identifier] isEqualToString: COLUMNID_NODE_KIND]) {
		// We don't allow editing of this column, so we should never actually get here.
    }
}

// ================================================================
//  NSOutlineView delegate methods.
// ================================================================

- (BOOL)outlineView:(NSOutlineView *)olv shouldExpandItem:(id)item
{
    return [NODE_DATA(item) isExpandable];
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{    
    if ([[tableColumn identifier] isEqualToString: COLUMNID_NAME]) {
		// Make sure the image and text cell has an image.  If not, give it something random.
		if (item && ![NODE_DATA(item) iconRep]) 
			[NODE_DATA(item) setIconRep: [NSImage imageNamed:@"GroupIcon.tif"]];
		
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

- (BOOL)outlineView:(NSOutlineView *)olv shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	return NO;
}

// ================================================================
//  NSOutlineView data source methods. (dragging related)
// ================================================================

- (BOOL)outlineView:(NSOutlineView *)olv writeItems:(NSArray*)items toPasteboard:(NSPasteboard*)pboard
{
	int counter;
    draggedNodes = items; // Don't retain since this is just holding temporaral drag information, and it is only used during a drag!  We could put this in the pboard actually.

	for(counter = 0; counter < [draggedNodes count]; counter++) {
		if([NODE_DATA([draggedNodes objectAtIndex:counter]) isGroup]) {
			return NO;
		}
	}
	
    // Provide data for our custom type, and simple NSStrings.
    [pboard declareTypes:[NSArray arrayWithObjects: CUSTOM_PBOARD_TYPE, NSStringPboardType, nil] owner:self];
    
    // the actual data doesn't matter since DragDropSimplePboardType drags aren't recognized by anyone but us!.
    [pboard setData:[NSData data] forType:CUSTOM_PBOARD_TYPE]; 
    
    // Put string data on the pboard... notice you candrag into TextEdit!
    [pboard setString: [draggedNodes description] forType: NSStringPboardType];

    return YES;
}

- (unsigned int)outlineView:(NSOutlineView*)olv validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)childIndex
{
    // This method validates whether or not the proposal is a valid one. Returns NO if the drop should not be allowed.
    GroupTreeNode *targetNode = item;
    BOOL targetNodeIsValid = YES;

	NSLog(@"Class of dragged Item: %@", [item class]);
	// check if we are dragging from within the group box, or dragging from the file browser...
	if(groupOutlineView == [info draggingSource]) {
		NSLog(@"Dragging from within the group box.");
		if(targetNode == nil) {
			targetNodeIsValid = NO;
		}
	
	} else {
		NSLog(@"Dragging from the file browser.");
		// don't allow a file to be created as a new group (dropped on something other than a group.)
		if(targetNode == nil) {
			targetNodeIsValid = NO;
		}	
	}
    
    // Set the item and child index in case we computed a retargeted one.
    [groupOutlineView setDropItem:targetNode dropChildIndex:childIndex];
    
    return targetNodeIsValid ? NSDragOperationGeneric : NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView*)olv acceptDrop:(id <NSDraggingInfo>)info item:(id)targetItem childIndex:(int)childIndex {
    TreeNode * 		parentNode = nil;
    
    // Determine the parent to insert into and the child index to insert at.
    if ([NODE_DATA(targetItem) isLeaf]) {
        parentNode = (GroupTreeNode*)(childIndex == NSOutlineViewDropOnItemIndex ? [targetItem nodeParent] : targetItem);
        childIndex = (childIndex == NSOutlineViewDropOnItemIndex ? [[targetItem nodeParent] indexOfChild: targetItem]+1 : 0);
        if ([NODE_DATA(parentNode) isLeaf]) [NODE_DATA(parentNode) setIsLeaf:NO];
    } else {            
        parentNode = SAFENODE(targetItem);
		childIndex = (childIndex == NSOutlineViewDropOnItemIndex?0:childIndex);
    }
    
    [self _performDropOperation:info onNode:parentNode atIndex:childIndex];
        
    return YES;
}

@end

// ================================================================
// Private methods...
// ================================================================

@implementation GroupController (Private)

// called by the add group button...
- (void)_addNewGroup:(GroupTreeNode *)newChild
{
	[groups insertChild: newChild atIndex: [groups numberOfChildren]];
	[groupOutlineView reloadData];
}

- (NSImage *)_iconForFileType:(NSString *)extension
{
    NSImage *image = [[NSWorkspace sharedWorkspace] iconForFileType:extension];
	[image setSize:NSMakeSize(16, 16)];
	return image;
}

- (NSImage *)_thumbForFileType:(NSString *)extension
{
	NSImage *image = [[NSWorkspace sharedWorkspace] iconForFileType:extension];
	[image setSize:NSMakeSize(128, 128)];
	return image;
}

- (void)_performDropOperation:(id <NSDraggingInfo>)info onNode:(TreeNode*)parentNode atIndex:(int)childIndex {
    // Helper method to insert dropped data into the model. 
    NSPasteboard *pboard = [info draggingPasteboard];
    NSMutableArray *itemsToSelect = nil;
	int counter;
    
    // Do the appropriate thing depending on wether the data is DragDropSimplePboardType or NSStringPboardType.
    if ([pboard availableTypeFromArray:[NSArray arrayWithObjects:CUSTOM_PBOARD_TYPE, nil]] != nil) {
        GroupController *dragDataSource = [[info draggingSource] dataSource];
        NSArray *_draggedNodes = [TreeNode minimumNodeCoverFromNodesInArray: [dragDataSource draggedNodes]];
        NSEnumerator *draggedNodesEnum = [_draggedNodes objectEnumerator];
        GroupTreeNode *_draggedNode = nil, *_draggedNodeParent = nil;
        
		itemsToSelect = [NSMutableArray arrayWithArray:[self selectedNodes]];
	
        while ((_draggedNode = [draggedNodesEnum nextObject])) {
            _draggedNodeParent = (GroupTreeNode*)[_draggedNode nodeParent];
            if (parentNode==_draggedNodeParent && [parentNode indexOfChild: _draggedNode]<childIndex) childIndex--;
            [_draggedNodeParent removeChild: _draggedNode];
        }
        [parentNode insertChildren: _draggedNodes atIndex: childIndex];
		
    } else if ([pboard availableTypeFromArray:[NSArray arrayWithObject: NSStringPboardType]]) {
        NSString *string = [pboard stringForType: NSStringPboardType];
		NSArray *list = [string componentsSeparatedByString:@","];
		for(counter = 0; counter < [list count]; counter++) {
			if(![(NSString *)[list objectAtIndex:counter] isEqualToString:@""]) { 
				//NSLog(@"Adding: %@", (NSString *)[list objectAtIndex:counter]);
				GroupData *newData = [GroupData leafDataWithName:[(NSString *)[list objectAtIndex:counter] lastPathComponent]];
				[newData setFullPath:(NSString *)[list objectAtIndex:counter]];
				//NSLog(@"Fullpath %@", [newData fullPath]);
				if([newData fullPath]) {
					NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:[newData fullPath]];
					[image setSize:NSMakeSize(16, 16)];
					[newData setIconRep:image];
				}
				//NSLog(@"Creating new tree node.");
				GroupTreeNode *newItem = [GroupTreeNode treeNodeWithData: newData];
				//NSLog(@"adding new item to parent node.");
				[parentNode insertChild:newItem atIndex:childIndex++];
			}
		}

    }

    [groupOutlineView reloadData];
    //[groupOutlineView selectItems: itemsToSelect byExtendingSelection: NO];
}

@end
