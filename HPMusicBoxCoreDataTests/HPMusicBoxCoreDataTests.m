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
    
    ArtistEntity *entity = [coredata findOrCreateArtistWithName:name error:&error];
    
    NSLog(@"entity.cleanName=%@ dateUpdate=%@ error=%@", entity.cleanName, entity.dateUpdate, [error localizedDescription]);
    
    XCTAssertNotNil(entity, @"%@ Not exist and not created ???", name);
    XCTAssertEqualObjects(entity.cleanName, cleanName, @"Bad value in cleanName field");
    XCTAssertNil(error, @"error: %@", [error localizedDescription]);
}

- (void)testSimulError
{
    NSString *name = @" The Strokes ";
    NSString *cleanName = @"strokes";
    
    coredata.simulError = YES;
    
    NSError *error = nil;

    ArtistEntity *entity = [coredata findOrCreateArtistWithName:name error:&error];
    
    NSLog(@"entity.cleanName=%@ dateUpdate=%@ error=%@", entity.cleanName, entity.dateUpdate, [error localizedDescription]);
    
    XCTAssertNotNil(entity, @"%@ Not exist and not created ???", name);
    XCTAssertEqualObjects(entity.cleanName, cleanName, @"Bad value in cleanName field");
    XCTAssertNotNil(error, @"pas eu d'erreur dans testSimulError ???");
}


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
