//
//  SearchEventEntity+Helper.m
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 26/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "SearchEventEntity+Helper.h"

@implementation SearchEventEntity (Helper)

-(NSString *) toString {
    
    NSString *result = @"SearchEventEntity: ";

    result = [result stringByAppendingFormat:@"uuid:%@, ", self.uuid];
    result = [result stringByAppendingFormat:@"title:%@, ", self.title];
    result = [result stringByAppendingFormat:@"typeSearch:%@, ", self.typeSearch];
    result = [result stringByAppendingFormat:@"text:%@, ", self.text];
    result = [result stringByAppendingFormat:@"gps:(%@, %@) distance:(%@), ", self.gpsLat, self.gpsLong,
              self.distance];
    result = [result stringByAppendingFormat:@"dateUpdate:%@, count=%@, notRead=%@", self.dateUpdate, self.count, self.countNotRead];
    
    result = [result stringByAppendingString:@"\n---------------------------\n"];

    return result;
}

@end
