//
//  SmartPlaylistEntity.h
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 06/08/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PLBaseEntity.h"

@class CriteriaPLEntity;

@interface SmartPlaylistEntity : PLBaseEntity

@property (nonatomic, retain) NSNumber * flagCriteriasAND;
@property (nonatomic, retain) NSOrderedSet *criterias;
@end

@interface SmartPlaylistEntity (CoreDataGeneratedAccessors)

- (void)insertObject:(CriteriaPLEntity *)value inCriteriasAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCriteriasAtIndex:(NSUInteger)idx;
- (void)insertCriterias:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCriteriasAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCriteriasAtIndex:(NSUInteger)idx withObject:(CriteriaPLEntity *)value;
- (void)replaceCriteriasAtIndexes:(NSIndexSet *)indexes withCriterias:(NSArray *)values;
- (void)addCriteriasObject:(CriteriaPLEntity *)value;
- (void)removeCriteriasObject:(CriteriaPLEntity *)value;
- (void)addCriterias:(NSOrderedSet *)values;
- (void)removeCriterias:(NSOrderedSet *)values;
@end
