//
//  PLBaseEntity.h
//  HPMusicBoxCoreData
//
//  Created by Hervé PEROTEAU on 05/08/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PLBaseEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSDate * dateLastCount;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * dateCreate;

@end
