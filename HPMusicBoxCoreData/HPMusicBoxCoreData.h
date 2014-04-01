//
//  HPMusicBoxCoreData.h
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 22/07/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ArtistEntity.h"
#import "SmartPlaylistEntity.h"
#import "CriteriaPLEntity.h"
#import "AlbumEntity.h"
#import "EventEntity.h"
#import "SearchEventEntity.h"

#define ERROR_ALREADY_EXIST 1001

#define COREDATA_DBNAME @"MusicBox.sqlite"
#define ICLOUD_CONTENT_NAME_KEY @"com-peroteau-herve-icloud-musicbox"
#define ICLOUD_FOLDER_UPDATE @"musicboxdata"

#define NOTIFICATION_MUSICBOX_COREDATA_ICLOUD_REFRESH @"com.peroteau.herve.musicBox.coredata.icloud.refresh"

typedef NS_ENUM(NSUInteger, HPTypeSearchEvent) {
    
    HPTypeSearchEventUnknown,
    HPTypeSearchEventByLocation,
    HPTypeSearchEventByLocationLimitArtistsLibrary,
    HPTypeSearchEventByArtist
};


@interface HPMusicBoxCoreData : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/**
 Directory where database is store
 By default, database is store at [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
 */
+(void) setBaseDocumentsURL:(NSURL *) documentsURL;


/**
 You need call one time, methode setBaseDocumentsURL, before call sharedManager
 */
+(HPMusicBoxCoreData *) sharedManager;

#pragma mark - API Twitter Artist

/** create if not already exist
 */
-(ArtistEntity *) findOrCreateArtistWithName:(NSString *) fullName;


#pragma mark - API PlayLists with criterias

-(NSArray *) getSmartPlaylists;

-(SmartPlaylistEntity *) createSmartPlaylist:(NSString *) title;

-(SmartPlaylistEntity *) createNewSmartPlaylist:(NSString *) title uuid:(NSString *)uuid;

-(CriteriaPLEntity *) createCriteria;

-(SmartPlaylistEntity *) findSmartPLaylistWithUUID:(NSString *) uuid;

#pragma mark - Album : indice satisfaction

// return Array of AlbumEntity
-(NSArray *) getAlbumsEntities;

-(AlbumEntity *) findOrCreateAlbumEntity:(NSString *)keyAlbum;

#pragma mark - Events

-(EventEntity *) findEventByEventID:(NSString *)eventId;
-(EventEntity *) findEventByEventID:(NSString *)eventId inContext:(NSManagedObjectContext *)context;

-(EventEntity *) createEventWithEventID:(NSString *)eventId;
-(EventEntity *) createEventWithEventID:(NSString *)eventId inContext:(NSManagedObjectContext *)context;

-(SearchEventEntity *) findSearchEventsByUUID:(NSString *)uuid;
-(SearchEventEntity *) createSearchEventsWithTitle:(NSString *)title AndTypeSearch:(HPTypeSearchEvent)typeSearch;

-(NSArray *) getListSearchEventsForArtist:(BOOL)onlyWithEvents;
-(NSArray *) getListSearchEventsForLocation;

-(void) updateDistanceEventWithLocation:(CLLocation *)location
                             Completion:(void (^)(BOOL success, NSError *error))completion;

#pragma mark - FetchRequest for use with NSFetchedResultsController

-(NSFetchRequest *) createFetchRequestEventsAfterDate:(NSDate *) date;

-(NSFetchRequest *) createFetchRequestEventsAfterDate:(NSDate *) date
                                            ForArtist:(NSString *) artist;

-(NSFetchRequest *) createFetchRequestEventsAfterDate:(NSDate *) date
                                            ForSearch:(NSString *) search;

-(NSFetchRequest *) createFetchRequestEventsAfterDate:(NSDate *) date
                                            ForSearch:(NSString *) search
                                        MaxKilometers:(NSInteger) maxKilometers;

#pragma mark - Update, Delete, Save

-(void) deleteObject:(NSManagedObject *) object;
-(void) save;


@end
