//
//  HPMusicBoxCoreData_Private.h
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 23/07/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import "HPMusicBoxCoreData.h"

@interface HPMusicBoxCoreData ()

// Mis ici pour pouvoir etre initialiser aussi directement pendant les TestUnit (sans creation de fichier sqlite)
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (assign, nonatomic) BOOL simulError;

@end
