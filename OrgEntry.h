//
//  OrgEntry.h
//  Velocity
//
//  Created by Mike Wille on 9/27/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OrgEntry : NSObject {
	NSString *orgName;
	NSString *orgID;
}

- (NSString *)orgName;
- (void)setOrgName:(NSString *)name;

- (NSString *)orgID;
- (void)setOrgID:(NSString *)aID;

@end
