#import "BannerViewController.h"
// Step 6: Import HyBid into your class
#import <HyBid/HyBid.h>

#define BANNER_AD_UNIT_ID @"/6499/example/banner"

// Step 1: Import Google Mobile Ads into your class
@import GoogleMobileAds;

@interface BannerViewController () <HyBidAdRequestDelegate, GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bannerAdContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
// Step 2: Create a GAMBannerView property
@property (nonatomic, strong) GAMBannerView *bannerView;
// Step 7: Create a HyBidAdRequest property
@property (nonatomic, strong) HyBidAdRequest *bannerAdRequest;

@end

@implementation BannerViewController

- (void)dealloc {
    self.bannerView = nil;
    self.bannerAdRequest = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"GAM Header Bidding Banner";
// Step 3: Initialize the GAMBannerView property
    self.bannerView = [[GAMBannerView alloc] initWithAdSize:GADAdSizeBanner];
    self.bannerView.adUnitID = BANNER_AD_UNIT_ID;
    self.bannerView.rootViewController = self;
    // Step 4: Set GADBannerViewDelegate delegate
    self.bannerView.delegate = self;
    [self.bannerAdContainer addSubview:self.bannerView];
}

- (IBAction)loadAdTouchUpInside:(id)sender {
    [self.activityIndicator startAnimating];
    self.bannerAdContainer.hidden = YES;
// Step 8: Initialize the HyBidAdRequest property with a HyBidAdSize and request a HyBidAd
    self.bannerAdRequest = [[HyBidAdRequest alloc] init];
    self.bannerAdRequest.adSize = HyBidAdSize.SIZE_320x50;
    [self.bannerAdRequest requestAdWithDelegate:self withZoneID:@"2"];
}

// Step 5: Implement the GADBannerViewDelegate methods
#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    self.bannerAdContainer.hidden = NO;
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
    if (request == self.bannerAdRequest) {
        // Step 10: Request a Google Mobile ad with some parameters as keywords
        GAMRequest *request = [GAMRequest request];
        request.customTargeting = [HyBidHeaderBiddingUtils createHeaderBiddingKeywordsDictionaryWithAd:ad];
        [self.bannerView loadRequest:request];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    [self.bannerView loadRequest:[GAMRequest request]];
}

@end
