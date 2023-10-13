Pod::Spec.new do |s|
    s.name         = "MangopayVaultSDK"
    s.version      = "1.0.5"
    s.summary      = "Securely tokenize payment cards"
    s.description  = <<-DESC
    The Mangopay Vault SDK allows you to securely tokenize an end user’s payment card for use in your application. A tokenized card is a virtual and secure version of the card that can be used for payment.
                     DESC
    s.homepage     = "https://www.mangopay.com"
    s.swift_version = "5.0"
    s.license      = "MIT"
    s.author       = { "Elikem Savie" => "ext-elikem.savie@mangopay.com" }
    s.platform     = :ios, "13.0"
    s.source       = { :git => "https://github.com/Mangopay/mangopay-ios-vault-sdk", :tag => "#{s.version}", :branch => "main" }

    s.source_files = 'MangopayVault/*.swift', 'MangopayVault/Models/*.swift', 'MangopayVault/Networking/*.swift'

  end
  

