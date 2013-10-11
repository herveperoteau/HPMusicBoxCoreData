//
//  AlbumEntity+Helper.m
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 11/10/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import "AlbumEntity+Helper.h"

@implementation AlbumEntity (Helper)

-(NSString *) toString {
    
    NSString *result = [NSString stringWithFormat:@"id=%@, title=%@, artist=%@ (%@), styles=%@, year=%@, satisfaction=%@, indiceLastShare=%@, dateLastCalcul=%@, dateLastShare=%@",
                        self.albumId, self.title, self.artist, self.artistCleanName, self.styles, self.year,
                        self.indiceSatisfaction, self.indiceLastShare, self.dateLastCalcul, self.dateLastShare];
    
    return result;
}


@end
