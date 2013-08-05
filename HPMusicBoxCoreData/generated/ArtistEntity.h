//
//  ArtistEntity.h
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 05/08/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ArtistEntity : NSManagedObject

@property (nonatomic, retain) NSString * cleanName;
@property (nonatomic, retain) NSDate * dateUpdate;
@property (nonatomic, retain) NSString * twitterAccount;

@end
