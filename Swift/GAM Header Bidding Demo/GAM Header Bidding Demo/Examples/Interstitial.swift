import UIKit
// Step 1: Import Google Mobile Ads into your class
import GoogleMobileAds
// Step 3: Import HyBid into your class
import HyBid

class Interstitial: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var showAdButton: UIButton!

// Step 2: Create a GAMInterstitialAd property
    var interstitialAd: GAMInterstitialAd?
// Step 4: Create a HyBidAdRequest property
    var interstitialAdRequest =  HyBidInterstitialAdRequest()
    let adUnitID = "/6499/example/interstitial"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "GAM Header Bidding Interstitial"
    }

    @IBAction func loadAdTouchUpInside(_ sender: UIButton) {
        activityIndicator.startAnimating()
        showAdButton.isHidden = true
// Step 5: Initialize the HyBidInterstitialAdRequest property and request a HyBidAd
        interstitialAdRequest.requestAd(with: self, withZoneID: "4")
    }
    
    @IBAction func showAdTouchUpInside(_ sender: UIButton) {
// Step 10: Check canPresentFromRootViewController:error: method on GAMInterstitialAd to find out if it is ready to be shown
        do {
            try interstitialAd?.canPresent(fromRootViewController: self)
            if interstitialAd != nil {
                interstitialAd?.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
        } catch {
            print("Error: \(error)")
        }
    }
}

// Step 9: Implement the GADFullScreenContentDelegate methods
extension Interstitial : GADFullScreenContentDelegate {
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        activityIndicator.stopAnimating()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        showAdButton.isHidden = true
    }
}

// Step 6: Implement the HyBidAdRequestDelegate methods
extension Interstitial : HyBidAdRequestDelegate {
    func requestDidStart(_ request: HyBidAdRequest!) {
        print("Request\(String(describing: request)) started")
    }

    func request(_ request: HyBidAdRequest!, didLoadWith ad: HyBidAd!) {
        print("Request loaded with ad: \(String(describing: ad))")
        if (request == self.interstitialAdRequest) {
            // Step 7: Request a Google Mobile ad with some parameters as keywords
            let request = GAMRequest()
            request.customTargeting = (HyBidHeaderBiddingUtils.createHeaderBiddingKeywordsDictionary(with: ad) as! [String : String])
            GAMInterstitialAd.load(withAdManagerAdUnitID: adUnitID, request: request) { [self] ad, error in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                interstitialAd = ad
                activityIndicator.stopAnimating()
                showAdButton.isHidden = false
                // Step 8: Set GADFullScreenContentDelegate delegate
                interstitialAd?.fullScreenContentDelegate = self
               }
            }
        }

    func request(_ request: HyBidAdRequest!, didFailWithError error: Error!) {
        print("Request\(String(describing: request)) failed with error: \(error.localizedDescription)")
        GAMInterstitialAd.load(withAdManagerAdUnitID: adUnitID, request: GAMRequest()) { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            interstitialAd = ad
            activityIndicator.stopAnimating()
            showAdButton.isHidden = false
            interstitialAd?.fullScreenContentDelegate = self
        }
    }
}
