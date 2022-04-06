#import "MRectViewController.h"
// Step 6: Import HyBid into your class
#import <HyBid/HyBid.h>

#define MRECT_AD_UNIT_ID @"/6499/example/banner"

// Step 1: Import Google Mobile Ads into your class
@import GoogleMobileAds;

@interface MRectViewController () <HyBidAdRequestDelegate, GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *mRectAdContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
// Step 2: Create a GAMBannerView property
@property (nonatomic, strong) GAMBannerView *mRectView;
// Step 7: Create a HyBidAdRequest property
@property (nonatomic, strong) HyBidAdRequest *mRectAdRequest;

@end

@implementation MRectViewController

- (void)dealloc {
    self.mRectView = nil;
    self.mRectAdRequest = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"GAM Header Bidding MRect";
// Step 3: Initialize the GAMBannerView property
    self.mRectView = [[GAMBannerView alloc] initWithAdSize:GADAdSizeMediumRectangle];
    self.mRectView.adUnitID = MRECT_AD_UNIT_ID;
    self.mRectView.rootViewController = self;
// Step 4: Set GADBannerViewDelegate delegate
    self.mRectView.delegate = self;
    [self.mRectAdContainer addSubview:self.mRectView];
}

- (IBAction)loadAdTouchUpInside:(id)sender {
    [self.activityIndicator startAnimating];
    self.mRectAdContainer.hidden = YES;
// Step 8: Initialize the HyBidAdRequest property with a HyBidAdSize and request a HyBidAd
    self.mRectAdRequest = [[HyBidAdRequest alloc] init];
    self.mRectAdRequest.adSize = HyBidAdSize.SIZE_300x250;
    [self.mRectAdRequest requestAdWithDelegate:self withZoneID:@"3"];
}

// Step 5: Implement the GADBannerViewDelegate methods
#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    self.mRectAdContainer.hidden = NO;
    [self.activityIndicator stopAnimating];
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];
}

-(void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
}

// Step 9: Implement the HyBidAdRequestDelegate methods
#pragma mark - HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    NSLog(@"Request %@ started:",request);
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    NSLog(@"Request loaded with ad: %@",ad);
    if (request == self.mRectAdRequest) {
        // Step 10: Request a Google Mobile ad with some parameters as keywords
        GAMRequest *request = [GAMRequest request];
        request.customTargeting = [HyBidHeaderBiddingUtils createHeaderBiddingKeywordsDictionaryWithAd:ad];
        [self.mRectView loadRequest:request];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    [self.mRectView loadRequest:[GAMRequest request]];
}

@end
