iOS-CacheManager
================

Simple data cache mechanism for iOS apps. The class saves the data object so you can retrieve some other time. The class supports cache-timeout, that you can only retrieve cache record within the time limit. The default time limit is 1 day.

Installation
------------

Copy the files in 'src' folder to your iOS project

Usage
-----

To save the data object 
    
    // save the cache
    [FAWebServiceCache saveCacheWithIdentifier:@"the service identifier" data:myData];

To fetch the data from cache

    NSArray* cachedData = [FAWebServiceCache cachedDataForServiceIdentifier:@"the service identifier"];

You can customize the settings

    // the cache interval is 1 hour
    [FAWebServiceCache setTimeInterval:60*60];
    
    // use can use a custom cache manager, the default one uses the NSUserDefaults
    [FAWebServiceCache setCacheManager:[[FAWebServiceCacheManagerDefault alloc] init]];
