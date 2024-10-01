import Flutter
import UIKit
import PaymobSDK

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    var SDKResult: FlutterResult?
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
            let nativeChannel = FlutterMethodChannel(name: "paymob_sdk_flutter",
                                                     binaryMessenger: controller.binaryMessenger)


            nativeChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                if call.method == "payWithPaymob",
                   let args = call.arguments as? [String: Any]{
                    self.SDKResult = result

                    self.callNativeSDK(arguments: args, VC: controller)
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

     // Function to call native PaymobSDK
      private func callNativeSDK(arguments: [String: Any], VC: FlutterViewController) {
          
          // Initialize Paymob SDK
          let paymob = PaymobSDK()
          var savedCards:[SavedBankCard] = []
          paymob.delegate = self
          
          //customize the SDK
          if let appName = arguments["appName"] as? String{
              paymob.paymobSDKCustomization.appName = appName
          }
          if let buttonBackgroundColor = arguments["buttonBackgroundColor"] as? NSNumber{
              
              let colorInt = buttonBackgroundColor.intValue
              let alpha = CGFloat((colorInt >> 24) & 0xFF) / 255.0
              let red = CGFloat((colorInt >> 16) & 0xFF) / 255.0
              let green = CGFloat((colorInt >> 8) & 0xFF) / 255.0
              let blue = CGFloat(colorInt & 0xFF) / 255.0
              
              let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
              
              paymob.paymobSDKCustomization.buttonBackgroundColor = color
          }
          if let buttonTextColor = arguments["buttonTextColor"] as? NSNumber{
              
              let colorInt = buttonTextColor.intValue
              let alpha = CGFloat((colorInt >> 24) & 0xFF) / 255.0
              let red = CGFloat((colorInt >> 16) & 0xFF) / 255.0
              let green = CGFloat((colorInt >> 8) & 0xFF) / 255.0
              let blue = CGFloat(colorInt & 0xFF) / 255.0
              
              let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
              
              paymob.paymobSDKCustomization.buttonTextColor = color
          }
          if let saveCardDefault = arguments["saveCardDefault"] as? Bool{
              paymob.paymobSDKCustomization.saveCardDefault = saveCardDefault
          }
          if let showSaveCard = arguments["showSaveCard"] as? Bool{
              paymob.paymobSDKCustomization.showSaveCard = showSaveCard
          }
          
                   
          if let savedCardData = arguments["savedBankCard"] as? [String: String],
             let token = savedCardData["token"],
             let maskedPanNumber = savedCardData["maskedPanNumber"],
             let cardType = savedCardData["cardType"] {

              // Now you can create a custom class in Swift
              let savedcard = SavedBankCard(token: token, maskedPanNumber: maskedPanNumber, cardType: CardType(rawValue: cardType) ?? CardType.Unknown)
              
              savedCards.append(savedcard)
          }
          
          // Call Paymob SDK with publicKey and clientSecret
          if let publicKey = arguments["publicKey"] as? String,
             let clientSecret = arguments["clientSecret"] as? String{
              do{
                  try paymob.presentPayVC(VC: VC, PublicKey: publicKey, ClientSecret: clientSecret, SavedBankCards: savedCards)
              } catch let error {
                  print(error.localizedDescription)
              }
              return
          }
      }
}


extension AppDelegate: PaymobSDKDelegate{
    public func transactionRejected() {
        self.SDKResult?("Rejected")
    }
    
    public func transactionAccepted() {
        self.SDKResult?("Successfull")
    }
    
    public func transactionPending() {
        self.SDKResult?("Pending")
    }
}
