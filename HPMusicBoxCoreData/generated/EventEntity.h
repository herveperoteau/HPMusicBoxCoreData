//
//  EventEntity.h
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 28/03/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EventEntity : NSManagedObject

@property (nonatomic, retain) NSString * artistHeadliner;
@property (nonatomic, retain) NSString * artists;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSDate * dateEnd;
@property (nonatomic, retain) NSDate * dateStart;
@property (nonatomic, retain) NSString * descriptionEvent;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * eventId;
@property (nonatomic, retain) NSNumber * flagCancelled;
@property (nonatomic, retain) NSNumber * gpsLat;
@property (nonatomic, retain) NSNumber * gpsLong;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * statusAlert;
@property (nonatomic, retain) NSNumber * statusRead;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * urlImageEvent;
@property (nonatomic, retain) NSString * urlImageVenue;
@property (nonatomic, retain) NSString * webSite;

@end
