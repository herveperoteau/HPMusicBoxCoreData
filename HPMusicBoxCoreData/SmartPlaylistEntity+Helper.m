//
//  SmartPlaylistEntity+Helper.m
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 05/08/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import "SmartPlaylistEntity+Helper.h"
#import "CriteriaPLEntity+Helper.h"

@implementation SmartPlaylistEntity(Helper)

-(NSString *) toString {
    
    NSString *result = [NSString stringWithFormat:@"title=%@, count=%@, dateLastCount=%@, dateCreate=%@",
                        self.title, self.count, self.dateLastCount, self.dateCreate];

    result = [result stringByAppendingString:@"Criterias:\n"];
    
    for (CriteriaPLEntity *crit in self.criterias) {
        
        result  = [result stringByAppendingString:[crit toString]];
        result  = [result stringByAppendingString:@"\n"];
    }
    
    return result;
}

@end
