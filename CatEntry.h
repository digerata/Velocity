//
//  CatEntry.h
//  Velocity
//
//  Created by Mike Wille on 9/29/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CatEntry : NSObject {
	NSString *catID;
	NSString *catName;
	int depth;
}

- (void)setCatID:(NSString *)newID;
- (NSString *)catID;
- (void)setCatName:(NSString *)newName;
- (NSString *)catName;
- (void)setDepth:(int)newDepth;
- (int)depth;

@end
