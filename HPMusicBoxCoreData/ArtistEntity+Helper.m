//
//  ArtistEntity+Helper.m
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 05/08/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import "ArtistEntity+Helper.h"

@implementation ArtistEntity(Helper)

-(NSString *) toString {
    
    NSString *result = [NSString stringWithFormat:@"cleanName=%@, twitterAccount=%@, dateUpdate=%@",
                        self.cleanName, self.twitterAccount, self.dateUpdate];
    
    return result;
}

@end
