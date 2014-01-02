//
//  BNRFeedStore.h
//  Nerdfeed
//
//  Created by Alan Sparrow on 1/2/14.
//
//

#import <Foundation/Foundation.h>

@class RSSChannel;

@interface BNRFeedStore : NSObject

+ (BNRFeedStore *)sharedStore;

- (void)fetchRSSFeedWithCompletion:(void (^)(RSSChannel *obj, NSError *err))block;

@end
