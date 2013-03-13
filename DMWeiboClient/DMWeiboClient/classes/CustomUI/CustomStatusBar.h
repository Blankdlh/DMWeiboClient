//
//  CustomStatusBar.h
//  ZFSoftForIOS
//
//  Created by Blank on 12-12-18.
//
//



@interface CustomStatusBar : UIWindow


+ (void)showStatusMessage:(NSString *)message autoDismiss:(BOOL)autoDismiss;
+ (void)hide;
@end
