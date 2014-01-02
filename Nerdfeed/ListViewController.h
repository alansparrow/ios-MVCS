//
//  ListViewController.h
//  Nerdfeed
//
//  Created by joeconway on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ListViewControllerRSSTypeBNR,
    ListViewControllerRSSTypeApple
} ListViewControllerRSSType;

@class RSSChannel;
@class WebViewController;

@interface ListViewController : UITableViewController <UITextFieldDelegate>
{
    RSSChannel *channel;
    ListViewControllerRSSType rssType;
    UITextField *noSTF;
    UILabel *noSLabel;
    NSInteger noS;
}
@property (nonatomic, strong) WebViewController *webViewController;
- (void)fetchEntries;

@end

// A new protocol named ListViewControllerDelegate
@protocol ListViewControllerDelegate

// Classes that conform to this protocol must implement this method:
- (void)listViewController:(ListViewController *)lvc handleObject:(id)object;
@end