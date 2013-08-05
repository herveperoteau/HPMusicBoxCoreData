//
//  CriteriaPLEntity+Helper.m
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 05/08/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import "CriteriaPLEntity+Helper.h"

@implementation CriteriaPLEntity(Helper)

-(NSString *) toString {
    
    NSString *result = [NSString stringWithFormat:@"key=%@, condition=%@, value=%@",
                        self.key, self.condition, self.value];
    
    return result;
}

@end
