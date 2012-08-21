//
//  FAWebServiceCache.m
//
//  Created by Suleyman Melikoglu on 8/21/12.
//  Copyright (c) 2012 suleymanmelikoglu@gmail.com. All rights reserved.
//

#import "FAWebServiceCache.h"

////////////////////////////////////
// FAWebServiceCache class        //
////////////////////////////////////

@implementation FAWebServiceCache

// default time interval is 1 day
static NSTimeInterval timeInterval = 60*60*24;

static id<FAWebServiceCacheManager> cacheManager = nil;

+ (void)setTimeInterval:(NSTimeInterval)theTimeInterval
{
    timeInterval = theTimeInterval;
}

+ (void)setCacheManager:(id<FAWebServiceCacheManager>)aCacheManager
{
    cacheManager = aCacheManager;
}

+ (id<FAWebServiceCacheManager>)cacheManager
{
    return cacheManager;
}

+ (id)cachedDataForServiceIdentifier:(NSString *)identifier
{
    // check if the timeout
    if ([FAWebServiceTimeout isTimeOutForServiceIdentifier:identifier]) {
        return nil;
    }
    
    if (cacheManager == nil) {
        cacheManager = [[FAWebServiceCacheManagerDefault alloc] init];
    }
    
    // I could've used a delegator for fetching method, but since this is a cache data, it needs to fast enough to fetch it.
    return [cacheManager fetchCacheDataForIdentifier:identifier];
}

+ (void)saveCacheWithIdentifier:(NSString *)identifier data:(id)data
{
    if (cacheManager == nil) {
        cacheManager = [[FAWebServiceCacheManagerDefault alloc] init];
    }
    
    [cacheManager saveCacheData:data forIdentifier:identifier];
}

@end

////////////////////////////////////
// FAWebServiceTimeout class      //
////////////////////////////////////

@interface FAWebServiceTimeout()
- (BOOL)compareNowAndLastUsageDate:(NSDate*)lastUsage;
@end

@implementation FAWebServiceTimeout

// YES if cache is valid
- (BOOL)compareNowAndLastUsageDate:(NSDate *)lastUsage
{
    // now minus time interval (1 day)
    NSDate* referenceDate = [NSDate dateWithTimeIntervalSinceNow:-timeInterval];
    NSComparisonResult comparison = [lastUsage compare:referenceDate];
    
    if (comparison == NSOrderedAscending) {
        // last usage is earlier than reference date
        return YES;
    } else {
        // last usage is equal or later than reference date
        return NO;
    }
}

// if NO, cache record is available to use, otherwise cache should be deleted
+ (BOOL)isTimeOutFromCacheDate:(NSDate *)cacheDate
{
    FAWebServiceTimeout* instance = [[FAWebServiceTimeout alloc] init];
    return [instance compareNowAndLastUsageDate:cacheDate];
}

// if NO, cache record is available to use, otherwise cache should be deleted
+ (BOOL)isTimeOutForServiceIdentifier:(NSString *)identifier
{
    NSString* lastUsageKey = [FAWebServiceKeyGenerator lastUsageKeyForIdentifier:identifier];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate* lastUsage = [defaults valueForKey:lastUsageKey];
    if (lastUsage == nil)
        return YES;
    
    return [self isTimeOutFromCacheDate:lastUsage];
}

@end

////////////////////////////////////
// FAWebServiceKeyGenerator class //
////////////////////////////////////

@implementation FAWebServiceKeyGenerator

+ (NSString*)lastUsageKeyForIdentifier:(NSString *)identifier
{
    return [NSString stringWithFormat:@"%@_LastUsage", identifier];
}

@end

////////////////////////////////////
// FAWebServiceKeyGenerator class //
////////////////////////////////////

@implementation FAWebServiceCacheManagerDefault

 - (void)saveCacheData:(id)data forIdentifier:(NSString *)identifier
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:identifier];
    [defaults setObject:[NSDate date] forKey:[FAWebServiceKeyGenerator lastUsageKeyForIdentifier:identifier]];
    [defaults synchronize];
}

- (id)fetchCacheDataForIdentifier:(NSString *)identifier
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:identifier];
}

@end
