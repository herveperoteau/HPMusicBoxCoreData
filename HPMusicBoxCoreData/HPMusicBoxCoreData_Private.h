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

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *writerManagedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

@end
