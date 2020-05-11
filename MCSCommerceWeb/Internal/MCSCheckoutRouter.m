/* Copyright © 2019 Mastercard. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 =============================================================================*/

#import "MCSCheckoutRouter.h"
#import "MCSReachability.h"
#import "MCFCoreConstants.h"
#import "MCSTopMessageView.h"
#import "MCSWebViewController.h"

@interface MCSCheckoutRouter()

@property (nonatomic, strong) NSTimer *networkTimer;
@property (nonatomic, readwrite, nullable) UIViewController *presentingViewController;
@property (nonatomic, strong) MCSWebViewController *webViewController;
@property (nonatomic, strong) MCSTopMessageView *topMessageView;

@end

@implementation MCSCheckoutRouter


- (instancetype) initWithUrl:(NSURL *)url scheme:(NSString *)scheme presentingViewController:(UIViewController *)viewController delegate:(id<MCSWebCheckoutDelegate>)delegate {
    if (self = [super init]) {
        _webViewController = [[MCSWebViewController alloc] initWithUrl:url scheme:scheme delegate:delegate];
        self.presentingViewController = viewController;
    }
    
    return self;
}

- (void) start: error handler:(void (^)(void))errorHandler {
    NSError *isReachableError = [MCSReachability isNetworkReachable];
    if (isReachableError) {
        [self showAlert:kCoreNoInternetConnectionErrorInfo message:kCoreNoInternetConnectionMessage handler:^(UIAlertAction *action){
            errorHandler();
        }];
    } else {
        if (self.presentingViewController != NULL) {
            [_webViewController startWithViewController:[self presentingViewController]];
        } else {
            [_webViewController startWithViewController:[self topViewController]];
        }
            [self initiateNetworkAvailabilityCheck];
    }
    
}


#pragma mark - Check Internet Connectivity
- (void)initiateNetworkAvailabilityCheck {
    
    self.networkTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(checkNetworkAvailablity) userInfo:nil repeats:YES];
    [self.networkTimer fire];
}

- (void)checkNetworkAvailablity {
    
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
        
        NSError *isReachableError = [MCSReachability isNetworkReachable];
        
        if (isReachableError) {
            MCSCheckoutRouter * __weak weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.topMessageView == nil){
                    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                    NSArray *nib = [bundle loadNibNamed:@"MCSTopMessageView" owner:self options:nil];
                    self.topMessageView = (MCSTopMessageView *)[nib lastObject];
                    
                    CGRect mainBounds = [UIScreen mainScreen].bounds;
                    
                    self.topMessageView.frame = CGRectMake(0.0, 0.0, mainBounds.size.width, self.topMessageView.frame.size.height);
                    
                    [[weakSelf topViewController].view addSubview:self.topMessageView];
                    //remove after 5 seconds
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if(self.topMessageView != nil){
                            [self.topMessageView removeFromSuperview];
                            self.topMessageView = nil;
                        }
                    });
                }
            });
        }
    });
}

- (void)stop {
    [self invalidateTimer];
}

- (void)invalidateTimer {
    if (self.networkTimer.isValid) {
        [self.networkTimer invalidate];
        self.networkTimer = nil;
    }
}

- (UIViewController *)topViewController {
    
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController {
    if (rootViewController.presentedViewController == nil) {
        
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    
    return [self topViewController:presentedViewController];
}

- (void)showAlert:(NSString *)title message:(NSString *)message handler:(void (^)(UIAlertAction *))handler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:handler];
    [alertController addAction:okAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self topViewController] presentViewController:alertController animated:YES completion:nil];
    });
}

@end
