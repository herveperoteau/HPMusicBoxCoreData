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

#define ArtistEntityName @"ArtistEntity"
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

@implementation HPMusicBoxCoreData

+(void) setBaseDocumentsURL:(NSURL *) docUrl {
    
    NSAssert(sharedMyManager == nil, @"setBaseDocumentsURL has no effect after call sharedManager method !!!");
    
    documentsURL = [docUrl copy];
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

+(NSURL *) defaultStorageURL {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Facade CoreData

-(ArtistEntity *) findOrCreateArtistWithName:(NSString *) fullName error:(NSError **) error{
    
    ArtistEntity *entity = nil;
    
    entity = [self findArtistWithName:fullName error:error];
    if (error && *error != nil) {
        return nil;
    }

    if (!entity) {
        
        entity = [self createArtistWithName:fullName error:error];
        if (error && *error != nil) {
            return nil;
        }
    }

    return entity;
}

-(ArtistEntity *) createArtistWithName:(NSString *) fullName error:(NSError **) error {
    
    NSString *cleanName = [HPMusicHelper cleanArtistName:fullName];

    NSManagedObjectContext *context = [self managedObjectContext:error];
    if (error && *error != nil) {
        return nil;
    }

    ArtistEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:ArtistEntityName
                                                         inManagedObjectContext:context];
    
    entity.cleanName = cleanName;
    entity.dateUpdate = [NSDate date];
    
    [context save:error];
    
    return entity;
}

-(ArtistEntity *) findArtistWithName:(NSString *) fullName error:(NSError **) error {
    
    NSString *cleanName = [HPMusicHelper cleanArtistName:fullName];
    
    NSManagedObjectContext *context = [self managedObjectContext:error];
    if (error && *error != nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:ArtistEntityName
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cleanName == %@", cleanName];
    
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest
                                                     error:error];
    
    if (error && *error != nil) {
        return nil;
    }
    
    if (fetchedObjects.count > 0) {
        
        ArtistEntity *result = fetchedObjects[0];
        return result;
    }
    
    return nil;
}

#pragma mark - API PlayLists with criterias

-(NSArray *) getSmartPlaylists:(NSError **) error {

    NSMutableArray *tmpResult = [[NSMutableArray alloc] init];

    NSManagedObjectContext *context = [self managedObjectContext:error];

    if (error== NULL || *error == nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity =[NSEntityDescription entityForName:SmartPlaylistEntityName
                                                 inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sort = [[NSSortDescriptor alloc]  initWithKey:@"title" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:error];

        if (error== NULL || *error == nil) {
            
            [tmpResult addObjectsFromArray:fetchedObjects];
        }
    }
    
    return [NSArray arrayWithArray:tmpResult];
}

-(SmartPlaylistEntity *) createSmartPlaylist:(NSString *) title error:(NSError **) error {
    
    NSString *uuid = [[NSUUID UUID] UUIDString];

    SmartPlaylistEntity *exist = [self findSmartPLaylistWithUUID:uuid error:error];
    if (error && *error != nil) {
        return nil;
    }
    
    if (exist != nil) {
        
        NSString *msgErr = [NSString stringWithFormat:@"UUID %@ already used by %@", uuid, exist.title];
        NSDictionary *infos = [NSDictionary dictionaryWithObject:msgErr  forKey:NSLocalizedDescriptionKey];
        NSError *err = [NSError errorWithDomain:ErrorDomain code:ERROR_ALREADY_EXIST userInfo:infos];
        
        if (error != NULL)
            *error = err;

        return nil;
    }

    SmartPlaylistEntity *result = [self createNewSmartPlaylist:title uuid:uuid error:error];

    return result;
}

-(SmartPlaylistEntity *) findSmartPLaylistWithUUID:(NSString *) uuid error:(NSError **) error {
    
    NSManagedObjectContext *context = [self managedObjectContext:error];
    if (error && *error != nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:SmartPlaylistEntityName
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];
    
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest
                                                     error:error];
    
    if (error && *error != nil) {

        return nil;
    }
    
    if (fetchedObjects.count > 0) {
        
        SmartPlaylistEntity *result = fetchedObjects[0];
        return result;
    }
    
    return nil;
}


-(SmartPlaylistEntity *) createNewSmartPlaylist:(NSString *) title uuid:(NSString *)uuid error:(NSError **) error {
    
    NSManagedObjectContext *context = [self managedObjectContext:error];
    if (error && *error != nil) {
        return nil;
    }
    
    SmartPlaylistEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:SmartPlaylistEntityName
                                                                inManagedObjectContext:context];
    
    entity.title = title;
    entity.uuid = uuid;
    entity.dateCreate = [NSDate date];
    
    [context save:error];
    
    return entity;
}

-(CriteriaPLEntity *) createCriteria:(NSError **) error {
    
    NSManagedObjectContext *context = [self managedObjectContext:error];
    if (error && *error != nil) {
        return nil;
    }
    
    CriteriaPLEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:CriteriaPLEntityName
                                                             inManagedObjectContext:context];
    
    [context save:error];
    
    return entity;
}


#pragma mark - Delete, Save

-(BOOL) save:(NSError **) error {
    
    NSManagedObjectContext *context = [self managedObjectContext:error];
    
    return [context save:error];
}

-(void) deleteObject:(NSManagedObject *) object error:(NSError **) error {
    
    NSManagedObjectContext *context = [self managedObjectContext:error];
    if (error && *error != nil) {
        return;
    }
    
    [context deleteObject:object];
    [context save:error];
}


#pragma mark - Core Data stack

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
    
    NSURL *storeURL = [self.documentsURL URLByAppendingPathComponent:@"MusicBox.sqlite"];
    
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
