//
//  JSONSerializable.h
//  Nerdfeed
//
//  Created by Alan Sparrow on 1/2/14.
//
//

#import <Foundation/Foundation.h>

@protocol JSONSerializable <NSObject>

- (void)readFromJSONDictionary:(NSDictionary *)d;

@end
