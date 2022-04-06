import UIKit
// Step 1: Import Google Mobile Ads into your class
import GoogleMobileAds
// Step 6: Import HyBid into your class
import HyBid

class Banner: UIViewController {

    @IBOutlet weak var bannerAdContainer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

// Step 2: Create a GAMBannerView property
    var bannerView : GAMBannerView!
// Step 7: Create a HyBidAdRequest property
    var bannerAdRequest =  HyBidAdRequest()
    let adUnitID = "/6499/example/banner"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "GAM Header Bidding Banner"
// Step 3: Initialize the GAMBannerView property
        bannerView = GAMBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = self
// Step 4: Set GADBannerViewDelegate delegate
        bannerView.delegate = self
        bannerAdContainer.addSubview(bannerView)
    }

    @IBAction func loadAdTouchUpInside(_ sender: UIButton) {
        activityIndicator.startAnimating()
        bannerAdContainer.isHidden = true
// Step 8: Initialize the HyBidAdRequest property with a HyBidAdSize and request a HyBidAd
        bannerAdRequest.adSize = HyBidAdSize.size_320x50
        bannerAdRequest.requestAd(with: self, withZoneID: "2")
    }
}

// Step 5: Implement the GADBannerViewDelegate methods
extension Banner : GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerAdContainer.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        activityIndicator.stopAnimating()
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
    }
}

// Step 9: Implement the HyBidAdRequestDelegate methods
extension Banner : HyBidAdRequestDelegate {
    func requestDidStart(_ request: HyBidAdRequest!) {
        print("Request\(String(describing: request)) started")
    }

    func request(_ request: HyBidAdRequest!, didLoadWith ad: HyBidAd!) {
        print("Request loaded with ad: \(String(describing: ad))")
        if (request == self.bannerAdRequest) {
            // Step 10: Request a Google Mobile ad with some parameters as keywords
            let request = GAMRequest()
            request.customTargeting = (HyBidHeaderBiddingUtils.createHeaderBiddingKeywordsDictionary(with: ad) as! [String : String])
            bannerView.load(request)
        }
    }

    func request(_ request: HyBidAdRequest!, didFailWithError error: Error!) {
        print("Request\(String(describing: request)) failed with error: \(error.localizedDescription)")
        bannerView.load(GAMRequest())
    }
}
