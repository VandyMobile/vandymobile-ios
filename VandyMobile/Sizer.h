//
//  Sizer.h
//  VandyMobile
//
//  Created by Scott Andrus on 6/16/12.
//
//

#import <Foundation/Foundation.h>

@interface Sizer : NSObject

+ (CGRect)sizeTextView:(UITextView *)textView withMaxHeight:(CGFloat)maxHeight andFont:(UIFont *)font;
+ (CGFloat)sizeText:(NSString *)text withConstraint:(CGSize)constraintSize font:(UIFont *)font andMinimumHeight:(CGFloat)minHeight;

@end
