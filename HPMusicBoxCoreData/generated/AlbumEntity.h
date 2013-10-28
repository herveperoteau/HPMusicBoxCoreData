//
//  AlbumEntity.h
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 28/10/2013.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AlbumEntity : NSManagedObject

@property (nonatomic, retain) NSString * albumId;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * artistCleanName;
@property (nonatomic, retain) NSDate * dateLastCalcul;
@property (nonatomic, retain) NSDate * dateLastShare;
@property (nonatomic, retain) NSNumber * indiceLastShare;
@property (nonatomic, retain) NSNumber * indiceSatisfaction;
@property (nonatomic, retain) NSString * styles;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSNumber * rank;

@end
