//
//  SearchEventEntity.h
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 26/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SearchEventEntity : NSManagedObject

@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * typeSearch;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * gpsLong;
@property (nonatomic, retain) NSNumber * gpsLat;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSDate * dateUpdate;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSNumber * countNotRead;

@end
