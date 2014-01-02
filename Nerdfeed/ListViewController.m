//
//  ListViewController.m
//  Nerdfeed
//
//  Created by joeconway on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "RSSChannel.h"
#import "RSSItem.h"
#import "WebViewController.h"
#import "ChannelViewController.h"
#import "BNRFeedStore.h"
#import <QuartzCore/QuartzCore.h>

@interface ListViewController ()
- (void)transferBarButtonToViewController:(UIViewController *)vc;
@end

@implementation ListViewController
@synthesize webViewController;
- (void)transferBarButtonToViewController:(UIViewController *)vc
{
    // Get the navigation controller in the detail spot of the split view controller 
    UINavigationController *nvc = [[[self splitViewController] viewControllers] 
                                                                    objectAtIndex:1];

    // Get the root view controller out of that nav controller
    UIViewController *currentVC = [[nvc viewControllers] objectAtIndex:0];
    
    // If it's the same view controller, let's not do anything
    if (vc == currentVC)
        return;
    
    // Get that view controller's navigation item 
    UINavigationItem *currentVCItem = [currentVC navigationItem];
    
    // Tell new view controller to use left bar button item of current nav item 
    [[vc navigationItem] setLeftBarButtonItem:[currentVCItem leftBarButtonItem]];
    
    // Remove the bar button item from the current view controller's nav item
    [currentVCItem setLeftBarButtonItem:nil];
}
- (id)initWithStyle:(UITableViewStyle)style 
{
    self = [super initWithStyle:style];

    if (self) {
        noS = 10;
        
        UIBarButtonItem *bbi = 
            [[UIBarButtonItem alloc] initWithTitle:@"Info" 
                                             style:UIBarButtonItemStyleBordered 
                                            target:self 
                                            action:@selector(showInfo:)];

        [[self navigationItem] setRightBarButtonItem:bbi];
        
        UISegmentedControl *rssTypeControl = [[UISegmentedControl alloc]
                                              initWithItems:[NSArray arrayWithObjects:@"BNR",
                                                             @"Apple", nil]];
        [rssTypeControl setSelectedSegmentIndex:0];
        [rssTypeControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [rssTypeControl addTarget:self
                           action:@selector(changeType:)
                 forControlEvents:UIControlEventValueChanged];
        [[self navigationItem] setTitleView:rssTypeControl];
        [self fetchEntries];
    }

    return self;
}

- (void)changeType:(id)sender
{
    rssType = [sender selectedSegmentIndex];
    
    // Add number of songs to fetch to Apple segment
    if (rssType == ListViewControllerRSSTypeApple) {
        UIBarButtonItem *nosBtn = [[UIBarButtonItem alloc] initWithTitle:@"NoS"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(chooseNoS)];
        [[self navigationItem] setLeftBarButtonItem:nosBtn];
    } else {
        [[self navigationItem] setLeftBarButtonItem:nil];
    }
    
    [self fetchEntries];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self fetchEntries];
}

- (void)chooseNoS
{
    NSLog(@"here here here");
    
    
    CGPoint center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2,
                                 [[UIScreen mainScreen] bounds].size.height / 2);

    UIViewController *tmpView = [[UIViewController alloc] init];
    
    [[tmpView view] setFrame:CGRectMake(0, 0, center.x *2, center.y *2)];
    
    UITextField *nosTextField = [[UITextField alloc] init];
    UIButton *okBtn = [[UIButton alloc] init];
    UILabel *okLabel = [[UILabel alloc] init];

    
    [nosTextField setFrame:CGRectMake(center.x/2, center.y/2, center.x*3/2, 40)];
    [nosTextField setCenter:center];
    [nosTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [nosTextField setTextAlignment:NSTextAlignmentCenter];
    [nosTextField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [nosTextField setDelegate:self];
    noSTF = nosTextField;
    
    [okBtn addTarget:self action:@selector(setNoS) forControlEvents:UIControlEventTouchDown];
    [okBtn setFrame:CGRectMake(center.x/2, center.y/2, center.x/2, 40)];
    [okBtn setCenter:CGPointMake(center.x, center.y + 50)];
    [okBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [[okBtn layer] setCornerRadius:10];
    [[okBtn layer] setBorderWidth:1];
    [[okBtn layer] setBorderColor:[[UIColor redColor] CGColor]];
    [okBtn setClipsToBounds:YES];
    
    [okLabel setFrame:CGRectMake(center.x/2, center.y/2, center.x*2, 40)];
    [okLabel setCenter:CGPointMake(center.x, center.y - 50)];
    [okLabel setTextColor:[UIColor blueColor]];
    [okLabel setTextAlignment:NSTextAlignmentCenter];
    noSLabel = okLabel;


    
    [okBtn setTitle:@"OK" forState:UIControlStateNormal];
    
//    [nosTextField setBackgroundColor:[UIColor greenColor]];
//    [okBtn setBackgroundColor:[UIColor blueColor]];
    
    
    [[tmpView view] addSubview:nosTextField];
    [[tmpView view] addSubview:okBtn];
    [[tmpView view] addSubview:okLabel];
//    [[tmpView view] setBackgroundColor:[UIColor redColor]];
    
    
    [[self navigationController] pushViewController:tmpView animated:YES];
    
}

- (void)setNoS
{
    NSLog(@"%d", noS);
    if ([[noSTF text] length]) {
        if ([[noSTF text] intValue]) {
            noS = [[noSTF text] intValue];
            [noSLabel setText:[NSString stringWithFormat:@"%d songs will be fetched.", noS]];
            NSLog(@"%d", noS);
            return;
        }
    }
    
    noS = 10;
    [noSLabel setText:[NSString stringWithFormat:@"%d songs will be fetched.", noS]];
}

- (BOOL)textFieldShouldReturn:(id)sender
{
    [sender resignFirstResponder];
    [self setNoS];
    
    return YES;
}



- (void)showInfo:(id)sender
{
    // Create the channel view controller
    ChannelViewController *channelViewController = [[ChannelViewController alloc] 
                                initWithStyle:UITableViewStyleGrouped];

    if ([self splitViewController]) {
        [self transferBarButtonToViewController:channelViewController];
            
        UINavigationController *nvc = [[UINavigationController alloc] 
                     initWithRootViewController:channelViewController];
        
        // Create an array with our nav controller and this new VC's nav controller
        NSArray *vcs = [NSArray arrayWithObjects:[self navigationController], 
                                                 nvc, 
                                                 nil];

        // Grab a pointer to the split view controller
        // and reset its view controllers array.
        [[self splitViewController] setViewControllers:vcs];

        // Make detail view controller the delegate of the split view controller 
        [[self splitViewController] setDelegate:channelViewController];

        // If a row has been selected, deselect it so that a row 
        // is not selected when viewing the info
        NSIndexPath *selectedRow = [[self tableView] indexPathForSelectedRow];
        if (selectedRow)
            [[self tableView] deselectRowAtIndexPath:selectedRow animated:YES];
    } else {
        [[self navigationController] pushViewController:channelViewController
                                               animated:YES];
    }
    
    // Give the VC the channel object through the protocol message
    [channelViewController listViewController:self handleObject:channel];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return YES;
    return io == UIInterfaceOrientationPortrait;
}
- (void)tableView:(UITableView *)tableView
                didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    // Push the web view controller onto the navigation stack - this implicitly 
    // creates the web view controller's view the first time through
    if (![self splitViewController])
        [[self navigationController] pushViewController:webViewController animated:YES];
    else {
        [self transferBarButtonToViewController:webViewController];
        // We have to create a new navigation controller, as the old one 
        // was only retained by the split view controller and is now gone
        UINavigationController *nav = 
        [[UINavigationController alloc] initWithRootViewController:webViewController];

        NSArray *vcs = [NSArray arrayWithObjects:[self navigationController],
                                                 nav,
                                                 nil];

        [[self splitViewController] setViewControllers:vcs];

        // Make the detail view controller the delegate of the split view controller 
        [[self splitViewController] setDelegate:webViewController];
    }
    // Grab the selected item
    RSSItem *entry = [[channel items] objectAtIndex:[indexPath row]];

    [webViewController listViewController:self handleObject:entry];
}


- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
    return [[channel items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = [tableView 
                            dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:@"UITableViewCell"];
    }
    RSSItem *item = [[channel items] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[item title]];
    
    return cell;
}

- (void)fetchEntries
{
    // Get ahold of the segmented control that is currently in
    // the title view
    UIView *currentTitleView = [[self navigationItem] titleView];
    
    // Create a activity indicator and start it spinning in the nav bar
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc]
                                       initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [[self navigationItem] setTitleView:aiView];
    [aiView startAnimating];
    
    void (^completionBlock)(RSSChannel *obj, NSError *err) =
    ^(RSSChannel *obj, NSError *err) {
        // When the request completes = success or failure
        // replace the activity indicator with the segmented control
        [[self navigationItem] setTitleView:currentTitleView];
        
        // When the request completes, this block will be called.
        if (!err) {
            // If everything went ok, grab the channel object and reload the table
            channel = obj;
            [[self tableView] reloadData];
        } else {
            // If things went bad, show an alert view
            NSString *errorString = [NSString stringWithFormat:@"Fetch failed: %@",
                                     [err localizedDescription]];
            
            // Create and show an alert view with this error
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:errorString
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
    };
    
    // Initiate the request...
    if (rssType == ListViewControllerRSSTypeBNR) {
        [[BNRFeedStore sharedStore] fetchRSSFeedWithCompletion:completionBlock];
    } else if (rssType == ListViewControllerRSSTypeApple) {
        [[BNRFeedStore sharedStore] fetchTopSongs:noS
                                   withCompletion:completionBlock];
    }
    
}
@end
