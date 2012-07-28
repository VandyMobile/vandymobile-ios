//
//  LoginViewController.h
//  VandyMobile
//
//  Created by Scott Andrus on 6/22/12.
//
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) id delegate;

@end
