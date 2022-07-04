#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>
#import <libgscommon/libgscommon.h>

@interface UIView (Private)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface PSListController (Private)
- (void)_returnKeyPressed:(id)arg1;
@end

@interface PSSpecifier (Private)
-(void)performSetterWithValue:(id)value;
-(id)performGetter;
@end
