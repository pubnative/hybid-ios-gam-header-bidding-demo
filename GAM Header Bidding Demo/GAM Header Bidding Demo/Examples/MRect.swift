import UIKit
// Step 1: Import Google Mobile Ads into your class
import GoogleMobileAds
// Step 6: Import HyBid into your class
import HyBid

class MRect: UIViewController {

    @IBOutlet weak var mRectAdContainer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

// Step 2: Create a GAMBannerView property
    var mRectView : GAMBannerView!
// Step 7: Create a HyBidAdRequest property
    var mRectAdRequest =  HyBidAdRequest()
    let adUnitID = "/6499/example/banner"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "GAM Header Bidding MRect"
// Step 3: Initialize the GAMBannerView property
        mRectView = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        mRectView.adUnitID = adUnitID
        mRectView.rootViewController = self
// Step 4: Set GADBannerViewDelegate delegate
        mRectView.delegate = self
        mRectAdContainer.addSubview(mRectView)
    }

    @IBAction func loadAdTouchUpInside(_ sender: UIButton) {
        activityIndicator.startAnimating()
        mRectAdContainer.isHidden = true
// Step 8: Initialize the HyBidAdRequest property with a HyBidAdSize and request a HyBidAd
        mRectAdRequest.adSize = HyBidAdSize.size_300x250
        mRectAdRequest.requestAd(with: self, withZoneID: "3")
    }
}

// Step 5: Implement the GADBannerViewDelegate methods
extension MRect : GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        mRectAdContainer.isHidden = false
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
extension MRect : HyBidAdRequestDelegate {
    func requestDidStart(_ request: HyBidAdRequest!) {
        print("Request\(String(describing: request)) started")
    }

    func request(_ request: HyBidAdRequest!, didLoadWith ad: HyBidAd!) {
        print("Request loaded with ad: \(String(describing: ad))")
        if (request == self.mRectAdRequest) {
            // Step 10: Request a Google Mobile ad with some parameters as keywords
            let request = GAMRequest()
            request.customTargeting = (HyBidHeaderBiddingUtils.createHeaderBiddingKeywordsDictionary(with: ad) as! [String : String])
            mRectView.load(request)
        }
    }

    func request(_ request: HyBidAdRequest!, didFailWithError error: Error!) {
        print("Request\(String(describing: request)) failed with error: \(error.localizedDescription)")
        mRectView.load(GAMRequest())
    }
}
