//
//  EventEntity+Helper.h
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 26/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "EventEntity.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define kDistanceUnknown 99999999L

typedef NS_ENUM(NSInteger, EventStatusOfRead) {
    EventStatusNotRead = 0,
    EventStatusNotReadAfterModification = 1,
    EventStatusRead = 2
};

@interface EventEntity (Helper)

-(NSString *) toString;

-(EventStatusOfRead) statusOfRead;
-(void) setStatusOfRead:(EventStatusOfRead)status;

-(CLLocationCoordinate2D) coordinate;

-(id<MKAnnotation>) asMKAnnotation;

-(NSArray *) artistsArray;
-(NSArray *) tagsArray;

-(void) updateDistanceWithMe:(CLLocation *) location;

@end
