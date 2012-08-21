//
//  FAWebServiceCacheTests.m
//
//  Created by Suleyman Melikoglu on 8/21/12.
//  Copyright (c) 2012 suleymanmelikoglu@gmail.com. All rights reserved.
//

#import "FAWebServiceCacheTests.h"

#define kTestServiceIdentifier @"testServiceIdentifier"

@implementation FAWebServiceCacheTests

- (void)testKeyGenerator
{
    NSString* key = @"myKey";
    NSString* expectedResult = @"myKey_LastUsage";
    STAssertTrue([expectedResult isEqualToString:[FAWebServiceKeyGenerator lastUsageKeyForIdentifier:key]], @"key generation failed");
}

- (void)testTimeoutFromCacheDate
{
    // time interval is one day
    [FAWebServiceCache setTimeInterval:60*60*24];
    
    NSDate* twoDaysAgo = [NSDate dateWithTimeIntervalSinceNow:-60*60*24*2];
    BOOL isTimeOut = [FAWebServiceTimeout isTimeOutFromCacheDate:twoDaysAgo];
    STAssertTrue(isTimeOut, @"the cache is too old, time is out, it should be OK to fetch new records");
    
    NSDate* sevenHoursAgo = [NSDate dateWithTimeIntervalSinceNow:-60*60*7];
    isTimeOut = [FAWebServiceTimeout isTimeOutFromCacheDate:sevenHoursAgo];
    STAssertFalse(isTimeOut, @"the cache is too new, still in time interval, it should NOT be OK to fetch new records");
}

- (void)testTimeoutFromIdentifier
{
    // cache is 2 seconds
    [FAWebServiceCache setTimeInterval:2];
    [FAWebServiceCache saveCacheWithIdentifier:kTestServiceIdentifier data:[NSArray arrayWithObjects:@"1", @"2", nil]];
    
    BOOL isTimeOut = [FAWebServiceTimeout isTimeOutForServiceIdentifier:kTestServiceIdentifier];
    STAssertFalse(isTimeOut, @"cache is too new, cache should be available within 2 seconds");
    
    // let the 2 seconds pass
    [NSThread sleepForTimeInterval:3];
    isTimeOut = [FAWebServiceTimeout isTimeOutForServiceIdentifier:kTestServiceIdentifier];
    STAssertTrue(isTimeOut, @"cache should be unavailable since 2 seconds has passed");
}

- (void)testDefaultCacheManagerSaveData
{
    FAWebServiceCacheManagerDefault* defaultCacheManager = [[FAWebServiceCacheManagerDefault alloc] init];
    NSArray* sampleData = [NSArray arrayWithObjects:@"1st item", @"2nd item", nil];
    
    [defaultCacheManager saveCacheData:sampleData forIdentifier:kTestServiceIdentifier];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* cachedData = [defaults objectForKey:kTestServiceIdentifier];
    STAssertEqualObjects(sampleData, cachedData, @"cached data should be equal");
}

- (void)testDefaultCacheManagerFetch
{
    FAWebServiceCacheManagerDefault* defaultCacheManager = [[FAWebServiceCacheManagerDefault alloc] init];
    NSArray* sampleData = [NSArray arrayWithObjects:@"1st item", @"2nd item", nil];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:sampleData forKey:kTestServiceIdentifier];
    
    NSArray* cachedData = [defaultCacheManager fetchCacheDataForIdentifier:kTestServiceIdentifier];
    STAssertEqualObjects(sampleData, cachedData, @"cached data should be equal");
}

- (void)testDefaultCacheManagerUsage
{
    FAWebServiceCacheManagerDefault* defaultCacheManager = [[FAWebServiceCacheManagerDefault alloc] init];
    NSArray* sampleData = [NSArray arrayWithObjects:@"1st item", @"2nd item", nil];
    
    [defaultCacheManager saveCacheData:sampleData forIdentifier:kTestServiceIdentifier];
    
    NSArray* cachedData = [defaultCacheManager fetchCacheDataForIdentifier:kTestServiceIdentifier];
    STAssertEqualObjects(sampleData, cachedData, @"cached data should be equal");
}

- (void)testWebServiceCache
{
    NSTimeInterval timeInterval = 2; // timeout is 2 seconds
    NSArray* sampleData = [NSArray arrayWithObjects:@"1st item", @"2nd item", nil];
    
    // settings
    [FAWebServiceCache setTimeInterval:timeInterval];
    [FAWebServiceCache setCacheManager:[[FAWebServiceCacheManagerDefault alloc] init]];
    
    // save the cache
    [FAWebServiceCache saveCacheWithIdentifier:kTestServiceIdentifier data:sampleData];
    
    // cache should be available in 2 seconds
    BOOL isTimeOut = [FAWebServiceTimeout isTimeOutForServiceIdentifier:kTestServiceIdentifier];
    STAssertFalse(isTimeOut, @"cache should be available in 2 seconds");
    
    // cached data should be available
    NSArray* cachedData = [FAWebServiceCache cachedDataForServiceIdentifier:kTestServiceIdentifier];
    STAssertNotNil(cachedData, @"cache data should be available since we're within 2 seconds");
    STAssertTrue([cachedData isKindOfClass:[NSArray class]], @"cache data integrity failed");
    STAssertTrue(2 == [cachedData count], @"cache data integrity failed");
    STAssertTrue([[cachedData objectAtIndex:0] isEqualToString:@"1st item"], @"cache data integrity failed");
    STAssertTrue([[cachedData objectAtIndex:1] isEqualToString:@"2nd item"], @"cache data integrity failed");
    
    // let some time pass
    [NSThread sleepForTimeInterval:timeInterval + 1];
    
    isTimeOut = [FAWebServiceTimeout isTimeOutForServiceIdentifier:kTestServiceIdentifier];
    STAssertTrue(isTimeOut, @"cache should NOT be available since 2 seconds passed");
    
    cachedData = [FAWebServiceCache cachedDataForServiceIdentifier:kTestServiceIdentifier];
    STAssertNil(cachedData, @"cache data should NOT be available since 2 seconds passed");
}

@end
