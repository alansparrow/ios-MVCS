//
//  BNRConnection.h
//  Nerdfeed
//
//  Created by Alan Sparrow on 1/2/14.
//
//

#import <Foundation/Foundation.h>

@interface BNRConnection : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

{
    NSURLConnection *internalConnection;
    NSMutableData *container;
}

- (id)initWithRequest:(NSURLRequest *)req;

@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, copy) void (^completionBlock)(id obj, NSError *err);
@property (nonatomic, strong) id <NSXMLParserDelegate> xmlRootObject;

- (void)start;


@end
