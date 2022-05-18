#import "InterstitialViewController.h"
// Step 3: Import HyBid into your class
#import <HyBid/HyBid.h>

#define INTERSTITIAL_AD_UNIT_ID @"/6499/example/interstitial"

// Step 1: Import Google Mobile Ads into your class
@import GoogleMobileAds;

@interface InterstitialViewController () <HyBidAdRequestDelegate, GADFullScreenContentDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
// Step 2: Create a GAMInterstitialAd property
@property (nonatomic, strong) GAMInterstitialAd *interstitialAd;
// Step 4: Create a HyBidAdRequest property
@property (nonatomic, strong) HyBidInterstitialAdRequest *interstitialAdRequest;

@end

@implementation InterstitialViewController

- (void)dealloc {
    self.interstitialAd = nil;
    self.interstitialAdRequest = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"GAM Header Bidding Interstitial";
}

- (IBAction)loadAdTouchUpInside:(id)sender {
    [self.activityIndicator startAnimating];
    self.showAdButton.hidden = YES;
// Step 5: Initialize the HyBidInterstitialAdRequest property and request a HyBidAd
    self.interstitialAdRequest = [[HyBidInterstitialAdRequest alloc] init];
    [self.interstitialAdRequest requestAdWithDelegate:self withZoneID:@"4"];
}

- (IBAction)showAdTouchUpInside:(UIButton *)sender {
// Step 10: Check canPresentFromRootViewController:error: method on GAMInterstitialAd to find out if it is ready to be shown
    if ([self.interstitialAd canPresentFromRootViewController:self error:nil]) {
        if (self.interstitialAd) {
            [self.interstitialAd presentFromRootViewController:self];
        } else {
            NSLog(@"Ad wasn't ready");
        }
    }
}

// Step 9: Implement the GADFullScreenContentDelegate methods
#pragma mark GADFullScreenContentDelegate

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    
}

- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];
}

- (void)adDidDismissFullScreenContent:(id)ad {
    self.showAdButton.hidden = YES;
}

// Step 6: Implement the HyBidAdRequestDelegate methods
#pragma mark - HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    NSLog(@"Request %@ started:",request);
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    NSLog(@"Request loaded with ad: %@",ad);
    if (request == self.interstitialAdRequest) {
        // Step 7: Request a Google Mobile ad with some parameters as keywords
        GAMRequest *request = [GAMRequest request];
        request.customTargeting = [HyBidHeaderBiddingUtils createHeaderBiddingKeywordsDictionaryWithAd:ad];
        [GAMInterstitialAd loadWithAdManagerAdUnitID:INTERSTITIAL_AD_UNIT_ID
                                             request:request
                                   completionHandler:^(GAMInterstitialAd *ad, NSError *error) {
            if (error) {
                NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
                [self.activityIndicator stopAnimating];
                return;
            }
            self.interstitialAd = ad;
            [self.activityIndicator stopAnimating];
            self.showAdButton.hidden = NO;
            // Step 8: Set GADFullScreenContentDelegate delegate
            self.interstitialAd.fullScreenContentDelegate = self;
        }];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    [GAMInterstitialAd loadWithAdManagerAdUnitID:INTERSTITIAL_AD_UNIT_ID
                                         request:[GAMRequest request]
                               completionHandler:^(GAMInterstitialAd *ad, NSError *error) {
        if (error) {
            NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
            [self.activityIndicator stopAnimating];
            return;
        }
        self.interstitialAd = ad;
        [self.activityIndicator stopAnimating];
        self.showAdButton.hidden = NO;
        self.interstitialAd.fullScreenContentDelegate = self;
    }];
}

@end
