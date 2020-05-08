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

import Foundation
import Alamofire
import MerchantServices
import MCSCommerceWeb


/// OrderSummaryAPIDataManager implements the OrderSummaryAPIDataManagerInputProtocol protocol, if data needs to be saved/retrieved from the server, all the implentation should be done here
class OrderSummaryAPIDataManager: OrderSummaryAPIDataManagerInputProtocol, MCSCheckoutDelegate {
    var completionHandler: (([AnyHashable : Any]?, Error?) -> ())? = nil
    
    
    // MARK: Initializers
    /// Base initializer
    init() {}
    
    /// Gets the payment data from OneServer using the checkout response information
    ///
    /// - Parameter completionHandler: Block of code to execute after the payment data response
    func getPaymentData(completionHandler: @escaping (NSDictionary?, Error?) -> ()){
        let checkoutResponse: CheckoutResponse = CheckoutResponse.sharedInstance
        
        var checkoutId:String!
        var merchantKeyFileName:String!
        var merchantKeyFilePassword:String!
        var consumerKey:String!
        var host:String!
        
        let env = SDKConfiguration.sharedInstance.environment
           switch env {
           case .SANDBOX:
                XCCParser.sharedInstance.parseXCConfig(configName: Constants.envEnum.SANDBOX.rawValue)
                XCCParser.sharedInstance.paymentDataXConfig(&checkoutId, &merchantKeyFileName, &merchantKeyFilePassword, &consumerKey, &host)
           case .STAGE:
                XCCParser.sharedInstance.parseXCConfig(configName: Constants.envEnum.STAGE.rawValue)
                XCCParser.sharedInstance.paymentDataXConfig(&checkoutId, &merchantKeyFileName, &merchantKeyFilePassword, &consumerKey, &host)
           case .PRODUCTION:
                XCCParser.sharedInstance.parseXCConfig(configName: Constants.envEnum.PRODUCTION.rawValue)
                XCCParser.sharedInstance.paymentDataXConfig(&checkoutId, &merchantKeyFileName, &merchantKeyFilePassword, &consumerKey, &host)
           }
        
        let paymentDataService = MDSMerchantServices()
        let paymentDataRequest = MDSPaymentDataRequest()
        paymentDataRequest.cartId = ShoppingCart.sharedInstance.cartId
        paymentDataRequest.checkoutId = checkoutId
        paymentDataRequest.transactionId = checkoutResponse.transactionId!
        paymentDataRequest.merechantKeyFileName = merchantKeyFileName
        paymentDataRequest.merechantKeyFilePassword = merchantKeyFilePassword
        paymentDataRequest.consumerKey = consumerKey
        paymentDataRequest.host = host
        
        var responseDict = NSDictionary()
        let responseKeys: [String] = ["status", "data"]
        
        paymentDataService.getChekcoutResourceService(paymentDataRequest, onSuccess: { responseObject in
            
            let paymentData: PaymentData = PaymentData.sharedInstance
            if (responseObject != nil) {
                
                let paymentDataDict:NSDictionary = responseObject! as NSDictionary
                // CARD
                paymentData.card?.brandId = paymentDataDict.value(forKeyPath: "card.brandId") as? String
                paymentData.card?.brandName = paymentDataDict.value(forKeyPath: "card.brandName") as? String
                paymentData.card?.cardHolderName = paymentDataDict.value(forKeyPath: "cardHolderName") as? String
                paymentData.card?.expiryMonth = paymentDataDict.value(forKeyPath: "expiryMonth") as? Int
                paymentData.card?.expiryYear = paymentDataDict.value(forKeyPath: "expiryYear") as? Int
                paymentData.card?.accountNumber = paymentDataDict.value(forKeyPath: "card.accountNumber") as? String
                paymentData.card?.cardHolderName = paymentDataDict.value(forKeyPath: "card.cardHolderName") as? String
                // Shipping address
                paymentData.shippingAddress?.line1 = paymentDataDict.value(forKeyPath: "card.billingAddress.line1") as? String
                paymentData.shippingAddress?.line2 = paymentDataDict.value(forKeyPath: "card.billingAddress.line2") as? String
                paymentData.shippingAddress?.line3 = paymentDataDict.value(forKeyPath: "scard.billingAddress.line3") as? String
                paymentData.shippingAddress?.line4 = paymentDataDict.value(forKeyPath: "card.billingAddress.line4") as? String
                paymentData.shippingAddress?.line5 = paymentDataDict.value(forKeyPath: "card.billingAddress.line5") as? String
                paymentData.shippingAddress?.city = paymentDataDict.value(forKeyPath: "card.billingAddress.city") as? String
                paymentData.shippingAddress?.country = paymentDataDict.value(forKeyPath: "card.billingAddress.country") as? String
                paymentData.shippingAddress?.subdivision = paymentDataDict.value(forKeyPath: "card.billingAddress.subdivision") as? String
                paymentData.shippingAddress?.postalCode = paymentDataDict.value(forKeyPath: "card.billingAddress.postalCode") as? String
                responseDict = NSDictionary.init(objects: [Constants.status.OK, paymentData], forKeys: responseKeys as [NSCopying])
            } else {
                responseDict = NSDictionary.init(objects: [Constants.status.NOK, paymentData], forKeys: responseKeys as [NSCopying])
            }
            completionHandler(responseDict, nil)
        }) { err in
            responseDict = NSDictionary.init(objects: [Constants.status.NOK, ""], forKeys: responseKeys as [NSCopying])
            completionHandler(responseDict, err)
        }
    }
    
    
    
    func initializeSdk(with viewController: UIViewController?) {
        /*
        * NOTE: Set the locale to "en_GB" if you want to test Prod
        * locale: Locale(identifier: "en_GB")
        */
        let configuration: SDKConfiguration = SDKConfiguration.sharedInstance
        var checkoutId:String!
        var checkoutUrl:String!
        let env = SDKConfiguration.sharedInstance.environment
        switch env {
        case .SANDBOX:
            XCCParser.sharedInstance.parseXCConfig(configName: Constants.envEnum.SANDBOX.rawValue)
            XCCParser.sharedInstance.xconfigEnvironment(&checkoutId, &checkoutUrl)
        case .STAGE:
            XCCParser.sharedInstance.parseXCConfig(configName: Constants.envEnum.STAGE.rawValue)
            XCCParser.sharedInstance.xconfigEnvironment(&checkoutId, &checkoutUrl)
        case .PRODUCTION:
            XCCParser.sharedInstance.parseXCConfig(configName: Constants.envEnum.PRODUCTION.rawValue)
            XCCParser.sharedInstance.xconfigEnvironment(&checkoutId, &checkoutUrl)
        }
        
        /*
         * NOTE: Set the locale to "en_GB" if you want to test Prod
         * locale: Locale(identifier: "en_GB")
         */
        let commerceConfig: MCSConfiguration = MCSConfiguration(
            locale: configuration.getLocaleFromSelectedLanguage(),
            checkoutId: checkoutId,
            checkoutUrl: checkoutUrl,
            callbackScheme: BuildConfiguration.sharedInstance.merchantUrlScheme(),
            allowedCardTypes: [.master, .visa, .amex])
        commerceConfig.presentingViewController = viewController
        SRCSDKManager.sharedInstance.initializeSdk(configuration: commerceConfig)
    }
    
    func getCheckoutButton(completionHandler: @escaping ([AnyHashable : Any]?, Error?) -> ()) -> MCSCheckoutButton {
        self.completionHandler = completionHandler
        
        return SRCSDKManager.sharedInstance.getCheckoutButton(with: self)
    }
    
    // MARK: Delegate methods
    
    func getCheckoutRequest(withHandler handler: @escaping (MCSCheckoutRequest) -> Void) {
        handler(getCheckoutRequest())
    }
    
    func checkoutCompleted(withRequest request: MCSCheckoutRequest, status: MCSCheckoutStatus, transactionId: String?) {
        completionHandler?(["TransactionId" : transactionId ?? ""], nil)
        CheckoutResponse.sharedInstance.transactionId = transactionId
        if (status == MCSCheckoutStatus.success) {
            CallbackResponseHandlerManager.handle(checkoutResponse: CheckoutResponse.sharedInstance, withSDKManager: SRCSDKManager.sharedInstance)
        }
    }
    
    func getCheckoutRequest() -> MCSCheckoutRequest {
        let shoppingCart: ShoppingCart = ShoppingCart.sharedInstance
        let sdkConfig : SDKConfiguration = SDKConfiguration.sharedInstance
        
        let checkoutRequest = MCSCheckoutRequest()
        checkoutRequest.amount = NSDecimalNumber(string: String(shoppingCart.total))
        checkoutRequest.currency = sdkConfig.currency
        checkoutRequest.cartId = shoppingCart.cartId
        checkoutRequest.suppressShippingAddress = sdkConfig.suppressShipping
        checkoutRequest.unpredictableNumber = "12345678"

        let cryptoOptionMaster = MCSCryptoOptions()
        cryptoOptionMaster.cardType = "master"
        cryptoOptionMaster.format = ["ICC,UCAF"]
        
        checkoutRequest.cryptoOptions = [cryptoOptionMaster]
        
        return checkoutRequest
    }
}
