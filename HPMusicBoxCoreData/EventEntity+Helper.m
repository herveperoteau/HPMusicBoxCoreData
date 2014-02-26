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


@end
