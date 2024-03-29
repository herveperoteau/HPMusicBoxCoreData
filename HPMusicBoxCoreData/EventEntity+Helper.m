//
//  EventEntity+Helper.m
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 26/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "EventEntity+Helper.h"

@implementation EventEntity (Helper)

-(NSString *) toString {
    
    NSString *event = [NSString stringWithFormat:@"eventId=%@, title=%@ (cancelled=%@), artistHeadliner=%@, artists=%@, deb=%@, end=%@, descriptionEvent=%@", self.eventId, self.title, self.flagCancelled, self.artistHeadliner, self.artists, self.dateStart, self.dateEnd, self.descriptionEvent];
    
    NSString *eventLocation = [NSString stringWithFormat:@"city=%@, country=%@, locationName=%@, GPS (LAT:%@, LON:%@)", self.city, self.country, self.locationName, self.gpsLat, self.gpsLong];

    NSString *eventInfos = [NSString stringWithFormat:@"phoneNumber=%@, webSite=%@, urlImageEvent=%@, urlImageVenue=%@, tags=%@", self.phoneNumber, self.webSite, self.urlImageEvent, self.urlImageVenue, self.tags];

    NSString *eventStatus = [NSString stringWithFormat:@"statusAlert=%@, statusRead=%@", self.statusAlert, self.statusRead];

    NSString *result = [NSString stringWithFormat:@"Event: %@\n%@\n%@\n%@", event, eventLocation, eventInfos, eventStatus];
    
    return result;
}


-(EventStatusOfRead) statusOfRead {
    
    NSNumber *number = self.statusRead;
    
    if (number == nil) {
        return EventStatusNotRead;
    }
    
    switch ([number integerValue]) {
            
        case EventStatusNotRead :
        case EventStatusNotReadAfterModification :
        case EventStatusRead :
            return [number integerValue];
    }

    NSLog(@"%@.statusOfRead : BAD VALUE ???", self.class);
    return EventStatusNotRead;
}

-(void) setStatusOfRead:(EventStatusOfRead)status {
    
    self.statusRead = [NSNumber numberWithInteger:status];
}

-(CLLocationCoordinate2D) coordinate {
    
    CLLocationCoordinate2D result = kCLLocationCoordinate2DInvalid;
    if (self.gpsLat && self.gpsLong) {
        result = CLLocationCoordinate2DMake(self.gpsLat.floatValue,
                                            self.gpsLong.floatValue);
    }
    
    return result;
}

-(id<MKAnnotation>) asMKAnnotation {
    
    return (id<MKAnnotation>) self;
}

-(NSArray *) artistsArray {

    return [self arrayComponentsString:self.artists SeparatedByString:@"+"];
}

-(NSArray *) tagsArray {
    
    return [self arrayComponentsString:self.tags SeparatedByString:@"+"];
}

-(NSArray *) arrayComponentsString:(NSString *) str SeparatedByString:(NSString *)separ {
    
    NSArray *tmp = [str componentsSeparatedByString:separ];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [tmp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *objStr = (NSString *)obj;
        if (objStr.length>0) {
            [result addObject:objStr];
        }
    }];
    
    return [NSArray arrayWithArray:result];
}

-(void) updateDistanceWithMe:(CLLocation *) location {
    
    if (self.gpsLat == nil) {
        
        self.distance = [NSNumber numberWithDouble:kDistanceUnknown];
    }
    else {
    
        CLLocation *locationEvent = [[CLLocation alloc] initWithLatitude:self.gpsLat.floatValue
                                                               longitude:self.gpsLong.floatValue];
    
        CLLocationDistance distInMeter = [locationEvent distanceFromLocation:location];
    
        self.distance = [NSNumber numberWithDouble:distInMeter];
    }

//    NSLog(@"%@.updateDistanceWithMe Event:%@ Distance=%@ (meters)", self.class, self.title, self.distance);
}

@end
