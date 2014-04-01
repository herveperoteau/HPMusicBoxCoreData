//
//  HPMusicBoxCoreData.m
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 22/07/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//


#import "HPMusicBoxCoreData.h"
#import "HPMusicBoxCoreData_Private.h"
#import "HPMusicHelper.h"
#import "CriteriaPLEntity.h"
#import "ArtistEntity.h"
#import "PLBaseEntity.h"
#import "SmartPlaylistEntity.h"
#import "EventEntity+Helper.h"

#define AlbumEntityName @"AlbumEntity"
#define ArtistEntityName @"ArtistEntity"
#define EventEntityName @"EventEntity"
#define SearchEventEntityName @"SearchEventEntity"
#define CriteriaPLEntityName @"CriteriaPLEntity"
#define SmartPlaylistEntityName @"SmartPlaylistEntity"
#define ErrorDomain @"HPMusicBoxCoreData"

#define kStalenessInterval 60.0

//#define FATAL_CORE_DATA_ERROR(__error__) \
//NSLog(@"*** Fatal Error in %s:%d\n%@\n%@", __FILE__, __LINE__, error, [error userInfo]);\
//if ([(id) [[UIApplication sharedApplication] delegate] respondsToSelector:@selector(fatalCoreDataError:)]) {\
//[(id) [[UIApplication sharedApplication] delegate] performSelector:@selector(fatalCoreDataError:) withObject:error];\
//};

static NSURL *documentsURL = nil;
static HPMusicBoxCoreData *sharedMyManager = nil;

@interface HPMusicBoxCoreData()

@property (strong, nonatomic) NSURL *documentsURL;

@end

@implementation HPMusicBoxCoreData


+(void) setBaseDocumentsURL:(NSURL *) docUrl {
    
    NSAssert(sharedMyManager == nil, @"setBaseDocumentsURL has no effect after call sharedManager method !!!");
    
    documentsURL = [docUrl copy];
}

+(NSURL *) defaultStorageURL {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+(HPMusicBoxCoreData *) sharedManager {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        if (documentsURL == nil) {
            
            documentsURL = [HPMusicBoxCoreData defaultStorageURL];
        }
        
        HPMusicBoxCoreData *manager = [[HPMusicBoxCoreData alloc] initWithURLDocuments:documentsURL];
        sharedMyManager = manager;
    });
    
    return sharedMyManager;
}

#pragma mark - Initialisation

-(id) initWithURLDocuments:(NSURL *)docURL {
    
    if ( (self = [self init]) ) {
        
        self.documentsURL = docURL;
    }
    
    return self;
}

#pragma mark - Facade CoreData

-(ArtistEntity *) findOrCreateArtistWithName:(NSString *) fullName {
    
    ArtistEntity *entity = nil;
    
    entity = [self findArtistWithName:fullName];

    if (!entity) {
        
        entity = [self createArtistWithName:fullName];
    }

    return entity;
}

-(ArtistEntity *) createArtistWithName:(NSString *) fullName {
    
    __block ArtistEntity *result = nil;
    
    [self.managedObjectContext performBlockAndWait:^{
        
        NSString *cleanName = [self cleanNameArtist:fullName];

        NSManagedObjectContext *context = _managedObjectContext;

        ArtistEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:ArtistEntityName
                                                             inManagedObjectContext:context];
    
        entity.cleanName = cleanName;
        entity.dateUpdate = [NSDate date];
        
        result = entity;
    }];

    [self save];
    
    return result;
}

-(NSString *) cleanNameArtist:(NSString *)artist {
    
    NSString *cleanName = [HPMusicHelper cleanArtistName:artist PreserveAccent:NO PreservePrefix:NO];
    return cleanName;
}

-(ArtistEntity *) findArtistWithName:(NSString *) fullName {
    
    __block ArtistEntity *result = nil;
    
    [self.managedObjectContext performBlockAndWait:^{
    
        NSString *cleanName = [self cleanNameArtist:fullName];
        
        NSManagedObjectContext *context = _managedObjectContext;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:ArtistEntityName
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cleanName == %@", cleanName];
        
        [fetchRequest setPredicate:predicate];
        
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest
                                                         error:NULL];
        
        if (fetchedObjects.count > 0) {
            
            result = fetchedObjects[0];
        }
    }];

    return result;
}

#pragma mark - API PlayLists with criterias

-(NSArray *) getSmartPlaylists {

    __block NSMutableArray *tmpResult = [[NSMutableArray alloc] init];
    
    [self.managedObjectContext performBlockAndWait:^{
        
        NSManagedObjectContext *context = _managedObjectContext;

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity =[NSEntityDescription entityForName:SmartPlaylistEntityName
                                                 inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortByTitle = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        
        [fetchRequest setSortDescriptors:@[sortByTitle]];
        
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:NULL];
        
        [tmpResult addObjectsFromArray:fetchedObjects];
    }];

    return [NSArray arrayWithArray:tmpResult];
}

-(SmartPlaylistEntity *) createSmartPlaylist:(NSString *) title {
    
    NSString *uuid = [[NSUUID UUID] UUIDString];

    SmartPlaylistEntity *result = [self createNewSmartPlaylist:title uuid:uuid];

    return result;
}

-(SmartPlaylistEntity *) findSmartPLaylistWithUUID:(NSString *) uuid {
    
    __block SmartPlaylistEntity *result = nil;

    [self.managedObjectContext performBlockAndWait:^{
    
        NSManagedObjectContext *context = _managedObjectContext;
    
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
        NSEntityDescription *entity = [NSEntityDescription entityForName:SmartPlaylistEntityName
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];
    
        [fetchRequest setPredicate:predicate];
    
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest
                                                         error:NULL];
    
        if (fetchedObjects.count > 0) {
        
            result = fetchedObjects[0];
        }
    }];
    
    return result;
}


-(SmartPlaylistEntity *) createNewSmartPlaylist:(NSString *) title uuid:(NSString *)uuid {
    
    __block SmartPlaylistEntity *result = nil;
    
    [self.managedObjectContext performBlockAndWait:^{
        
        NSManagedObjectContext *context = _managedObjectContext;
    
        SmartPlaylistEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:SmartPlaylistEntityName
                                                                    inManagedObjectContext:context];
    
        entity.title = title;
        entity.uuid = uuid;
        entity.dateCreate = [NSDate date];
        
        result = entity;
    }];
    
    [self save];
    
    return result;
}

-(CriteriaPLEntity *) createCriteria {
    
    __block CriteriaPLEntity *result = nil;
    
    [self.managedObjectContext performBlockAndWait:^{

        NSManagedObjectContext *context = _managedObjectContext;
        
        CriteriaPLEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:CriteriaPLEntityName
                                                                 inManagedObjectContext:context];
    
        result = entity;
    }];

    [self save];
    
    return result;
}


#pragma mark - Album : indice satisfaction

// return Array of AlbumEntity
-(NSArray *) getAlbumsEntities {
    
    __block NSMutableArray *tmpResult = [[NSMutableArray alloc] init];
    
    [self.managedObjectContext performBlockAndWait:^{
        
        NSManagedObjectContext *context = _managedObjectContext;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity =[NSEntityDescription entityForName:AlbumEntityName
                                                 inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortByArtist = [[NSSortDescriptor alloc]  initWithKey:@"artistCleanName" ascending:YES];
        NSSortDescriptor *sortByYear = [[NSSortDescriptor alloc]  initWithKey:@"clean" ascending:YES];
        
        [fetchRequest setSortDescriptors:@[sortByArtist, sortByYear]];
        
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:NULL];
        
        [tmpResult addObjectsFromArray:fetchedObjects];
    }];

    return [NSArray arrayWithArray:tmpResult];
}

-(AlbumEntity *) findOrCreateAlbumEntity:(NSString *)keyAlbum {
    
    __block AlbumEntity *result = nil;
    
    [self.managedObjectContext performBlockAndWait:^{

        NSManagedObjectContext *context = _managedObjectContext;
    
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
        NSEntityDescription *entity = [NSEntityDescription entityForName:AlbumEntityName
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"albumId == %@", keyAlbum];
    
        [fetchRequest setPredicate:predicate];
    
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:NULL];
    
        if (fetchedObjects.count == 0) {
     
            // create ...
        
            result = [NSEntityDescription insertNewObjectForEntityForName:AlbumEntityName
                                                                inManagedObjectContext:context];
        
            result.albumId = keyAlbum;
        }
        else {
        
            result = fetchedObjects[0];
        }
    }];

    [self save];
    
    return result;
}

#pragma mark - Events

-(EventEntity *) findEventByEventID:(NSString *)eventId {
    
    return [self findEventByEventID:eventId inContext:self.managedObjectContext];
}

-(EventEntity *) findEventByEventID:(NSString *)eventId inContext:(NSManagedObjectContext *)context {
    
    NSAssert(context!=nil, @"context is nil !");
    
    __block EventEntity *result = nil;
    
    [context performBlockAndWait:^{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:EventEntityName
                                                    inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventId == %@", eventId];
        
        [fetchRequest setPredicate:predicate];
        
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest
                                                         error:NULL];
        
        if (fetchedObjects.count > 0) {
            
            result = fetchedObjects[0];
        }
    }];
    
    return result;
}

-(EventEntity *) createEventWithEventID:(NSString *)eventId {
    
    return [self createEventWithEventID:eventId inContext:self.managedObjectContext];
}

-(EventEntity *) createEventWithEventID:(NSString *)eventId inContext:(NSManagedObjectContext *)context {
    
    NSAssert(context!=nil, @"context is nil !");

    __block EventEntity *result = nil;
    
    [context performBlockAndWait:^{
        
        EventEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:EventEntityName
                                                            inManagedObjectContext:context];
        
        entity.eventId = eventId;
        
        result = entity;
    }];
    
    return result;
}


-(SearchEventEntity *) findSearchEventsByUUID:(NSString *)uuid {
    
    __block SearchEventEntity *result = nil;

    [self.managedObjectContext performBlockAndWait:^{
        
        NSManagedObjectContext *context = _managedObjectContext;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:SearchEventEntityName
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];
        [fetchRequest setPredicate:predicate];
        
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest
                                                         error:NULL];
        
        if (fetchedObjects.count > 0) {
            
            result = fetchedObjects[0];
        }
    }];
    
    return result;
}

-(SearchEventEntity *) createSearchEventsWithTitle:(NSString *)title AndTypeSearch:(HPTypeSearchEvent)typeSearch {
    
    __block SearchEventEntity *result = nil;
    
    [self.managedObjectContext performBlockAndWait:^{
        
        NSManagedObjectContext *context = _managedObjectContext;
        
        SearchEventEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:SearchEventEntityName
                                                            inManagedObjectContext:context];
        
        entity.uuid = [[NSUUID UUID] UUIDString];
        entity.title = title;
        entity.typeSearch = [NSNumber numberWithInteger:typeSearch];
        
        result = entity;
    }];

    [self save];
    
    return result;
}


-(NSArray *) getListSearchEventsForArtist:(BOOL)onlyWithEvents {
        
    __block NSMutableArray *tmpResult = [[NSMutableArray alloc] init];
    
    [self.managedObjectContext performBlockAndWait:^{
        
        NSManagedObjectContext *context = _managedObjectContext;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity =[NSEntityDescription entityForName:SearchEventEntityName
                                                 inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"typeSearch == %d && count >= %d", HPTypeSearchEventByArtist, (onlyWithEvents ? 1 : 0)];
        
        [fetchRequest setPredicate:predicate];
        
        NSSortDescriptor *sortByTitle = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortByTitle]];
        
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:NULL];
        [tmpResult addObjectsFromArray:fetchedObjects];
    }];
    
    return [NSArray arrayWithArray:tmpResult];
}

-(NSArray *) getListSearchEventsForLocation {
    
    __block NSMutableArray *tmpResult = [[NSMutableArray alloc] init];
    
    [self.managedObjectContext performBlockAndWait:^{
        
        NSManagedObjectContext *context = _managedObjectContext;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity =[NSEntityDescription entityForName:SearchEventEntityName
                                                 inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"typeSearch == %d OR typeSearch == %d", HPTypeSearchEventByLocation, HPTypeSearchEventByLocationLimitArtistsLibrary];
        [fetchRequest setPredicate:predicate];
        
        NSSortDescriptor *sortByTitle = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortByTitle]];
        
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:NULL];
        [tmpResult addObjectsFromArray:fetchedObjects];
    }];
    
    return [NSArray arrayWithArray:tmpResult];
}

#pragma mark - Fetches

-(NSFetchRequest *) createFetchRequestEventsAfterDate:(NSDate *) date {
    
    return [self createFetchRequestEventsAfterDate:date
                                         InContext:self.managedObjectContext];
}

-(NSFetchRequest *) createFetchRequestEventsAfterDate:(NSDate *) date
                                      flagOnlyNotRead:(BOOL)flagOnlyNotRead {
    
    return [self createFetchRequestEventsAfterDate:date
                                         ForSearch:nil
                                     MaxKilometers:0
                                   flagOnlyNotRead:flagOnlyNotRead];
}

-(NSFetchRequest *) createFetchRequestEventsAfterDate:(NSDate *) date
                                            ForArtist:(NSString *) artist {

    return [self createFetchRequestEventsAfterDate:date
                                         ForArtist:artist
                                         InContext:self.managedObjectContext];
}

-(NSFetchRequest *) createFetchRequestEventsAfterDate:(NSDate *) date
                                            ForSearch:(NSString *) search {

    return [self createFetchRequestEventsAfterDate:date
                                         ForSearch:search
                                         InContext:self.managedObjectContext];
}

-(NSFetchRequest *) createFetchRequestEventsAfterDate:(NSDate *) date
                                            ForSearch:(NSString *) search
                                        MaxKilometers:(NSInteger) maxKilometers {
    
    return [self createFetchRequestEventsAfterDate:date
                                         ForSearch:search
                                     MaxKilometers:maxKilometers
                                         InContext:self.managedObjectContext];
}

-(NSFetchRequest *) createFetchRequestEventsAfterDate:(NSDate *) date
                                            ForSearch:(NSString *) search
                                        MaxKilometers:(NSInteger) maxKilometers
                                      flagOnlyNotRead:(BOOL)flagOnlyNotRead {
    
    return [self createFetchRequestEventsAfterDate:date
                                         ForSearch:search
                                     MaxKilometers:maxKilometers
                                   flagOnlyNotRead:flagOnlyNotRead
                                         InContext:self.managedObjectContext];
}

-(NSFetchRequest *) createFetchRequestEventsAfterDate:(NSDate *) date
                                            InContext:(NSManagedObjectContext *) context {

    return [self createFetchRequestEventsAfterDate:date
                                         ForArtist:nil
                                         InContext:context];
}

-(NSFetchRequest *) createFetchRequestEventsAfterDate:(NSDate *) date
                                            ForArtist:(NSString *) artist
                                            InContext:(NSManagedObjectContext *) context {

    NSLog(@"%@.createFetchRequestEventsAfterDate:%@ ForArtist:%@ ...", self.class, date, artist);
    
    __block NSFetchRequest *fetchRequest = nil;

    [context performBlockAndWait:^{

        fetchRequest = [[NSFetchRequest alloc] init];

        NSEntityDescription *entity =[NSEntityDescription entityForName:EventEntityName
                                                 inManagedObjectContext:context];

        [fetchRequest setEntity:entity];

        NSMutableArray *predicates = [NSMutableArray array];

        if (date) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"dateStart > %@", date]];
        }

        if (artist.length>0) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"artists CONTAINS[cd] %@", artist]];
        }

        if (predicates.count>0) {
            NSPredicate *predicatesCompound = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
            NSLog(@"Predicates=%@", predicatesCompound);
            [fetchRequest setPredicate:predicatesCompound];
        }
    
        NSSortDescriptor *sortByStartDate = [[NSSortDescriptor alloc] initWithKey:@"dateStart" ascending:YES];
        NSSortDescriptor *sortByTitle = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    
        [fetchRequest setSortDescriptors:@[sortByStartDate, sortByTitle]];
 
        [fetchRequest setFetchBatchSize:20];
    }];
    
    return fetchRequest;
}

-(NSFetchRequest *) createFetchRequestEventsAfterDate:(NSDate *) date
                                            ForSearch:(NSString *) search
                                            InContext:(NSManagedObjectContext *) context {
    
    return [self createFetchRequestEventsAfterDate:date
                                         ForSearch:search
                                     MaxKilometers:0
                                         InContext:context];
}


-(NSFetchRequest *) createFetchRequestEventsAfterDate:(NSDate *) date
                                            ForSearch:(NSString *) search
                                        MaxKilometers:(NSInteger) maxKilometers
                                            InContext:(NSManagedObjectContext *) context {

    return [self createFetchRequestEventsAfterDate:date
                                         ForSearch:search
                                     MaxKilometers:maxKilometers
                                   flagOnlyNotRead:NO
                                         InContext:context];
}

-(NSFetchRequest *) createFetchRequestEventsAfterDate:(NSDate *) date
                                            ForSearch:(NSString *) search
                                        MaxKilometers:(NSInteger) maxKilometers
                                      flagOnlyNotRead:(BOOL) flagOnlyNotRead
                                            InContext:(NSManagedObjectContext *) context {
    
    __block NSFetchRequest *fetchRequest = nil;
    
    [context performBlockAndWait:^{

        NSLog(@"%@.createFetchRequestEventsAfterDate:%@ ForSearch:%@ MaxKilometers:%d ...", self.class, date, search, maxKilometers);
    
        fetchRequest = [[NSFetchRequest alloc] init];
    
        NSEntityDescription *entity = [NSEntityDescription entityForName:EventEntityName
                                                  inManagedObjectContext:context];
    
        [fetchRequest setEntity:entity];
    
        NSMutableArray *predicates = [NSMutableArray array];
    
        if (date) {
        
            [predicates addObject:[NSPredicate predicateWithFormat:@"dateStart > %@", date]];
        }
        
        if (flagOnlyNotRead) {
            
            [predicates addObject:[NSPredicate predicateWithFormat:@"statusRead != %d", EventStatusRead]];
        }
    
        if (search.length>0) {
        
            NSPredicate *searchArtists = [NSPredicate predicateWithFormat:@"artists CONTAINS[cd] %@", search];
            NSPredicate *searchTitle = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", search];
            NSPredicate *searchCity = [NSPredicate predicateWithFormat:@"city CONTAINS[cd] %@", search];
            //        NSPredicate *searchLocation = [NSPredicate predicateWithFormat:@"location CONTAINS[cd] %@", search];
            NSPredicate *searchTags = [NSPredicate predicateWithFormat:@"tags CONTAINS[cd] %@", search];
        
            NSArray *arraySearch = @[searchArtists, searchTitle, searchCity, /*searchLocation,*/ searchTags];
            NSPredicate *predicatesSearch = [NSCompoundPredicate orPredicateWithSubpredicates:arraySearch];
            [predicates addObject:predicatesSearch];
        }
    
        if (maxKilometers > 0) {
        
            [predicates addObject:[NSPredicate predicateWithFormat:@"(distance!=nil && distance!=0 && distance <= %d)", maxKilometers * 1000]];
        }
    
        if (predicates.count>0) {
        
            NSPredicate *predicatesCompound = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
            NSLog(@"Predicates=%@", predicatesCompound);
            [fetchRequest setPredicate:predicatesCompound];
        }
    
        NSSortDescriptor *sortByStartDate = [[NSSortDescriptor alloc] initWithKey:@"dateStart" ascending:YES];
        NSSortDescriptor *sortByTitle = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortByStartDate, sortByTitle]];
    
        [fetchRequest setFetchBatchSize:20];
    }];
    
    return fetchRequest;
}

#pragma mark - Location (update distance)

-(void) updateDistanceEventWithLocation:(CLLocation *)location
                             Completion:(void (^)(BOOL success, NSError *error))completion {
    
    [self.managedObjectContext performBlock:^{

        NSManagedObjectContext *context = _managedObjectContext;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity =[NSEntityDescription entityForName:EventEntityName
                                                 inManagedObjectContext:context];
        
        [fetchRequest setEntity:entity];

        NSError *error;
        
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

        if (!error) {
        
            [fetchedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                EventEntity *event = obj;
                [event updateDistanceWithMe:location];
            }];
        
            // Save
            [self save];
        }
        
        // Completion
        if (completion) {
            BOOL success = (error == nil);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success, error);
            });
        }
    }];
}

#pragma mark - Save

-(void) save {
    
    [self.managedObjectContext performBlockAndWait:^{

        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%@.Unresolved error %@, %@", self.class, error, [error userInfo]);
            abort();
        }
        
        [self.writerManagedObjectContext performBlock:^{
            
            NSError *error = nil;
            if (![self.writerManagedObjectContext save:&error]) {
                NSLog(@"%@.Unresolved error %@, %@", self.class, error, [error userInfo]);
                abort();
            }
        }];
    }];
    
}

-(void) deleteObject:(NSManagedObject *) object {
    
    [self.managedObjectContext performBlockAndWait:^{
        
        NSManagedObjectContext *context = _managedObjectContext;
        [context deleteObject:object];
        [self save];
    }];
}


#pragma mark - Core Data stack 

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.parentContext = self.writerManagedObjectContext;
    
    [_managedObjectContext setStalenessInterval:kStalenessInterval];
    
    return _managedObjectContext;
}


-(NSManagedObjectContext *) writerManagedObjectContext {
    
    if (_writerManagedObjectContext != nil) {
        return _writerManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;

    if (coordinator != nil) {
        
        _writerManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _writerManagedObjectContext.persistentStoreCoordinator = coordinator;
        
        [_writerManagedObjectContext setStalenessInterval:kStalenessInterval];
    }
    
    return _writerManagedObjectContext;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSError *error;
    
    NSURL *storeURL = [self.documentsURL URLByAppendingPathComponent:@"Everzik_V2.sqlite"];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error]) {
        
        NSLog(@"%@.Unresolved error %@, %@", self.class, error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
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
    
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}


@end
