//
//  EventEntity+Helper.h
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 26/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "EventEntity.h"

typedef NS_ENUM(NSInteger, EventStatusOfRead) {
    EventStatusNotRead = 0,
    EventStatusNotReadAfterModification = 1,
    EventStatusRead = 2
};

@interface EventEntity (Helper)

-(NSString *) toString;

-(EventStatusOfRead) statusOfRead;
-(void) setStatusOfRead:(EventStatusOfRead)status;

@end
