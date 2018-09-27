#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AMPARCMacros.h"
#import "AMPConstants.h"
#import "AMPDatabaseHelper.h"
#import "AMPDeviceInfo.h"
#import "AMPIdentify.h"
#import "Amplitude+SSLPinning.h"
#import "Amplitude.h"
#import "AMPLocationManagerDelegate.h"
#import "AMPRevenue.h"
#import "AMPTrackingOptions.h"
#import "AMPURLConnection.h"
#import "AMPURLSession.h"
#import "AMPUtils.h"
#import "ISPCertificatePinning.h"
#import "ISPPinnedNSURLConnectionDelegate.h"
#import "ISPPinnedNSURLSessionDelegate.h"

FOUNDATION_EXPORT double Amplitude_iOSVersionNumber;
FOUNDATION_EXPORT const unsigned char Amplitude_iOSVersionString[];

