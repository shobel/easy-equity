# Plaid Link for iOS [![version][link-sdk-version]][link-sdk-pod-url] [![swift compatibility][link-sdk-swift-compat]][link-sdk-spi-url]

📱 This repository contains multiple sample applications for (requiring Xcode 11) that demonstrates integration and use of Plaid Link for iOS.
* [Swift+UIKit](LinkDemo-Swift/LinkDemo-Swift-UIKit)
* [Swift+SwiftUI](LinkDemo-Swift/LinkDemo-Swift-SwiftUI)
* [Objective-C](LinkDemo-ObjC)

📚 Detailed instructions on how to integrate with Plaid Link for iOS can be found in our main documentation at [plaid.com/docs/link/ios][link-ios-docs]. 

⚠️ iOS Link SDK versions prior to 2.2.2 (released October 2021) will no longer work with the Plaid API as of November 1, 2022. If you are using a version of the iOS Link SDK earlier than 2.2.2, you **must** upgrade to version 2.2.2 or later before November 1, 2022. For details on how to migrate from LinkKit 1.x to LinkKit 2.x please review the [Link Migration Guide][link-1-2-migration].

1️⃣  The previous major version of LinkKit can be found on the [main-v1][link-main-v1] branch.

## About the LinkDemo Xcode projects

Plaid Link can be used for different use-cases and the sample applications demonstrate how to use Plaid Link for iOS for each use-case.
For clarity between the different use cases each use case specific example showing how to integrate Plaid Link for iOS is implemented in a Swift extension.

Before building and running the sample application replace any Xcode placeholder strings (like `<#GENERATED_LINK_TOKEN#>`) in the code with the appropriate value so that Plaid Link is configured properly. For convenience the Xcode placeholder strings are also marked as compile-time warnings.

Select your desired use-case in [`ViewController.didTapButton`](https://github.com/plaid/plaid-link-ios/search?q=didtapbutton) then build and run the demo application to experience the particular Link flow for yourself.

[link-ios-docs]: https://plaid.com/docs/link/ios
[link-sdk-version]: https://img.shields.io/cocoapods/v/Plaid
[link-sdk-pod-url]: https://cocoapods.org/pods/Plaid
[link-sdk-spi-url]: https://swiftpackageindex.com/plaid/plaid-link-ios
[link-sdk-swift-compat]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fplaid%2Fplaid-link-ios%2Fbadge%3Ftype%3Dswift-versions
[link-1-2-migration]: https://plaid.com/docs/link/ios/ios-v2-migration
[link-main-v1]: https://github.com/plaid/plaid-link-ios/tree/main-v1
