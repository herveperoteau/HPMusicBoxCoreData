//
//  ArtistEntity.h
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 23/07/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ArtistEntity : NSManagedObject

@property (nonatomic, retain) NSString * cleanName;
@property (nonatomic, retain) NSString * twitterAccount;
@property (nonatomic, retain) NSDate * dateUpdate;

@end
