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

#import "MCSConfiguration.h"

@implementation MCSConfiguration

- (instancetype _Nonnull) initWithLocale:(NSLocale *)locale
                              checkoutId:(NSString *)checkoutId
                                     baseUrl:(NSString *)baseUrl
                                  callbackScheme:(NSString *)scheme
allowedCardTypes:(NSSet<MCSCardType> *)allowedCardTypes{
    if (self = [super init]) {
        self.locale = locale;
        self.checkoutId = checkoutId;
        self.baseUrl = baseUrl;
        self.callbackScheme = scheme;
        self.allowedCardTypes = allowedCardTypes;
    }
    
    return self;
}


@end
