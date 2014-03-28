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

@implementation HPMusicBoxCoreData {
    
    NSOperationQueue *queue;
}

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

-(id) init {
    
    if ((self = [super init])) {
        
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;   // Thread confinement
    }
    
    return self;
}

-(void) setup {
    
    if (_managedObjectContext == nil) {
    
        [queue addOperationWithBlock:^{
            
            [self managedObjectContext:NULL];
        }];
    }
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
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");

    __block ArtistEntity *result = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [queue addOperationWithBlock:^{
        
        NSString *cleanName = [self cleanNameArtist:fullName];

        NSManagedObjectContext *context = _managedObjectContext;

        ArtistEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:ArtistEntityName
                                                             inManagedObjectContext:context];
    
        entity.cleanName = cleanName;
        entity.dateUpdate = [NSDate date];
        
        result = entity;
    
        [context save:NULL];
        
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    return result;
}

-(NSString *) cleanNameArtist:(NSString *)artist {
    
    NSString *cleanName = [HPMusicHelper cleanArtistName:artist PreserveAccent:NO PreservePrefix:NO];
    return cleanName;
}

-(ArtistEntity *) findArtistWithName:(NSString *) fullName {
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");
    
    __block ArtistEntity *result = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [queue addOperationWithBlock:^{
        
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
        
        dispatch_semaphore_signal(semaphore);

    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    return result;
}

#pragma mark - API PlayLists with criterias

-(NSArray *) getSmartPlaylists {

    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSMutableArray *tmpResult = [[NSMutableArray alloc] init];
    
    [queue addOperationWithBlock:^{

        NSManagedObjectContext *context = _managedObjectContext;

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity =[NSEntityDescription entityForName:SmartPlaylistEntityName
                                                 inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortByTitle = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        
        [fetchRequest setSortDescriptors:@[sortByTitle]];
        
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:NULL];
        
        [tmpResult addObjectsFromArray:fetchedObjects];

        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    return [NSArray arrayWithArray:tmpResult];
}

-(SmartPlaylistEntity *) createSmartPlaylist:(NSString *) title {
    
    NSString *uuid = [[NSUUID UUID] UUIDString];

    SmartPlaylistEntity *result = [self createNewSmartPlaylist:title uuid:uuid];

    return result;
}

-(SmartPlaylistEntity *) findSmartPLaylistWithUUID:(NSString *) uuid {
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");

    __block SmartPlaylistEntity *result = nil;

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [queue addOperationWithBlock:^{
    
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
    
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return result;
}


-(SmartPlaylistEntity *) createNewSmartPlaylist:(NSString *) title uuid:(NSString *)uuid {
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");
    
    __block SmartPlaylistEntity *result = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [queue addOperationWithBlock:^{
        
        NSManagedObjectContext *context = _managedObjectContext;
    
        SmartPlaylistEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:SmartPlaylistEntityName
                                                                    inManagedObjectContext:context];
    
        entity.title = title;
        entity.uuid = uuid;
        entity.dateCreate = [NSDate date];
        
        result = entity;
    
        [context save:NULL];
    
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    return result;
}

-(CriteriaPLEntity *) createCriteria {
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");
    
    __block CriteriaPLEntity *result = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [queue addOperationWithBlock:^{
        
        NSManagedObjectContext *context = _managedObjectContext;
        
        CriteriaPLEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:CriteriaPLEntityName
                                                                 inManagedObjectContext:context];
    
        result = entity;
        
        [context save:NULL];
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return result;
}


#pragma mark - Album : indice satisfaction

// return Array of AlbumEntity
-(NSArray *) getAlbumsEntities {
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");
    
    __block NSMutableArray *tmpResult = [[NSMutableArray alloc] init];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [queue addOperationWithBlock:^{
        
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
    
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    return [NSArray arrayWithArray:tmpResult];
}

-(AlbumEntity *) findOrCreateAlbumEntity:(NSString *)keyAlbum {
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");
    
    __block AlbumEntity *result = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [queue addOperationWithBlock:^{

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
        
            [context save:NULL];
        }
        else {
        
            result = fetchedObjects[0];
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return result;
}

#pragma mark - Events

-(EventEntity *) findEventByEventID:(NSString *)eventId {
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");
    
    __block EventEntity *result = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [queue addOperationWithBlock:^{
        
        result = [self findEventByEventID:eventId inContext:_managedObjectContext];
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return result;
}

-(EventEntity *) findEventByEventID:(NSString *)eventId inContext:(NSManagedObjectContext *)context {
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");
    NSAssert(context!=nil, @"context is nil !");
    
    EventEntity *result = nil;
    
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
    
    return result;
}



-(EventEntity *) createEventWithEventID:(NSString *)eventId {
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");
    
    __block EventEntity *result = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [queue addOperationWithBlock:^{
        
        result = [self createEventWithEventID:eventId inContext:_managedObjectContext];

        [_managedObjectContext save:NULL];
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return result;
}

-(EventEntity *) createEventWithEventID:(NSString *)eventId inContext:(NSManagedObjectContext *)context {
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");
    NSAssert(context!=nil, @"context is nil !");

    EventEntity *result = nil;
    
    EventEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:EventEntityName
                                                        inManagedObjectContext:context];
        
    entity.eventId = eventId;
        
    result = entity;
        
    return result;
}


-(SearchEventEntity *) findSearchEventsByUUID:(NSString *)uuid {
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");
    
    __block SearchEventEntity *result = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [queue addOperationWithBlock:^{
        
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
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return result;
}

-(SearchEventEntity *) createSearchEventsWithTitle:(NSString *)title AndTypeSearch:(HPTypeSearchEvent)typeSearch {
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");
    
    __block SearchEventEntity *result = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [queue addOperationWithBlock:^{
        
        NSManagedObjectContext *context = _managedObjectContext;
        
        SearchEventEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:SearchEventEntityName
                                                            inManagedObjectContext:context];
        
        entity.uuid = [[NSUUID UUID] UUIDString];
        entity.title = title;
        entity.typeSearch = [NSNumber numberWithInteger:typeSearch];
        
        result = entity;
        
        [context save:NULL];
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return result;
}


-(NSArray *) getListSearchEventsForArtist:(BOOL)onlyWithEvents {
        
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");
    
    __block NSMutableArray *tmpResult = [[NSMutableArray alloc] init];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [queue addOperationWithBlock:^{
        
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
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return [NSArray arrayWithArray:tmpResult];
}

-(NSArray *) getListSearchEventsForLocation {
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");
    
    __block NSMutableArray *tmpResult = [[NSMutableArray alloc] init];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [queue addOperationWithBlock:^{
        
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
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return [NSArray arrayWithArray:tmpResult];
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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

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
    
    NSLog(@"%@.createFetchRequestEventsAfterDate:%@ ForSearch:%@ MaxKilometers:%d ...", self.class, date, search, maxKilometers);
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =[NSEntityDescription entityForName:EventEntityName
                                             inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    NSMutableArray *predicates = [NSMutableArray array];
    
    if (date) {
        
        [predicates addObject:[NSPredicate predicateWithFormat:@"dateStart > %@", date]];
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
        
        [predicates addObject:[NSPredicate predicateWithFormat:@"(distance!=nil && distance <= %d)", maxKilometers * 1000]];
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
    
    return fetchRequest;
}


-(void) updateDistanceEventWithLocation:(CLLocation *)location
                             Completion:(void (^)(BOOL success, NSError *error))completion {
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");

    [queue addOperationWithBlock:^{
        
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
            [context save:&error];
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

#pragma mark - Delete, Save

-(void) addSyncOperationWithBlock:(void (^)(void))block {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self addOperationWithBlock:block
                     Completion:^{
                         dispatch_semaphore_signal(semaphore);
                     }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)addOperationWithBlock:(void (^)(void))block Completion:(void (^)(void))completion {
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:block];

    if (completion) {
        [operation setCompletionBlock:completion];
    }
    
    [queue addOperation:operation];
}

-(BOOL) save {
    
    if (_managedObjectContext == nil) {
        return NO;
    }
    
    __block BOOL result = NO;
    __block NSManagedObjectContext *context = _managedObjectContext;

    [self addSyncOperationWithBlock:^{
        
        result = [context save:NULL];
    }];

    return result;
}

-(void) deleteObject:(NSManagedObject *) object {
    
    NSAssert(_managedObjectContext!=nil, @"_managedObjectContext is nil : call setup before !");
    
    __block NSManagedObjectContext *context = _managedObjectContext;
    
    [self addSyncOperationWithBlock:^{
        
        [context deleteObject:object];
        [context save:NULL];
    }];
}

#pragma mark - Core Data stack (without iCloud)

#ifndef WITH_ICLOUD

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext:(NSError **) error
{
    [self checkSimulError:error];
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator:error];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel:(NSError **) error
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

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator:(NSError **) error
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [self.documentsURL URLByAppendingPathComponent:@"Everzik_V2.sqlite"];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel:error]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:error]) {
        
        //FATAL_CORE_DATA_ERROR(error);
        
        return nil;
    }
    
    return _persistentStoreCoordinator;
}

#endif

#pragma mark - Core Data stack (with iCloud)

#ifdef WITH_ICLOUD

-(NSManagedObjectModel *) managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSLog(@"%@ : init managedObjectModel ...", self.class);
    
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSLog(@"%@ : init persistentStoreCoordinator ...", self.class);
    
    NSURL *storeUrl = [self.documentsURL URLByAppendingPathComponent:COREDATA_DBNAME];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSPersistentStoreCoordinator *psc = _persistentStoreCoordinator;
    
    // download preexisting iCloud content
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSURL *transactionLogsURL = [fileManager URLForUbiquityContainerIdentifier:nil];
        NSString *coreDataCloudContent = [[transactionLogsURL path] stringByAppendingPathComponent:ICLOUD_FOLDER_UPDATE];
        transactionLogsURL = [NSURL fileURLWithPath:coreDataCloudContent];
        
        NSLog(@"coreData: transactionLogsURL=%@", transactionLogsURL);
        
        // building options for coordinator
        
        NSDictionary *options = @{NSPersistentStoreUbiquitousContentNameKey:ICLOUD_CONTENT_NAME_KEY,
                                  NSPersistentStoreUbiquitousContentURLKey:transactionLogsURL,
                                  NSMigratePersistentStoresAutomaticallyOption:[NSNumber numberWithBool:YES]};
        
        // Add persistant Store
        
        [psc lock];
        
        NSError *error;
        
        if ( ![psc addPersistentStoreWithType:NSSQLiteStoreType
                                configuration:nil
                                          URL:storeUrl
                                      options:options
                                        error:&error]) {
            
            NSLog(@"CoreData Error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [psc unlock];
        
        // Post notif to refresh UI
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"Persistent store added correctly : post notif %@ to UI", NOTIFICATION_MUSICBOX_COREDATA_ICLOUD_REFRESH);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MUSICBOX_COREDATA_ICLOUD_REFRESH
                                                                object:self
                                                              userInfo:nil];
        });
    });
    
    return _persistentStoreCoordinator;
}

-(NSManagedObjectContext *) managedObjectContext:(NSError **) error {
    
    [self checkSimulError:error];

    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSLog(@"%@ : init managedObjectContext ...", self.class);
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator) {
        
        // concurrency type
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [moc performBlockAndWait:^{
            
            [moc setPersistentStoreCoordinator:coordinator];

            self.persistantStoreAvailable = YES;
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(mergeChangesFrom_iCloud:)
                                                         name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                                       object:coordinator];
            
        }];
        
        _managedObjectContext = moc;
    }
    
    return _managedObjectContext;
}

-(void) mergeChangesFrom_iCloud:(NSNotification *)notification {
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    [moc performBlock:^{
        
        [self mergeiCloudChanges:notification forContext:moc];
    }];
}

-(void) mergeiCloudChanges:(NSNotification *)notification forContext:(NSManagedObjectContext *)moc {
    
    [moc mergeChangesFromContextDidSaveNotification:notification];
    
    // Post notif to refresh UI
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"mergeiCloudChanges : post notif %@ to UI", NOTIFICATION_MUSICBOX_COREDATA_ICLOUD_REFRESH);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MUSICBOX_COREDATA_ICLOUD_REFRESH
                                                            object:self
                                                          userInfo:nil];
    });
}

#endif

#pragma mark - Core Data stack (simul error)

-(BOOL) checkSimulError:(NSError **) error {
    
    if (self.simulError) {
        
        NSString *errorMsg = @"Simulation error";
        
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:errorMsg forKey:NSLocalizedDescriptionKey];
        
        if (error != NULL)
            *error = [NSError errorWithDomain:@"coredata" code:500 userInfo:details];
        
        //FATAL_CORE_DATA_ERROR(error);
    }
    
    return self.simulError;
}


@end
