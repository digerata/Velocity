//
//  CategoryTreeNode.m
//  Velocity
//
//  Created by Mike Wille on 9/29/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import "CategoryTreeNode.h"
#import "TreeNode.h"
#import "CatEntry.h"

@implementation CategoryData

- (id)initWithName:(NSString*)str isLeaf:(BOOL)leaf {
    self = [super init];
    if (self==nil) return nil;
    name = [str retain];
    isLeaf = leaf;
    iconRep = nil;
    isExpandable = !isLeaf;
    
    return self;
}

+ (id)leafDataWithCatEntry:(CatEntry *)cat {
    // Convenience method to return a leaf node with its name set.
	CategoryData *catData = [[[CategoryData alloc] initWithName:[cat catName] isLeaf:YES] autorelease];
	[catData setName:[cat catName]];
	[catData setCatID:[cat catID]];
    return catData;
}

+ (id)groupDataWithCatEntry:(CatEntry *)cat {
    // Convenience method to return a branch node with its name set.
	CategoryData *catData = [[[CategoryData alloc] initWithName:[cat catName] isLeaf:NO] autorelease];
	[catData setName:[cat catName]];
	[catData setCatID:[cat catID]];
    return catData;
}

- (void)dealloc {
    [name release];
    [iconRep release];
    name = nil;
    iconRep = nil;
    [super dealloc];
}

- (void)setName:(NSString *)str { 
    if (!name || ![name isEqualToString: str]) {
	[name release]; 
	name = [str retain]; 
    }
}

- (NSString*)name { 
    return name; 
}

- (NSString*)description
{
	return name;
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

- (void)setIsLeaf:(BOOL)leaf { 
    isLeaf = leaf; 
}

- (BOOL)isLeaf { 
    return isLeaf; 
}

- (BOOL)isGroup { 
    return !isLeaf; 
}

- (void)setIconRep:(NSImage*)ir {
    if (!iconRep || ![iconRep isEqual: ir]) {
	[iconRep release];
	iconRep = [ir retain];
    }
}
- (NSImage*)iconRep {
    return iconRep;
}

- (void)setIsExpandable: (BOOL)expandable {
    isExpandable = expandable;
}

- (BOOL)isExpandable {
    return isExpandable;
}

- (NSComparisonResult)compare:(TreeNodeData*)other {
    // We want the data to be sorted by name, so we compare [self name] to [other name]
    CategoryData *_other = (CategoryData *)other;
    return [catID compare: [_other catID]];
}

@end

@implementation CategoryTreeNode

- (id) initFromArray:(NSArray *)catList
{
	int *start = malloc(sizeof(int));
	*start = 0;
	self = [CategoryTreeNode loadArray:catList atIndex:start withDepth:1];
	free(start);
	return self;
}

+ (id) loadArray:(NSArray *)catList 
			 atIndex:(int *)curIndex 
		   withDepth:(int)curDepth 
{
	// catList is an array of CatEntry objects with name, id, and depth as attributes...
	// this function loops through the list and calls itself when a new depth is encountered.  It
	// returns when the depth is less then curDepth
	int counter = *curIndex;
	CategoryData *data;
	CatEntry *curCat;
	
	NSString *tabs = [[NSString alloc] init];
	int j = 0;
	for(j = 0; j < curDepth; j++) {
		tabs = [tabs stringByAppendingString:@"\t"];
	}
	
	if(counter >= [catList count]) {
		//NSLog(@"%@End of cat list, returning.", tabs);
		return nil;
	}
	
	//NSLog(@"%@[loadArray atIndex:%d withDepth: %d]", tabs, counter, curDepth);
	//NSLog(@"Cur Cat: %@", [catList objectAtIndex:curIndex]);
	
	if(counter + 1 < [catList count] && [[catList objectAtIndex:counter + 1] depth] > [[catList objectAtIndex:counter] depth]) {
		//NSLog(@"%@Creating new group node for %@", tabs, [[catList objectAtIndex:counter] catName]);
		data = [CategoryData groupDataWithCatEntry:[catList objectAtIndex:counter]];
	} else {
		//NSLog(@"%@Creating new leaf node for %@", tabs, [[catList objectAtIndex:counter] catName]);
		data = [CategoryData leafDataWithCatEntry:[catList objectAtIndex:counter]];
	}
	counter++;
	*curIndex = counter;
	
	CategoryTreeNode *tree = [[CategoryTreeNode alloc] initWithData:data parent:nil children:[NSArray array]];
	//NSLog(@"%@Looking for children...", tabs);
	while(counter < [catList count]) {
		curCat = [catList objectAtIndex:counter];
		if([curCat depth] < curDepth) {
			//NSLog(@"%@\t%@ - Depth:%d is less then current:%d, returning...", tabs, [curCat catName], [curCat depth], curDepth);
			*curIndex = counter;
			return tree;
			
		} else if([curCat depth] > curDepth) {
			//NSLog(@"%@\t%@ - Depth:%d is >= curDepth:%d at index: %d, recursing...", tabs, [curCat catName], [curCat depth], curDepth, *curIndex);
			[tree insertChild:[CategoryTreeNode loadArray:catList atIndex:curIndex withDepth:[curCat depth]] atIndex:[tree numberOfChildren]];
			//NSLog(@"%@Counter = %d <> CurIndex: %d", tabs, counter, *curIndex);
			counter = *curIndex;
			
		} else {
			break;
		}
		//NSLog(@"%@Moving to next possible child.", tabs);
	}
	//NSLog(@"%@Done searching children, returning...", tabs);
	*curIndex = counter;
    return tree;
}

+ (id) treeFromArray:(NSArray *)catList {
	NSLog(@"[CategoryTreeNode treeFromArray]");
    return [[[CategoryTreeNode alloc] initFromArray:catList] autorelease];
}

@end

