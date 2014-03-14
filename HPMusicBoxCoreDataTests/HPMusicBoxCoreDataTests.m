//
//  HPMusicBoxCoreDataTests.m
//  HPMusicBoxCoreDataTests
//
//  Created by Hervé PEROTEAU on 22/07/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HPMusicBoxCoreData.h"
#import "HPMusicBoxCoreData_Private.h"
#import "ArtistEntity+Helper.h"
#import "CriteriaPLEntity.h"
#import "SmartPlaylistEntity+Helper.h"
#import "EventEntity.h"
#import "EventEntity+Helper.h"
#import "SearchEventEntity+Helper.h"


@interface HPMusicBoxCoreDataTests : XCTestCase

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation HPMusicBoxCoreDataTests {
    
    HPMusicBoxCoreData *coredata;
    
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    
    coredata = [HPMusicBoxCoreData sharedManager];
    
    [coredata setManagedObjectModel:self.managedObjectModel];
    [coredata setManagedObjectContext:self.managedObjectContext];
    [coredata setPersistentStoreCoordinator:self.persistentStoreCoordinator];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


#pragma mark - Tests units

- (void)testFindOrCreateTheStrokes
{
    NSString *name = @" The Strokes ";
    NSString *cleanName = @"strokes";
    
    NSError *error = nil;
    
    ArtistEntity *entity = [coredata findOrCreateArtistWithName:name];
    
    NSLog(@"entity=%@ error=%@", [entity toString], [error localizedDescription]);
    
    XCTAssertNotNil(entity, @"%@ Not exist and not created ???", name);
    XCTAssertEqualObjects(entity.cleanName, cleanName, @"Bad value in cleanName field");
    XCTAssertNil(error, @"error: %@", [error localizedDescription]);
}

- (void)testSmartPlaylist
{
    NSError *error;
    
    int NBPLAYLIST=10;
    int NBCRIT=5;
    
    for (int i=0; i<NBPLAYLIST; i++) {
    
        NSString *title = [NSString stringWithFormat:@"Playlist n°%d", (i+1)];
        
        SmartPlaylistEntity *playlist = [coredata createSmartPlaylist:title];
        
        XCTAssertNil(error, @"error: %@", [error localizedDescription]);
        XCTAssertNotNil(playlist, @"%@ not created ???", title);
        XCTAssertNil(playlist.count, @"Bizarre count is not nil !!!");
        
        for (int j=0; j<NBCRIT; j++) {
            
            CriteriaPLEntity *criteria = [coredata createCriteria];
            XCTAssertNil(error, @"error: %@", [error localizedDescription]);

            criteria.playlist = playlist;
            
            BOOL inverseOK = [playlist.criterias containsObject:criteria];

            XCTAssertTrue(inverseOK, @"Relation inverse pas mise a jour sur playlist %@ ???", playlist.title);
            
            NSString *condition = @"Equals";
            NSString *key = [NSString stringWithFormat:@"Key%d", (j+1)];
            NSString *val = [NSString stringWithFormat:@"Value%d", (j+1)];
            
            criteria.condition = condition;
            criteria.key = key;
            criteria.value = val;
        }
    }
    
    NSArray *playlists = [coredata getSmartPlaylists];
    
    XCTAssertNil(error, @"Error=%@", [error localizedDescription]);
    
    XCTAssertNotNil(playlists, @"Aucune playlist ???");
    
    BOOL equals = (playlists.count == NBPLAYLIST);
   
    XCTAssertTrue(equals, @"Bad count %d playlists <> %d ???", NBPLAYLIST, playlists.count);
    
    for (SmartPlaylistEntity *playlist in playlists) {
        
        NSLog(@"%@", [playlist toString]);
        
        equals = (playlist.criterias.count == NBCRIT);

        XCTAssertTrue(equals, @"Bad count %d criterias on pl %@ ???", NBCRIT, playlist.title);
    }
}

- (void)testEvents
{
    NSError *error = nil;
    
    NSString *eventID = @"TEST1";
    
    EventEntity *entity = [coredata findEventByEventID:eventID];
    
    if (entity == nil) {
        
        entity = [coredata createEventWithEventID:eventID];
        
        entity.title = @"Les vieilles charrues";
        entity.artistHeadliner = @"indochine";
        entity.artists = @"indochine, MGMT, Les strokes, Skip the use";
    }
    
    NSLog(@"entity=%@ error=%@", [entity toString], [error localizedDescription]);
    
    XCTAssertNotNil(entity, @"EventID %@ Not exist and not created ???", eventID);
    XCTAssertEqualObjects(entity.eventId, eventID, @"Bad value in eventId field");
    XCTAssertNil(error, @"error: %@", [error localizedDescription]);
}


- (void)testSearchEvents
{
    NSError *error = nil;
    
    NSString *title = @"TEST SEARCH";
    HPTypeSearchEvent typeSearch = HPTypeSearchEventByLocation;
    
    SearchEventEntity *entity = [coredata findSearchEventsByUUID:@"123"];
    
    if (entity == nil) {
        
        entity = [coredata createSearchEventsWithTitle:title
                                         AndTypeSearch:typeSearch];
        
        [coredata addSyncOperationWithBlock:^{
            
            entity.gpsLat = [NSNumber numberWithDouble:10.101010];
            entity.gpsLong = [NSNumber numberWithDouble:10.121212];
            entity.distance = [NSNumber numberWithDouble:10];
        }];
    }
    
    NSLog(@"entity=%@ error=%@", [entity toString], [error localizedDescription]);
    
    XCTAssertNotNil(entity, @"SearchEvents %@ Not exist and not created ???", title);
    XCTAssertEqualObjects(entity.title, title, @"Bad value in title field");
    XCTAssertNil(error, @"error: %@", [error localizedDescription]);
}

-(void) test_getListSearchEventsForArtist {
    
    [self createListsSearchEvents];
    
    NSArray *list = [coredata getListSearchEventsForArtist:NO];
    
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSLog(@"%@", [obj toString]);
    }];
    
}

-(void) test_getListSearchEventsForLocation {

    [self createListsSearchEvents];
    
    NSArray *list = [coredata getListSearchEventsForLocation];
    
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSLog(@"%@", [obj toString]);
    }];
}

-(void) createListsSearchEvents {
    
    [coredata createSearchEventsWithTitle:@"Paris"
                            AndTypeSearch:HPTypeSearchEventByLocation];
        
    [coredata createSearchEventsWithTitle:@"Bordeaux"
                            AndTypeSearch:HPTypeSearchEventByLocation];
    
    [coredata createSearchEventsWithTitle:@"Toulouse"
                            AndTypeSearch:HPTypeSearchEventByLocationLimitArtistsLibrary];
    
    [coredata createSearchEventsWithTitle:@"Marseille"
                            AndTypeSearch:HPTypeSearchEventByLocationLimitArtistsLibrary];
    
    [coredata createSearchEventsWithTitle:@"Lyon"
                            AndTypeSearch:HPTypeSearchEventByLocation];

    [coredata createSearchEventsWithTitle:@"Indochine"
                            AndTypeSearch:HPTypeSearchEventByArtist];
    
    [coredata createSearchEventsWithTitle:@"The strokes"
                            AndTypeSearch:HPTypeSearchEventByArtist];
    
    [coredata createSearchEventsWithTitle:@"MGMT"
                            AndTypeSearch:HPTypeSearchEventByArtist];
    
    [coredata createSearchEventsWithTitle:@"Skip the use"
                            AndTypeSearch:HPTypeSearchEventByArtist];
    
    [coredata createSearchEventsWithTitle:@"Rihanna"
                            AndTypeSearch:HPTypeSearchEventByArtist];
}

//-(NSArray *) getSmartPlaylists;
//
//-(SmartPlaylistEntity *) createSmartPlaylist:(NSString *) title uuid:(NSString *)uuid error:(NSError **) error;
//
//-(CriteriaPLEntity *) createCriteriaInPlaylist:(SmartPlaylistEntity *)playlist error:(NSError **) error;


//- (void)testSimulError
//{
//    NSString *name = @" The Strokes ";
//    NSString *cleanName = @"strokes";
//    
//    coredata.simulError = YES;
//    
//    NSError *error = nil;
//
//    ArtistEntity *entity = [coredata findOrCreateArtistWithName:name error:&error];
//    
//    NSLog(@"entity.cleanName=%@ dateUpdate=%@ error=%@", entity.cleanName, entity.dateUpdate, [error localizedDescription]);
//    
//    XCTAssertNotNil(entity, @"%@ Not exist and not created ???", name);
//    XCTAssertEqualObjects(entity.cleanName, cleanName, @"Bad value in cleanName field");
//    XCTAssertNotNil(error, @"pas eu d'erreur dans testSimulError ???");
//}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    // Marche pas sur le test unitaire de la lib
    //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ModelTest" withExtension:@"momd"];
    //NSLog(@"modelURL=%@", modelURL);
    //_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                   configuration:nil
                                                             URL:nil
                                                         options:nil
                                                           error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}



@end
