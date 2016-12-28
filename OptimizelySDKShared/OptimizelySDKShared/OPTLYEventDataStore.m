/****************************************************************************
 * Copyright 2016, Optimizely, Inc. and contributors                        *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *    http://www.apache.org/licenses/LICENSE-2.0                            *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 ***************************************************************************/
#import <OptimizelySDKCore/OPTLYErrorHandler.h>
#import "OPTLYDataStore.h"
#import "OPTLYEventDataStore.h"

#if TARGET_OS_IOS
// SQLite tables are only available for iOS
#import "OPTLYDatabase.h"
#import "OPTLYDatabaseEntity.h"

@interface OPTLYEventDataStoreiOS()
@property (nonatomic, strong) OPTLYDatabase *database;
@property (nonatomic, strong) NSString *databaseDirectory;
@end

@implementation OPTLYEventDataStoreiOS

- (nullable instancetype)initWithBaseDir:(nonnull NSString *)baseDir
                                   error:(NSError * _Nullable * _Nullable)error
{
    self = [super init];
    if (self)
    {
        _databaseDirectory = [baseDir stringByAppendingPathComponent:[OPTLYDataStore stringForDataTypeEnum:OPTLYDataStoreDataTypeDatabase]];
        _database = [[OPTLYDatabase alloc] initWithBaseDir:_databaseDirectory];
        
        // create the events table
        NSError *error = nil;
        [self createTable:[OPTLYDataStore stringForDataEventEnum:OPTLYDataStoreEventTypeImpression] error:&error];
        [self createTable:[OPTLYDataStore stringForDataEventEnum:OPTLYDataStoreEventTypeConversion] error:&error];
    }
    return self;
}

- (void)createTable:(NSString *)eventTypeName
              error:(NSError * _Nullable * _Nullable)error
{
    [self.database createTable:eventTypeName error:error];
}

- (void)saveEvent:(nonnull NSDictionary *)data
        eventType:(nonnull NSString *)eventTypeName
            error:(NSError * _Nullable * _Nullable)error
{
     [self.database saveEvent:data table:eventTypeName error:error];
}

- (nullable NSArray *)getFirstNEvents:(NSInteger)numberOfEvents
                            eventType:(nonnull NSString *)eventTypeName
                                error:(NSError * _Nullable * _Nullable)error
{
    NSMutableArray *firstNEvents = [NSMutableArray new];
    
    NSArray *firstNEntities = [self.database retrieveFirstNEntries:numberOfEvents table:eventTypeName error:error];
    for (OPTLYDatabaseEntity *entity in firstNEntities) {
        NSString *entityValue = entity.entityValue;
        NSDictionary *event = [NSJSONSerialization JSONObjectWithData:[entityValue dataUsingEncoding:NSUTF8StringEncoding] options:0 error:error];
        [firstNEvents addObject:event];
    }
    
    return [firstNEvents copy];
}

- (void)removeFirstNEvents:(NSInteger)numberOfEvents
                 eventType:(nonnull NSString *)eventTypeName
                     error:(NSError * _Nullable * _Nullable)error
{
    NSArray *firstNEvents = [self.database retrieveFirstNEntries:numberOfEvents table:eventTypeName error:error];
    if ([firstNEvents count] <= 0) {
        if (error) {
            *error =  [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                          code:OPTLYErrorTypesDataStore
                                      userInfo:@{NSLocalizedDescriptionKey :
                                                     [NSString stringWithFormat:NSLocalizedString(OPTLYErrorHandlerMessagesDataStoreDatabaseNoSavedEvents, nil), eventTypeName]}];
        }
        return;
    }
    
    NSMutableArray *entityIds = [NSMutableArray new];
    for (OPTLYDatabaseEntity *entity in firstNEvents) {
        NSString *entityId = [entity.entityId stringValue];
        [entityIds addObject:entityId];
    }
    [self.database deleteEntities:entityIds table:eventTypeName error:error];
}

- (void)removeEvent:(nonnull NSDictionary *)event
          eventType:(nonnull NSString *)eventTypeName
              error:(NSError * _Nullable * _Nullable)error
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:event options:NSJSONWritingPrettyPrinted error:error];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self.database deleteEntityWithJSON:json table:eventTypeName error:error];
}

- (NSInteger)numberOfEvents:(NSString *)eventTypeName
                      error:(NSError * _Nullable * _Nullable)error
{
    NSInteger numberOfEvents = [self.database numberOfRows:eventTypeName error:error];
    return numberOfEvents;
}

- (void)removeDataStore:(NSError * _Nullable * _Nullable)error
{
    [self.database deleteDatabase:error];
    self.database = nil;
}

- (void)dealloc
{
    [self removeDataStore:nil];
}
@end
#endif

#if TARGET_OS_TV
#import <OptimizelySDKCore/OPTLYQueue.h>

@interface OPTLYEventDataStoreTVOS()
@property (nonatomic, strong) NSCache *eventsCache;
@end

@implementation OPTLYEventDataStoreTVOS

- (nullable instancetype)initWithBaseDir:(nonnull NSString *)baseDir
                                   error:(NSError * _Nullable * _Nullable)error
{
    self = [super init];
    if (self)
    {
        _eventsCache = [NSCache new];
        [_eventsCache setObject:[OPTLYQueue new] forKey:[OPTLYDataStore stringForDataEventEnum:OPTLYDataStoreEventTypeImpression]];
        [_eventsCache setObject:[OPTLYQueue new] forKey:[OPTLYDataStore stringForDataEventEnum:OPTLYDataStoreEventTypeConversion]];
    }
    return self;
}

- (void)saveEvent:(nonnull NSDictionary *)data
        eventType:(nonnull NSString *)eventTypeName
            error:(NSError * _Nullable * _Nullable)error
{
    OPTLYQueue *queue = [self.eventsCache objectForKey:eventTypeName];
    [queue enqueue:data];
}

- (nullable NSArray *)getFirstNEvents:(NSInteger)numberOfEvents
                            eventType:(nonnull NSString *)eventTypeName
                                error:(NSError * _Nullable * _Nullable)error
{
    OPTLYQueue *queue = [self.eventsCache objectForKey:eventTypeName];
    NSArray *firstNEvents = [queue firstNItems:numberOfEvents];
    return firstNEvents;
}

- (void)removeFirstNEvents:(NSInteger)numberOfEvents
                 eventType:(nonnull NSString *)eventTypeName
                     error:(NSError * _Nullable * _Nullable)error
{
    OPTLYQueue *queue = [self.eventsCache objectForKey:eventTypeName];
    [queue dequeueNItems:numberOfEvents];
}

- (void)removeEvent:(nonnull NSDictionary *)event
          eventType:(nonnull NSString *)eventTypeName
              error:(NSError * _Nullable * _Nullable)error
{
    OPTLYQueue *queue = [self.eventsCache objectForKey:eventTypeName];
    [queue removeItem:event];
}

- (NSInteger)numberOfEvents:(nonnull NSString *)eventTypeName
                      error:(NSError * _Nullable * _Nullable)error
{
    OPTLYQueue *queue = [self.eventsCache objectForKey:eventTypeName];
    return [queue size];
}

- (void)removeDataStore:(NSError * _Nullable * _Nullable)error
{
    self.eventsCache = nil;
}
    
- (void)dealloc
{
    [self removeDataStore:nil];
}
@end
#endif
