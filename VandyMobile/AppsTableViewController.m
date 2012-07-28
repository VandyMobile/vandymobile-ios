//
//  AppsTableViewController.m
//  VandyMobile
//
//  Created by Graham Gaylor on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppsTableViewController.h"
#import "SVProgressHUD.h"
#import "AppsAPIClient.h"
#import "App.h"
#import "VMCell.h"
#import "AppsDetailViewController.h"
#import "AppsCell.h"
#import "JSONKit.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Frame.h"
#import "Sizer.h"


@interface AppsTableViewController ()

@end

@implementation AppsTableViewController
@synthesize tableView = _tableView;
@synthesize results = _results;
//@synthesize heightOffset = _heightOffset;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create resizable UINavigationBar image
    UIImage *navImage = [UIImage imageNamed:@"NewNavBar4"];
    [self.navigationController.navigationBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
	
	[self pullAppsFromCache];
	[self pullAppsFromServer];
	[self setupRefreshAppsButton];
}

- (void)setupRefreshAppsButton {
	// Create add meeting button
	UIBarButtonItem *addMeetingButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(pullAppsFromServer)];
	[self.navigationItem setRightBarButtonItem:addMeetingButton animated:NO];
}

- (void)viewDidUnload {
	[self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    // Set the background image for *all* UINavigationBars
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NewNavBarText"]];
    if ([[self.navigationController.navigationBar subviews] count] > 2) {
        
        NSArray *navSubviews = [self.navigationController.navigationBar subviews];
        
        //        NSLog(@"%@", navSubviews);
        
        for (UIView * subview in navSubviews) {
            if ([subview isKindOfClass:[UIImageView class]] && subview != [navSubviews objectAtIndex:0]) {
                [subview removeFromSuperview];
            }
        }
    }
    [self.navigationController.navigationBar addSubview:logo];
}

#pragma mark APIClient Methods

- (void)pullAppsFromServer {
	// Status indicator. Takes place of network spinner and if no meetings are loaded
	[SVProgressHUD showWithStatus:@"Loading apps..." maskType:SVProgressHUDMaskTypeNone];
	[[AppsAPIClient sharedInstance] getPath:@"apps.json" parameters:nil
                                        success:^(AFHTTPRequestOperation *operation, id response) {
											//											NSLog(@"Response: %@", response);
											NSMutableArray *results = [NSMutableArray array];
											for (id appDictionary in response) {
												App *app = [[App alloc] initWithDictionary:appDictionary];
												[results addObject:app];
											}
											self.results = results;
											[self.tableView reloadData];
											[SVProgressHUD dismissWithSuccess:@"Done!"];
										}
										failure:^(AFHTTPRequestOperation *operation, NSError *error) {
											NSLog(@"%@",error);
											[SVProgressHUD dismissWithError:@"Error loading apps!"];
										}];
    

}

- (void)pullAppsFromCache {
	NSString *path = @"http://70.138.50.84/apps.json";
	NSURLRequest *request = [[AppsAPIClient sharedInstance] requestWithMethod:@"POST" path:path parameters:nil];
	NSCachedURLResponse *response = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
	if (response) {
		NSData *responseData = response.data;
		id appsObject = [[JSONDecoder decoder] objectWithData:responseData];
		
		NSMutableArray *results = [NSMutableArray array];
		for (id appDictionary in appsObject) {
			NSLog(@"%@", appDictionary);
			App *app = [[App alloc] initWithDictionary:appDictionary];
			[results addObject:app];
		}
		self.results = results;
		[self.tableView reloadData];
	}
}

- (void)downloadPhotoForApp:(App *)app andPhoto:(UIImageView *)imageView {
    // Download photo
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loading startAnimating];
    UIBarButtonItem * temp = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loading];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
    dispatch_async(downloadQueue, ^{
        
        NSData *imgUrl = [NSData dataWithContentsOfURL:[NSURL URLWithString:app.imagePath]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageView setImage:[UIImage imageWithData:imgUrl]];
            [loading stopAnimating];
            self.navigationItem.leftBarButtonItem = temp;
        });
    });
    dispatch_release(downloadQueue);
    
}


#pragma mark - TableView Datasource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *cellIdentifier = @"cellIdentifier";
	
	AppsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
	if(!cell) {
		cell = [[AppsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        App *app = [self.results objectAtIndex:indexPath.row];
        
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AppsCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];

        cell.mainLabel.text = app.name;
        cell.subLabel.text = app.tagline;
		[self downloadPhotoForApp:app andPhoto:cell.cellImage];//[UIImage imageNamed:@"VandyMobileIcon.png"];
        
        //CGFloat oldHeight = cell.subLabel.height;
        cell.subLabel.height = [Sizer sizeText:cell.subLabel.text withConstraint:CGSizeMake(227, MAXFLOAT) font:cell.subLabel.font andMinimumHeight:21];
        //[self.heightOffset setObject:[NSNumber numberWithFloat:(cell.subLabel.height-oldHeight)] atIndexedSubscript:indexPath.row];

		[cell configureCellForTableView:self.tableView atIndexPath:indexPath];    
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppsCell *cell = (AppsCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    CGFloat newHeight = [Sizer sizeText:cell.subLabel.text withConstraint:CGSizeMake(227, MAXFLOAT) font:[UIFont fontWithName:@"Helvetica" size:14] andMinimumHeight:21];
    return 67 + newHeight - 21;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Deselect the row
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Create new MeetingDVC
    AppsDetailViewController *appsDVC = [[AppsDetailViewController alloc] init];
    
    // Grab the meeting at the index path
    App *app = [self.results objectAtIndex:indexPath.row];
    
    // Prepare meetingDVC
    appsDVC.title = app.name;
    appsDVC.app = app;
    [self.navigationController pushViewController:appsDVC animated:YES];
    
}


@end
