/**
 * Modified MIT License
 *
 * Copyright 2017 OneSignal
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * 1. The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * 2. All copies of substantial portions of the Software may only be used in connection
 * with services provided by OneSignal.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "OSInAppMessageView.h"
#import "OneSignalHelper.h"
#import <WebKit/WebKit.h>
#import "OSInAppMessageAction.h"

@interface OSInAppMessageView ()
@property (strong, nonatomic, nonnull) OSInAppMessage *message;
@property (strong, nonatomic, nonnull) WKWebView *webView;
@property (nonatomic) BOOL loaded;
@end

@implementation OSInAppMessageView

- (instancetype _Nonnull)initWithMessage:(OSInAppMessage *)inAppMessage withScriptMessageHandler:(id<WKScriptMessageHandler>)messageHandler {
    if (self = [super init]) {
        self.message = inAppMessage;
        self.translatesAutoresizingMaskIntoConstraints = false;
        [self setupWebviewWithMessageHandler:messageHandler];
        
        // TODO: This is here for debugging/testing purposes until the backend implementation is available
        switch (self.message.type) {
            case OSInAppMessageDisplayTypeTopBanner:
            case OSInAppMessageDisplayTypeBottomBanner:
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.hesse.io/banner.html"]]];
                break;
            case OSInAppMessageDisplayTypeFullScreen:
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.hesse.io/testmsg.html"]]];
                break;
            case OSInAppMessageDisplayTypeCenteredModal:
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.hesse.io/testmsg.html"]]];
                break;
        }
    }
    
    return self;
}

- (void)loadedHtmlContent:(NSString *)html withBaseURL:(NSURL *)url {
    [self.webView loadHTMLString:html baseURL:url];
}

- (void)setupWebviewWithMessageHandler:(id<WKScriptMessageHandler>)handler {
    let configuration = [WKWebViewConfiguration new];
    [configuration.userContentController addScriptMessageHandler:handler name:@"iosListener"];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
    self.webView.translatesAutoresizingMaskIntoConstraints = false;
    self.webView.scrollView.scrollEnabled = false;
    self.webView.navigationDelegate = self;
    
    [self addSubview:self.webView];
    
    if (@available(iOS 11, *))
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    [self.webView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = true;
    [self.webView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = true;
    [self.webView.topAnchor constraintEqualToAnchor:self.topAnchor].active = true;
    [self.webView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = true;
    
    [self layoutIfNeeded];
}

// NOTE: Make sure to call this method when the message view gets dismissed
// Otherwise a memory leak will occur and the entire view controller will be leaked
- (void)removeScriptMessageHandler {
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"iosListener"];
}

- (void)loadReplacementURL:(NSURL *)url {
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark WKWebViewNavigationDelegate Methods
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    //webview finished loading
    if (self.loaded)
        return;
    
    self.loaded = true;
    
    [self.delegate messageViewDidLoadMessageContent];
}

@end
