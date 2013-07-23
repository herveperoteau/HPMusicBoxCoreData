//
//  HPMusicBoxCoreData.h
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 22/07/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArtistEntity.h"

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


/** create if not already exist
 */
-(ArtistEntity *) findOrCreateArtistWithName:(NSString *) fullName;


/**
 * Save all modifications in DataBase
 * You need call this method when your application ended or switch in background mode
 */
-(BOOL) save;

@end
