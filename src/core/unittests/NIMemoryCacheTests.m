//
// Copyright 2011 Jeff Verkoeyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// See: http://bit.ly/hS5nNh for unit test macros.

#import <SenTestingKit/SenTestingKit.h>

#import "NimbusCore/NimbusCore.h"
#import "NSDate+UnitTesting.h"


@interface NIMemoryCacheTests : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIMemoryCacheTests


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark In-Memory Cache


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testInitialization {
  NIMemoryCache* cache = [[[NIMemoryCache alloc] init] autorelease];

  STAssertEquals([cache count], (NSUInteger)0, @"Cache should be empty after initialization.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testSingleObjectNoExpiration {
  NIMemoryCache* cache = [[[NIMemoryCache alloc] init] autorelease];

  id cacheObject1 = [NSArray array];
  [cache storeObject:cacheObject1 withName:@"obj1"];

  STAssertEquals([cache count], (NSUInteger)1, @"Cache should have one object in it.");
  STAssertEquals([cache objectWithName:@"obj1"], cacheObject1, @"Cache object should be equal.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testMultipleObjectsNoExpiration {
  NIMemoryCache* cache = [[[NIMemoryCache alloc] init] autorelease];

  id cacheObject1 = [NSArray array];
  [cache storeObject:cacheObject1 withName:@"obj1"];

  id cacheObject2 = [NSArray array];
  [cache storeObject: cacheObject2 withName: @"obj2"];

  STAssertEquals([cache count], (NSUInteger)2, @"Cache should have two objects in it.");
  STAssertEquals([cache objectWithName:@"obj1"], cacheObject1, @"Cache object should be equal.");
  STAssertEquals([cache objectWithName:@"obj2"], cacheObject2, @"Cache object should be equal.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testRemovingSingleObject {
  NIMemoryCache* cache = [[[NIMemoryCache alloc] init] autorelease];

  id cacheObject1 = [NSArray array];
  [cache storeObject:cacheObject1 withName:@"obj1"];

  [cache removeObjectWithName:@"obj1"];

  STAssertEquals([cache count], (NSUInteger)0, @"Cache should be empty.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testRemovingAllObjects {
  NIMemoryCache* cache = [[[NIMemoryCache alloc] init] autorelease];

  id cacheObject1 = [NSArray array];
  [cache storeObject:cacheObject1 withName:@"obj1"];

  id cacheObject2 = [NSArray array];
  [cache storeObject:cacheObject2 withName:@"obj2"];

  STAssertEquals([cache count], (NSUInteger)2, @"Cache should have two objects in it.");
  [cache removeAllObjects];
  STAssertEquals([cache count], (NSUInteger)0, @"Cache should now be empty.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testSingleObjectWithFutureExpiration {
  NIMemoryCache* cache = [[[NIMemoryCache alloc] init] autorelease];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:1]];

  STAssertEquals([cache count], (NSUInteger)1, @"Cache should have one object in it.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testMultipleObjectsWithFutureExpiration {
  NIMemoryCache* cache = [[[NIMemoryCache alloc] init] autorelease];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:1]];

  id cacheObject2 = [NSArray array];
  [cache storeObject: cacheObject2
            withName: @"obj2"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:100]];

  STAssertEquals([cache count], (NSUInteger)2, @"Cache should have two objects in it.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testSingleObjectWithPastExpiration {
  NIMemoryCache* cache = [[[NIMemoryCache alloc] init] autorelease];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:-1]];

  STAssertEquals([cache count], (NSUInteger)0, @"Cache should be empty.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testMultipleObjectsWithPastExpiration {
  NIMemoryCache* cache = [[[NIMemoryCache alloc] init] autorelease];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:-1]];

  id cacheObject2 = [NSArray array];
  [cache storeObject: cacheObject2
            withName: @"obj2"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:-100]];

  STAssertEquals([cache count], (NSUInteger)0, @"Cache should be empty.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testSingleObjectWithExpiredUpdate {
  NIMemoryCache* cache = [[[NIMemoryCache alloc] init] autorelease];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"];

  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:-1]];

  STAssertEquals([cache count], (NSUInteger)0, @"Cache should be empty.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testSingleObjectWithNonExpiredUpdate {
  NIMemoryCache* cache = [[[NIMemoryCache alloc] init] autorelease];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"];

  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:1]];

  STAssertEquals([cache count], (NSUInteger)1, @"Cache should have one item.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testSingleObjectWithExpiration {
  NIMemoryCache* cache = [[[NIMemoryCache alloc] init] autorelease];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:1]];

  [NSDate setFakeDate:[NSDate dateWithTimeIntervalSinceNow:2]];

  // This makes [NSDate date] call our fakeDate implementation, which allows us to fake the
  // current time so that we don't have to pause the tests while we wait for the object to
  // expire.
  [NSDate swizzleMethodsForUnitTesting];

  STAssertEquals([cache count], (NSUInteger)1, @"Cache should have one object.");

  // Accessing an expired object removes it from the cache entirely.
  STAssertNil([cache objectWithName:@"obj1"], @"Object should have expired.");

  STAssertEquals([cache count], (NSUInteger)0, @"Cache should be empty.");

  // Reset the class implementations when we're done with them.
  [NSDate swizzleMethodsForUnitTesting];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testReduceMemoryUsage {
  NIMemoryCache* cache = [[[NIMemoryCache alloc] init] autorelease];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:1]];

  id cacheObject2 = [NSDictionary dictionary];
  [cache storeObject: cacheObject2
            withName: @"obj2"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:10]];

  [NSDate setFakeDate:[NSDate dateWithTimeIntervalSinceNow:2]];

  // This makes [NSDate date] call our fakeDate implementation, which allows us to fake the
  // current time so that we don't have to pause the tests while we wait for the object to
  // expire.
  [NSDate swizzleMethodsForUnitTesting];

  STAssertEquals([cache count], (NSUInteger)2, @"Cache should have two objects.");

  [cache reduceMemoryUsage];

  STAssertNil([cache objectWithName:@"obj1"], @"Object 1 should have expired.");

  STAssertEquals([cache count], (NSUInteger)1, @"Cache should have one object left.");

  STAssertNotNil([cache objectWithName:@"obj2"], @"Object 2 should still be around.");

  // Reset the class implementations when we're done with them.
  [NSDate swizzleMethodsForUnitTesting];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @brief Create an image of a given size. The contents are undefined.
 */
- (UIImage *)emptyImageWithSize:(CGSize)size {
  UIGraphicsBeginImageContext(size);
  UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testImageCacheStoreTooMuch {
  NIImageMemoryCache* cache = [[[NIImageMemoryCache alloc] init] autorelease];

  static const NSUInteger numberOfBytesInOneImage = 100 * 100 * 4;
  cache.maxTotalMemoryUsage = numberOfBytesInOneImage;

  UIImage* img1 = [self emptyImageWithSize:CGSizeMake(100, 100)];
  UIImage* img2 = [self emptyImageWithSize:CGSizeMake(100, 100)];

  [cache storeObject: img1
            withName: @"obj1"];

  // This second image will push out the first image.
  [cache storeObject: img2
            withName: @"obj2"];

  STAssertEquals([cache count], (NSUInteger)1, @"Cache should have one object.");
  STAssertNil([cache objectWithName:@"obj1"], @"Image 1 should not still be around.");
  STAssertNotNil([cache objectWithName:@"obj2"], @"Image 2 should still be around.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testImageCacheReduceMemoryUsage {
  NIImageMemoryCache* cache = [[[NIImageMemoryCache alloc] init] autorelease];

  static const NSUInteger numberOfBytesInOneImage = 100 * 100 * 4;
  cache.maxTotalMemoryUsage = numberOfBytesInOneImage * 2;
  cache.maxTotalLowMemoryUsage = numberOfBytesInOneImage;

  UIImage* img1 = [self emptyImageWithSize:CGSizeMake(100, 100)];
  UIImage* img2 = [self emptyImageWithSize:CGSizeMake(100, 100)];

  [cache storeObject: img1
            withName: @"obj1"];

  [cache storeObject: img2
            withName: @"obj2"];

  STAssertEquals([cache count], (NSUInteger)2, @"Cache should have two objects.");

  // Our "low memory" cache size will only fit one image. The first image should be the one
  // removed.
  [cache reduceMemoryUsage];

  STAssertEquals([cache count], (NSUInteger)1, @"Cache should have one object.");
  STAssertNil([cache objectWithName:@"obj1"], @"Image 1 should not still be around.");
  STAssertNotNil([cache objectWithName:@"obj2"], @"Image 2 should still be around.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testImageCacheReduceMemoryUsageWithAccess {
  NIImageMemoryCache* cache = [[[NIImageMemoryCache alloc] init] autorelease];

  static const NSUInteger numberOfBytesInOneImage = 100 * 100 * 4;
  cache.maxTotalMemoryUsage = numberOfBytesInOneImage * 2;
  cache.maxTotalLowMemoryUsage = numberOfBytesInOneImage;

  UIImage* img1 = [self emptyImageWithSize:CGSizeMake(100, 100)];
  UIImage* img2 = [self emptyImageWithSize:CGSizeMake(100, 100)];

  [cache storeObject: img1
            withName: @"obj1"];

  [cache storeObject: img2
            withName: @"obj2"];

  // Update the access time for img1.
  [cache objectWithName:@"obj1"];

  STAssertEquals([cache count], (NSUInteger)2, @"Cache should have two objects.");

  // Our "low memory" cache size will only fit one image.
  [cache reduceMemoryUsage];

  STAssertEquals([cache count], (NSUInteger)1, @"Cache should have one object.");
  STAssertNotNil([cache objectWithName:@"obj1"], @"Image 1 should still be around.");
  STAssertNil([cache objectWithName:@"obj2"], @"Image 2 should not still be around.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testImageCacheReduceMemoryUsageWithThrashingAccess {
  NIImageMemoryCache* cache = [[[NIImageMemoryCache alloc] init] autorelease];

  static const NSUInteger numberOfBytesInOneImage = 100 * 100 * 4;
  cache.maxTotalMemoryUsage = numberOfBytesInOneImage * 2;
  cache.maxTotalLowMemoryUsage = numberOfBytesInOneImage;

  UIImage* img1 = [self emptyImageWithSize:CGSizeMake(100, 100)];
  UIImage* img2 = [self emptyImageWithSize:CGSizeMake(100, 100)];

  [cache storeObject: img1
            withName: @"obj1"];

  [cache storeObject: img2
            withName: @"obj2"];

  for (NSInteger ix = 0; ix < 10; ++ix) {
    [cache objectWithName:@"obj1"];
    [cache objectWithName:@"obj2"];
  }

  STAssertEquals([cache count], (NSUInteger)2, @"Cache should have two objects.");

  // Our "low memory" cache size will only fit one image.
  [cache reduceMemoryUsage];

  STAssertEquals([cache count], (NSUInteger)1, @"Cache should have one object.");
  STAssertNil([cache objectWithName:@"obj1"], @"Image 1 should not still be around.");
  STAssertNotNil([cache objectWithName:@"obj2"], @"Image 2 should still be around.");
}


@end