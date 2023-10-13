# Vault SDK - iOS integration guide

## Introduction

The Mangopay Vault SDK allows you to securely tokenize an end user’s payment card for use in your application. A tokenized card is a virtual and secure version of the card that can be used for payment.

It is very highly recommended that you use the Mangopay Vault SDK, rather than integrating the API endpoints directly. By doing so, you:

- Avoid sensitive card details transiting your system
- Benefit from PCI-DSS compliance
- Receive ongoing support and updates

<aside>
<img src="/icons/square-alternate_lightgray.svg" alt="/icons/square-alternate_lightgray.svg" width="40px" /> **Prerequisites**

To use the Mangopay Vault SDK, you’ll need:

- A Mangopay `ClientId` and API key
- A User for whom to register the card (see [Testing - Payment methods](https://preview-documentation.swarm.preprod.mangopay.com/docs/dev-tools/testing/payment-methods) for test cards)
- iOS 13+
- Xcode 12.2
- Swift 5.3+
</aside>

## **Installation**

### **Swift Package Manager (recommended)**

Follow these steps to integrate the package into your Xcode project with SPM, 

1. Open your Xcode project and go to File > Swift Packages > Add Package Dependency.
2. In the prompted dialog, enter the repository URL **https://github.com/Mangopay/mangopay-ios-vault-sdk**.
3. Select `MangoPayVault` package by checking the corresponding checkbox.
4. Proceed by following the on-screen instructions to complete the integration.

### **CocoaPod**

Open your `podfile` and add:

```swift
pod 'MangopayVaultSDK'
```

Add these sources above your `podfile` :

```swift
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/Mangopay/mangopay-ios-vault-sdk'
```

Run the install command

```bash
$pod install
```

## Creating the Card Registration

In your backend, create the Card Registration via the Mangopay API, using the `Id` of the end user as the `UserId` .

You must also define the currency and type of the card at this stage.

<aside>
<img src="/icons/square-alternate_gray.svg" alt="/icons/square-alternate_gray.svg" width="40px" /> **POST** /v2.01/`ClientId`/cardregistrations

```json
{
    "Tag": "Created with the Mangopay Vault SDK",
    "UserId": "142036728",
    "CardType": "CB_VISA_MASTERCARD",
    "Currency": "EUR"
}
```

[See parameter details →](https://preview-documentation.swarm.preprod.mangopay.com/docs/endpoints/direct-card-payins#create-card-registration)

</aside>

### API response

```json
{
    "Id": "193020188",
    "Tag": null,
    "CreationDate": 1686147148,
    "UserId": "193020185",
    "AccessKey": "1X0m87dmM2LiwFgxPLBJ",
    "PreregistrationData": "XBDYiG8w9PrylPS01KmupZunmK2QRHKIC-yUF6il3aIpAnKba1TGkR9VJe5lHjHt2ddFLVXdicolcUIkv_kKEA",
    "RegistrationData": null,
    "CardId": null,
    "CardType": "CB_VISA_MASTERCARD",
    "CardRegistrationURL": "https://homologation-webpayment.payline.com/webpayment/getToken",
    "ResultCode": null,
    "ResultMessage": null,
    "Currency": "EUR",
    "Status": "CREATED"
}
```

The data obtained in the response will be used in the `CardRegistration` defined below.

## **Initializing the SDK**

Initialize the SDK with your `ClientId` and select your environment (Sandbox or Production). 

```swift
MangoPayVault.initialize(clientId: clientId, environment: SANDBOX | PRODUCTION )
```

## Providing data for tokenization

The SDK requires the following information to tokenize the card:

- The Card Registration data previously returned by the Mangopay API (`CardRegistration`)
- The end user’s card details (`CardInfo`) entered in the app (see [Testing - Payment methods](https://preview-documentation.swarm.preprod.mangopay.com/docs/dev-tools/testing/payment-methods) for test cards)

### CardRegistration

| Property | Type | Description |
| --- | --- | --- |
| id | String | The unique identifier of the Card Registration. |
| accessKey | String | The secure value used when tokenizing the card. |
| cardRegistrationURL | String | The URL to which the card details are sent to be tokenized. |
| preregistrationData | String | A specific value passed to the cardRegistrationURL. |

```swift
let cardRegistration  = CardRegistration(
            id: id,
                        accessKey: accessKey, 
                        preregistrationData: preregistrationData, 
                        cardRegistrationURL: cardRegistrationURL, 
  )
```

### CardInfo

| Property | Type | Description |
| --- | --- | --- |
| cardNumber | string | The card number to be tokenized, without any separators. |
| cardExpirationDate | string (Format: “MMYY”) | The expiration date of the card. |
| cardCvx | string | The card verification code (on the back of the card, usually 3 digits). |

```swift
let cardInfo = CardInfo(
cardNumber: "4970107111111119",
cardExpirationDate: "1224",
cardCvx: "123"
)
```

## Tokenizing the card

You can now tokenize the card with the card data obtained previously using the frontend SDK.

The SDK automatically updates the Card Registration object to provide you with a `CardId` that can be used for payments. 

### tokenizeCard

```swift
MangoPayVault.tokenizeCard(
  card: card,
  cardRegistration: cardRegistration) { card, error in
      guard let _ = card else {
          self.showLoader(false)
          self.showAlert(with: error?.localizedDescription ?? "", title: "Failed ❌")
          return
      }
      self.showLoader(false)
      self.showAlert(with: "", title: "Successful 🎉")
  }
```

## Managing cards

You can use the following endpoints to manage cards: 

- [View a Card](https://mangopay.com/docs/endpoints/direct-card-payins#view-card) provides key information about the card, including its `Fingerprint` which can be used as an [anti-fraud tool](https://mangopay.com/docs/concepts/payments/payment-methods/card/anti-fraud-tools#card-fingerprint)
- [Deactivate a Card](https://mangopay.com/docs/endpoints/direct-card-payins#deactivate-card) allows you to irreversibly set the card as inactive

## Making card pay-ins

A registered card (`CardId`) is needed for pay-ins with the following objects:

- [The Direct Card PayIn object](https://mangopay.com/docs/endpoints/direct-card-payins#direct-card-payin-object), for one-shot card payments
- [The Recurring PayIn Registration object](https://preview-documentation.swarm.preprod.mangopay.com/docs/endpoints/recurring-card-payins#recurring-payin-registration-object), for recurring card payments
- [The Preauthorization object](https://preview-documentation.swarm.preprod.mangopay.com/docs/endpoints/preauthorizations#preauthorization-object), for 7-day preauthorized card payments
- [The Deposit Preauthorization object](https://preview-documentation.swarm.preprod.mangopay.com/docs/endpoints/preauthorizations#deposit-preauthorization-object), for 30-day preauthorized card payments

## Related resources

- [Testing - Payment methods](https://mangopay.com/docs/dev-tools/testing/payment-methods)
- [All supported payment methods](https://mangopay.com/docs/concepts/payments/payment-methods/all)
