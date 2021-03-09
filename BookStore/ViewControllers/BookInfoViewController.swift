//
//  BookInfoViewController.swift
//  BookStore
//
//  Created by Soojin Ro on 10/06/2019.
//  Copyright © 2019 Soojin Ro. All rights reserved.
//

import UIKit
import BookStoreKit
import ContentsquareModule
import Adyen

final class BookInfoViewController: UIViewController {
    private var dropInComponent: DropInComponent? = nil
    static func instantiate(isbn13: String, bookStore: BookStoreService) -> BookInfoViewController {
        let bookInfo = UIStoryboard.main.instantiateViewController(BookInfoViewController.self)
        bookInfo.bookStore = bookStore
        bookInfo.isbn13 = isbn13
        return bookInfo
    }
    
    private(set) lazy var isbn13: String = unspecified()

    override func viewDidLoad() {
        super.viewDidLoad()
        Contentsquare.send(screenViewWithName: "Book Info")
        setupViews()
        refreshInfo()
        
        
    }
    
    private func refreshInfo() {
        activityIndicator?.startAnimating()
        bookStore.fetchInfo(with: isbn13) { [weak self] (result) in
            guard let self = self else { return }
            
            self.activityIndicator?.stopAnimating()
            result.success { self.bookInfo = $0 }
                  .catch(self.handle)
        }
    }
    
    private func handle(_ error: Error) {
        let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let retry = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.refreshInfo()
        }
        alert.addActions([cancel, retry])
        
        present(alert, animated: true, completion: nil)
    }
    
    private func setupViews() {
        contentStackView?.isHidden = true
        buyButton?.layer.cornerRadius = 8
        buyButton?.layer.masksToBounds = true
    }
    
    private func layoutInfo() {
        guard let info = bookInfo else { return }
        
        titleLabel?.text = info.title
        subtitleLabel?.text = info.subtitle
        authorsLabel?.text = info.authors
        priceLabel?.text = info.price
        descriptionLabel?.text = info.shortDescription
        publisherLabel?.text = info.publisher
        yearLabel?.text = info.year
        languageLabel?.text = info.language
        lengthLabel?.text = info.pages
        isbn10Label?.text = info.isbn10
        isbn13Label?.text = info.isbn13
        ratingLabel?.text = info.rating
        
        if let thumbnailURL = info.thumbnailURL {
            ImageProvider.shared.fetch(from: thumbnailURL) { [weak self] (result) in
                self?.thumbnailImageView?.image = try? result.get()
            }
        }
        
        contentStackView?.isHidden = false
    }
    
    @IBAction private func buyButtonTapped(_ sender: UIButton) {
        Contentsquare.send(screenViewWithName: "Show Payment Methods")
        showPaymentOptions()
    }
    
    @IBAction private func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private var bookInfo: BookInfo? {
        didSet {
            layoutInfo()
        }
    }
    
    private func showPaymentOptions(){
        do {
            let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: getPaymentMethods())
            let configuration = DropInComponent.PaymentMethodsConfiguration()
            configuration.clientKey = "test_TC4V47DT5ZCDFPMMXYXNFY2OPIRQSEX4"
            let dropInComponent = DropInComponent(paymentMethods: paymentMethods, paymentMethodsConfiguration: configuration)
            
            // When you're ready to go live, change this to .live
            // or to other environment values described in https://adyen.github.io/adyen-ios/Docs/Structs/Environment.html
            dropInComponent.environment = .test
            // Optional. In this example, the Pay button will display 10 EUR.
            dropInComponent.payment = Payment(amount: Payment.Amount(value: 1000,
                                                                     currencyCode: "USD"))
            self.dropInComponent = dropInComponent
            present(dropInComponent.viewController, animated: true)
        } catch {
            
        }
        

    }
    
    private func getPaymentMethods() -> Data {
        return """
        {"paymentMethods":[{"brands":["visa","mc","amex","discover","diners"],"details":[{"key":"encryptedCardNumber","type":"cardToken"},{"key":"encryptedSecurityCode","type":"cardToken"},{"key":"encryptedExpiryMonth","type":"cardToken"},{"key":"encryptedExpiryYear","type":"cardToken"},{"key":"holderName","optional":true,"type":"text"}],"name":"Credit Card","type":"scheme"},{"name":"Pay later with Klarna.","type":"klarna"},{"name":"Pay over time with Klarna.","type":"klarna_account"}]}
        """.data(using: .utf8)!
    }
    
    private lazy var bookStore: BookStoreService = unspecified()
    @IBOutlet private weak var contentStackView: UIStackView?
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var subtitleLabel: UILabel?
    @IBOutlet private weak var authorsLabel: UILabel?
    @IBOutlet private weak var thumbnailImageView: UIImageView?
    @IBOutlet private weak var priceLabel: UILabel?
    @IBOutlet private weak var buyButton: UIButton?
    @IBOutlet private weak var descriptionLabel: UILabel?
    @IBOutlet private weak var publisherLabel: UILabel?
    @IBOutlet private weak var yearLabel: UILabel?
    @IBOutlet private weak var languageLabel: UILabel?
    @IBOutlet private weak var lengthLabel: UILabel?
    @IBOutlet private weak var isbn10Label: UILabel?
    @IBOutlet private weak var isbn13Label: UILabel?
    @IBOutlet private weak var ratingLabel: UILabel?


}

extension BookInfoViewController: DropInComponentDelegate {
    internal func didSubmit(_ data: PaymentComponentData, from component: DropInComponent) {
//        let request = PaymentsRequest(data: data)
//        apiClient.perform(request, completionHandler: paymentResponseHandler)
        print("CSLIB ℹ️ Info: SUBMIT")
    }

    internal func didProvide(_ data: ActionComponentData, from component: DropInComponent) {
//        let request = PaymentDetailsRequest(details: data.details,
//                                            paymentData: data.paymentData,
//                                            merchantAccount: Configuration.merchantAccount)
//        apiClient.perform(request, completionHandler: paymentResponseHandler)
        print("CSLIB ℹ️ Info: PROVIDE")
    }

    internal func didComplete(from component: DropInComponent) {
//        finish(with: .authorised)
        print("CSLIB ℹ️ Info: COMPLETE")
    }

    internal func didFail(with error: Error, from component: DropInComponent) {
//        finish(with: error)
        print("CSLIB ℹ️ Info: COMPLETE")
    }

    internal func didCancel(component: PaymentComponent, from dropInComponent: DropInComponent) {
        // Handle the event when the user closes a PresentableComponent.
        print("User did close: \(component)")
    }
}


