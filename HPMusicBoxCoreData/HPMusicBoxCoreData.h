//
//  HPMusicBoxCoreData.h
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 22/07/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArtistEntity.h"
#import "SmartPlaylistEntity.h"
#import "CriteriaPLEntity.h"
#import "AlbumEntity.h"

#define ERROR_ALREADY_EXIST 1001

#define COREDATA_DBNAME @"MusicBox.sqlite"
#define ICLOUD_CONTENT_NAME_KEY @"com-peroteau-herve-icloud-musicbox"
#define ICLOUD_FOLDER_UPDATE @"musicboxdata"

#define NOTIFICATION_MUSICBOX_COREDATA_ICLOUD_REFRESH @"com.peroteau.herve.musicBox.coredata.icloud.refresh"

@interface HPMusicBoxCoreData : NSObject

/**
 Directory where database is store
 By default, database is store at [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
 */
+(void) setBaseDocumentsURL:(NSURL *) documentsURL;


/**
 You need call one time, methode setBaseDocumentsURL, before call sharedManager
 */
+(HPMusicBoxCoreData *) sharedManager;

// Prepare to iCloud
-(void) setup;

#pragma mark - API Twitter Artist

/** create if not already exist
 */
-(ArtistEntity *) findOrCreateArtistWithName:(NSString *) fullName error:(NSError **) error;


#pragma mark - API PlayLists with criterias

-(NSArray *) getSmartPlaylists:(NSError **) error;

-(SmartPlaylistEntity *) createSmartPlaylist:(NSString *) title error:(NSError **) error;

-(CriteriaPLEntity *) createCriteria:(NSError **) error;


#pragma mark - Album : indice satisfaction

// return Array of AlbumEntity
-(NSArray *) getAlbumsEntities:(NSError **) error;

-(AlbumEntity *) findOrCreateAlbumEntity:(NSString *)keyAlbum error:(NSError **) error;


#pragma mark - Delete, Save

-(void) deleteObject:(NSManagedObject *) object error:(NSError **) error;

/**
 * Save all modifications in DataBase
 * You need call this method when your application ended or switch in background mode
 */
-(BOOL) save:(NSError **) error;




@end
