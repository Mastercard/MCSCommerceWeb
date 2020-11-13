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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MCSCheckoutButton.h"

@interface MCSCheckoutButtonManager : NSObject
/**
 Checkout Button Shared Manager

 @return sharedManager
 */
+(instancetype)sharedManager;

/**
 This method is responsible for reading svg file, parse the content and create UIImage object out of the received SVG file path
 
 @param delegate MCSCheckoutDelegate object to implement the checkout delegate call
 @return checkout button MCSCheckoutButton
 */
- (MCSCheckoutButton *)checkoutButtonWithDelegate:(id<MCSCheckoutDelegate>)delegate;

- (MCSCheckoutButton *)checkoutButtonWithDelegate:(id<MCSCheckoutDelegate>)delegate withImage:(UIImage *)image;

@end
