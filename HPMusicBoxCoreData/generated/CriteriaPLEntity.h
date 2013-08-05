//
//  CriteriaPLEntity.h
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 05/08/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SmartPlaylistEntity;

@interface CriteriaPLEntity : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * condition;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) SmartPlaylistEntity *playlist;

@end
