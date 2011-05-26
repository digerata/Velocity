//
//  FileController.m
//  Velocity
//
//  Created by Mike Wille on 9/15/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import "FileController.h"
#import "FileSystemItem.h"
#import "ImageAndTextCell.h"
#import "AppController.h"
#import "NSOutlineView_Extensions.h"

#define COLUMNID_IS_EXPANDABLE	 	@"IsExpandableColumn"
#define COLUMNID_NODE_KIND			@"NodeKindColumn"

@interface FileController (Private)
- (NSImage *)_iconForFilePath:(NSString *)path;
- (NSImage *)_iconForFileType:(NSString *)extension;
- (NSImage *)_thumbForFileType:(NSString *)extension;
@end

@implementation FileController

// ================================================================
// Initialization...
// ================================================================

- (id)init
{
	// 1. setup groups
	rootPath = @"/";
	root = [FileSystemItem rootItem:rootPath];
	//groupTreeData = [[SimpleTreeNode initWithName:@"Initial Upload" isLeaf:NO] retain];
	// 2. setup filesystem browser
	//...
	return self;
}

- (void)dealloc
{
	[root release];
	[rootPath release];
	[super dealloc];
}

- (void)awakeFromNib
{
	NSTableColumn *tableColumn = nil;
	ImageAndTextCell *imageAndTextCell = nil;
	NSButtonCell *buttonCell = nil;
	
	
	tableColumn = [fileOutlineView tableColumnWithIdentifier: @"FileEntry"];
	imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
	[imageAndTextCell setEditable: YES];
	[imageAndTextCell setStringValue:@"First Group"];
	[imageAndTextCell setImage:[self _iconForFilePath:@"/"]];
	[tableColumn setDataCell:imageAndTextCell];	
	
	[fileOutlineView registerForDraggedTypes:[NSArray arrayWithObjects:NSStringPboardType, NSFilenamesPboardType, nil]];
	
	[fileOutlineView expandItem:[fileOutlineView itemAtRow:0]];
}

// ================================================================
// DataSource methods...
// ================================================================

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	return (item == nil) ? 1 : [(FileSystemItem *)item numberOfChildren];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id) item
{
	return (item == nil) ? YES : ([item numberOfChildren] != -1);
}

- (id)outlineView:(NSOutlineView *)outlineView
					child:(int)index
					ofItem:(id)item
{
	return (item == nil) ? [FileSystemItem rootItem:rootPath] : [item childAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView
			objectValueForTableColumn:(NSTableColumn *)tableColumn
			byItem:(id)item
{
	return (item == nil) ? @"/shit" : [item relativePath];
}

// ================================================================
// Outline Delegates
// ================================================================

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	return (item == nil) ? NO : ([item numberOfChildren] == -1);
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{    
    if ([[tableColumn identifier] isEqualToString: @"FileEntry"]) {
		// Make sure the image and text cell has an image.  If not, give it the system icon
		if(item) {
			if(![(FileSystemItem *)item icon]) {
				[(FileSystemItem *)item setIcon:[self _iconForFilePath:[(FileSystemItem *)item fullPath]]];
			}
			// Set the image of the cell...
			[(ImageAndTextCell*)cell setImage:[(FileSystemItem *)item icon]];

			// Set the text of the cell...
			[(ImageAndTextCell*)cell setStringValue: [(FileSystemItem *)item relativePath]];
		}
    } else if ([[tableColumn identifier] isEqualToString: @"FileSizeColumn"]) {
		//[cell setStringValue:[NSString stringWithFormat:@"%@", [(FileSystemItem *)item fileSize]]];
		[cell setStringValue:@" "];		

	} else if ([[tableColumn identifier] isEqualToString: @"LastModifiedColumn"]) {
		//[cell setStringValue:[(FileSystemItem *)item lastModified]];
		[cell setStringValue:@" "];

    } else if ([[tableColumn identifier] isEqualToString: COLUMNID_IS_EXPANDABLE]) {

		if([(FileSystemItem *)item numberOfChildren] > 0)
			[cell setEnabled: YES];
		else
			[cell setEnabled: NO];

    } else if ([[tableColumn identifier] isEqualToString: COLUMNID_NODE_KIND]) {
		// Don't do anything unusual for the kind column.
    } else {
		// haven't supported that column yet (whatever it is)
		[cell setStringValue:@" "];
	}
}

// ================================================================
// Accessors for dragging and highlighting...
// ================================================================

- (NSArray *)draggedNodes   { return draggedNodes; }
- (NSArray *)selectedNodes { return [fileOutlineView allSelectedItems]; }

// ================================================================
// Setup for drap and drop...
// ================================================================

- (BOOL)allowOnDropOnGroup { return YES; }
- (BOOL)allowOnDropOnLeaf  { return NO; }
- (BOOL)allowBetweenDrop   { return YES; }
- (BOOL)onlyAcceptDropOnRoot { return NO; }

- (void)outlineViewAction:(id)olv
{
    // This message is sent from the groupOutlineView as it's action (see the connection in IB).
    NSArray *selectedNodes = [self selectedNodes];
    
    if([selectedNodes count]>1)
		NSLog(@"Multiple Rows Selected");
		
    else if ([selectedNodes count]==1) {
		NSLog([(FileSystemItem *)([selectedNodes objectAtIndex:0]) relativePath]);
		[appController loadImage:[(FileSystemItem *)[selectedNodes objectAtIndex:0] fullPath]];
   } else 
		NSLog(@"Nothing Selected");
}

// ================================================================
//  NSOutlineView data source methods. (dragging related)
// ================================================================

- (BOOL)outlineView:(NSOutlineView *)olv writeItems:(NSArray*)items toPasteboard:(NSPasteboard*)pboard
{
	int counter;
//    draggedNodes = items; // Don't retain since this is just holding temporaral drag information, and it is only used during a drag!  We could put this in the pboard actually.
    
    // Provide data for our custom type, and simple NSStrings.
    //[pboard declareTypes:[NSArray arrayWithObjects: CUSTOM_PBOARD_TYPE, NSStringPboardType, nil] owner:self];
    [pboard declareTypes:[NSArray arrayWithObjects: NSStringPboardType, nil] owner:self];
    // the actual data doesn't matter since DragDropSimplePboardType drags aren't recognized by anyone but us!.
	//[pboard setData:items forType:CUSTOM_PBOARD_TYPE]; 
    
	NSString *filenames = [NSString string];
	for(counter = 0; counter < [items count]; counter++) {
		NSString *file = [(FileSystemItem *)[items objectAtIndex:counter] fullPath];
		file = [file stringByAppendingString:@","];
		filenames = [filenames stringByAppendingString:file];
	}
	NSLog(@"Writing: %@", filenames);
	
	[pboard setString:filenames forType:NSStringPboardType];

    return YES;;
}


- (void)changeRoot:(NSString *)path
{
	NSLog(@"FileController:changeRoot:%@", path);
	[path retain];
	[rootPath release];
	rootPath = path;
	
	root = [FileSystemItem rootItem:rootPath];
    [fileOutlineView reloadData];
	[fileOutlineView expandItem:[fileOutlineView itemAtRow:0]];
	
	NSLog(@"New root: %@", [root fullPath]);
}
@end

// ================================================================
// Private methods...
// ================================================================

@implementation FileController (Private)

- (NSImage *)_iconForFilePath:(NSString *)path
{
    NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:path];
	[image setSize:NSMakeSize(16, 16)];
	return image;
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

@end


