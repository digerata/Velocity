//
//  UploadGroup.h
//  Velocity
//
//  Created by Mike Wille on 9/21/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UploadGroup : NSObject {
	NSString *name;
	NSString *orgID;
	NSString *catID;
}

- (void)setName:(NSString *)aName;
- (NSString *)name;
- (void)setOrgID:(NSString *)aOrgID;
- (NSString *)orgID;
- (void)setCatID:(NSString *)catID;
- (NSString *)catID;

@end
