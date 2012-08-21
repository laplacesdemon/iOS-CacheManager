//
//  FAWebServiceCache.h
//  Forum Avm
//
//  Created by Suleyman Melikoglu on 8/21/12.
//  Copyright (c) 2012 suleymanmelikoglu@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FAWebServiceCacheManager <NSObject>

- (void)saveCacheData:(id)data forIdentifier:(NSString*)identifier;
- (id)fetchCacheDataForIdentifier:(NSString*)identifier;

@end

////////////////////////////////////
// FAWebServiceCache class        //
////////////////////////////////////

@interface FAWebServiceCache : NSObject

// set if you want to change the default time interval programmatically
+ (void)setTimeInterval:(NSTimeInterval)timeInterval;

// set cache manager if you want to change the default one
+ (void)setCacheManager:(id<FAWebServiceCacheManager>)cacheManager;

+ (id<FAWebServiceCacheManager>)cacheManager;

// returns the available cache for the service
+ (id)cachedDataForServiceIdentifier:(NSString*)identifier;

// saves the cache with the identifier
+ (void)saveCacheWithIdentifier:(NSString*)identifier data:(id)data;

@end

////////////////////////////////////
// FAWebServiceTimeout class      //
////////////////////////////////////

// makes sure that the use of service is available until the timeout
@interface FAWebServiceTimeout : NSObject

// returns YES if the time is out (i.e. needs to delete the cache)
// returns NO if the cache control should happen
+ (BOOL)isTimeOutFromCacheDate:(NSDate*)cacheDate;

// returns YES if the cache time out
// returns NO if the cache control should happen
+ (BOOL)isTimeOutForServiceIdentifier:(NSString*)identifier;

@end

////////////////////////////////////
// FAWebServiceKeyGenerator class //
////////////////////////////////////

@interface FAWebServiceKeyGenerator
+ (NSString*)lastUsageKeyForIdentifier:(NSString*)identifier;
@end

////////////////////////////////////
// FAWebServiceKeyGenerator class //
////////////////////////////////////

@interface FAWebServiceCacheManagerDefault : NSObject <FAWebServiceCacheManager>

@end
