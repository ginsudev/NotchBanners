#import <UIKit/UIKit.h>

@interface DNDState : NSObject
@property (nonatomic,readonly) unsigned long long suppressionState;
@property (getter=isActive,nonatomic,readonly) BOOL active;
@end

@interface DNDStateUpdate : NSObject
@property (nonatomic,copy,readonly) DNDState * state;
@end

@interface DNDNotificationsService : NSObject
@end

@interface TLAlertConfiguration : NSObject
@end

@interface TLAlert : NSObject
+ (instancetype)alertWithConfiguration:(id)arg1;
- (void)play;
+ (BOOL)_stopAllAlerts;
@end

@interface NCNotificationSound : NSObject
@property (nonatomic,copy,readonly) TLAlertConfiguration * alertConfiguration;
@end

@protocol NCNotificationActionRunner <NSObject>
@required
-(void)executeAction:(id)arg1 fromOrigin:(NSString *)arg2 endpoint:(id)arg3 withParameters:(id)arg4 completion:(void (^)(BOOL finished))arg5;
@end

@interface NCNotificationAction : NSObject
@property (nonatomic,copy,readonly) NSDictionary * behaviorParameters;
@property (nonatomic,readonly) id<NCNotificationActionRunner> actionRunner;
@property (nonatomic,copy,readonly) NSString * title;
@property (nonatomic,readonly) unsigned long long behavior;
@property (getter=isDestructiveAction,nonatomic,readonly) BOOL destructiveAction;
@end

@interface NCNotificationOptions : NSObject
@property (nonatomic,readonly) BOOL dismissAutomatically;
@property (nonatomic,readonly) unsigned long long contentPreviewSetting;
@end

@interface NCNotificationContent : NSObject
@property (nonatomic,readonly) UIImage * icon;
@property (nonatomic,copy,readonly) NSString * header;
@property (nonatomic,copy,readonly) NSString * title;
@property (nonatomic,copy,readonly) NSString * subtitle;
@property (nonatomic,copy,readonly) NSString * message;
@end

@interface NCNotificationRequest : NSObject
@property (nonatomic,copy,readonly) NSDictionary * context;
@property (nonatomic,copy,readonly) NSString * sectionIdentifier;
@property (nonatomic,readonly) NCNotificationAction * defaultAction;
@property (nonatomic,readonly) NCNotificationSound * sound;
@property (nonatomic,copy,readonly) NSDictionary * supplementaryActions;
@property (nonatomic,readonly) NCNotificationContent * content;
@property (nonatomic,readonly) NCNotificationOptions * options;
@end

@interface SBNotificationBannerDestination : NSObject
- (void)_test_dismissNotificationRequest:(NCNotificationRequest *)arg1;
@end

@interface SBFTouchPassThroughViewController : UIViewController
@end

@interface SBFTouchPassThroughWindow : UIWindow
- (instancetype)initWithScreen:(UIScreen *)arg1 debugName:(NSString *)arg2;
@end

@interface UIStatusBarManager (Private)
@property (nonatomic,readonly) double statusBarHeight;
@end

@interface UIView (Private)
- (UIViewController *)_viewControllerForAncestor;
@end
