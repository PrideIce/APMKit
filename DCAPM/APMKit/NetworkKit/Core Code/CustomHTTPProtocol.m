/*
     File: CustomHTTPProtocol.m
 Abstract: An NSURLProtocol subclass that overrides the built-in HTTP/HTTPS protocol.
  Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "CustomHTTPProtocol.h"

#import "CanonicalRequest.h"
#import "CacheStoragePolicy.h"
#import "QNSURLSessionDemux.h"
#import "APMURLSessionConfiguration.h"
#import "NetworkModel.h"
#import "NSData+GZIP.h"

// I use the following typedef to keep myself sane in the face of the wacky 
// Objective-C block syntax.

typedef void (^ChallengeCompletionHandler)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * credential);

@interface CustomHTTPProtocol () <NSURLSessionDataDelegate>

@property (atomic, strong, readwrite) NSThread *                        clientThread;       ///< The thread on which we should call the client.

/*! The run loop modes in which to call the client.
 *  \details The concurrency control here is complex.  It's set up on the client 
 *  thread in -startLoading and then never modified.  It is, however, read by code 
 *  running on other threads (specifically the main thread), so we deallocate it in 
 *  -dealloc rather than in -stopLoading.  We can be sure that it's not read before 
 *  it's set up because the main thread code that reads it can only be called after 
 *  -startLoading has started the connection running.
 */

@property (atomic, copy,   readwrite) NSArray *                         modes;
@property (atomic, assign, readwrite) NSTimeInterval                    startTime;          ///< The start time of the request; written by client thread only; read by any thread.
@property (atomic, strong, readwrite) NSURLSessionDataTask *            task;               ///< The NSURLSession task for that request; client thread only.
@property (atomic, strong, readwrite) NSURLAuthenticationChallenge *    pendingChallenge;
@property (atomic, copy,   readwrite) ChallengeCompletionHandler        pendingChallengeCompletionHandler;  ///< The completion handler that matches pendingChallenge; main thread only.

@property (nonatomic, strong) NSURLResponse *apm_response;
@property (nonatomic, strong) NSMutableData *apm_data;
@property (nonatomic, strong) NSError *apm_error;
@property (nonatomic, strong) NetworkModel *model;

@end

@implementation CustomHTTPProtocol

#pragma mark * Subclass specific additions

/*! The backing store for the class delegate.  This is protected by @synchronized on the class.
 */

static id<CustomHTTPProtocolDelegate> sDelegate;

+ (void)start
{
    [NSURLProtocol registerClass:[self class]];
    
    APMURLSessionConfiguration *sessionConfiguration = [APMURLSessionConfiguration defaultConfiguration];
    if (![sessionConfiguration isSwizzle]) {
        [sessionConfiguration load];
    }
}

+ (void)stop
{
    [NSURLProtocol unregisterClass:[self class]];
    
    APMURLSessionConfiguration *sessionConfiguration = [APMURLSessionConfiguration defaultConfiguration];
    if ([sessionConfiguration isSwizzle]) {
        [sessionConfiguration unload];
    }
}

+ (id<CustomHTTPProtocolDelegate>)delegate
{
    id<CustomHTTPProtocolDelegate> result;

    @synchronized (self) {
        result = sDelegate;
    }
    return result;
}

+ (void)setDelegate:(id<CustomHTTPProtocolDelegate>)newValue
{
    @synchronized (self) {
        sDelegate = newValue;
    }
}

/*! Returns the session demux object used by all the protocol instances.
 *  \details This object allows us to have a single NSURLSession, with a session delegate, 
 *  and have its delegate callbacks routed to the correct protocol instance on the correct 
 *  thread in the correct modes.  Can be called on any thread.
 */

+ (QNSURLSessionDemux *)sharedDemux
{
    static dispatch_once_t      sOnceToken;
    static QNSURLSessionDemux * sDemux;
    dispatch_once(&sOnceToken, ^{
        NSURLSessionConfiguration *     config;
        
        config = [NSURLSessionConfiguration defaultSessionConfiguration];
        // You have to explicitly configure the session to use your own protocol subclass here 
        // otherwise you don't see redirects <rdar://problem/17384498>.
        config.protocolClasses = @[ self ];
        sDemux = [[QNSURLSessionDemux alloc] initWithConfiguration:config];
    });
    return sDemux;
}

/*! Called by by both class code and instance code to log various bits of information. 
 *  Can be called on any thread.
 *  \param protocol The protocol instance; nil if it's the class doing the logging.
 *  \param format A standard NSString-style format string; will not be nil.
 */

+ (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol logWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3)
    // All internal logging calls this routine, which routes the log message to the 
    // delegate.
{
    // protocol may be nil
    id<CustomHTTPProtocolDelegate> strongDelegate;
    
    strongDelegate = [self delegate];
    if ([strongDelegate respondsToSelector:@selector(customHTTPProtocol:logWithFormat:arguments:)]) {
        va_list arguments;
        
        va_start(arguments, format);
        [strongDelegate customHTTPProtocol:protocol logWithFormat:format arguments:arguments];
        va_end(arguments);
    }
}

#pragma mark * NSURLProtocol overrides

/*! Used to mark our recursive requests so that we don't try to handle them (and thereby 
 *  suffer an infinite recursive death).
 */

//为了避免canInitWithRequest和canonicalRequestForRequest的死循环
static NSString *const kAPMRecursiveRequestFlagProperty = @"com.apm.network.APMHTTPProtocol";

/**
 需要控制的请求

 @param request 此次请求
 @return 是否需要监控
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    //如果是已经拦截过的  就放行
    if ([NSURLProtocol propertyForKey:kAPMRecursiveRequestFlagProperty inRequest:request]) {
        return NO;
    }
    if ([request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"]) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSURLRequest *      result;
    
//    assert(request != nil);
    // can be called on any thread
    
    // Canonicalising a request is quite complex, so all the heavy lifting has 
    // been shuffled off to a separate module.
    
    result = CanonicalRequestForRequest(request);

    [self customHTTPProtocol:nil logWithFormat:@"canonicalized %@ to %@", [request URL], [result URL]];
    
    return result;
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client
{
//    assert(request != nil);
//    // cachedResponse may be nil
//    assert(client != nil);
    // can be called on any thread

    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    if (self != nil) {
        // All we do here is log the call.
        [[self class] customHTTPProtocol:self logWithFormat:@"init for %@ from <%@ %p>", [request URL], [client class], client];
    }
    return self;
}

- (void)dealloc
{
    // can be called on any thread
    [[self class] customHTTPProtocol:self logWithFormat:@"dealloc"];
//    assert(self->_task == nil);                     // we should have cleared it by now
//    assert(self->_pendingChallenge == nil);         // we should have cancelled it by now
//    assert(self->_pendingChallengeCompletionHandler == nil);    // we should have cancelled it by now
}

- (void)startLoading
{
    NSMutableURLRequest *   recursiveRequest;
    NSMutableArray *        calculatedModes;
    NSString *              currentMode;

    // At this point we kick off the process of loading the URL via NSURLSession. 
    // The thread that calls this method becomes the client thread.
    
//    assert(self.clientThread == nil);           // you can't call -startLoading twice
//    assert(self.task == nil);

    // Calculate our effective run loop modes.  In some circumstances (yes I'm looking at 
    // you UIWebView!) we can be called from a non-standard thread which then runs a 
    // non-standard run loop mode waiting for the request to finish.  We detect this 
    // non-standard mode and add it to the list of run loop modes we use when scheduling 
    // our callbacks.  Exciting huh?
    //
    // For debugging purposes the non-standard mode is "WebCoreSynchronousLoaderRunLoopMode" 
    // but it's better not to hard-code that here.
    
//    assert(self.modes == nil);
    calculatedModes = [NSMutableArray array];
    [calculatedModes addObject:NSDefaultRunLoopMode];
    currentMode = [[NSRunLoop currentRunLoop] currentMode];
    if ( (currentMode != nil) && ! [currentMode isEqual:NSDefaultRunLoopMode] ) {
        [calculatedModes addObject:currentMode];
    }
    self.modes = calculatedModes;
//    assert([self.modes count] > 0);

    // Create new request that's a clone of the request we were initialised with, 
    // except that it has our 'recursive request flag' property set on it.
    
    recursiveRequest = [[self request] mutableCopy];
//    assert(recursiveRequest != nil);
    
    [[self class] setProperty:@YES forKey:kAPMRecursiveRequestFlagProperty inRequest:recursiveRequest];

    self.startTime = [NSDate timeIntervalSinceReferenceDate];
    if (currentMode == nil) {
        [[self class] customHTTPProtocol:self logWithFormat:@"start %@", [recursiveRequest URL]];
    } else {
        [[self class] customHTTPProtocol:self logWithFormat:@"start %@ (mode %@)", [recursiveRequest URL], currentMode];
    }
    
    // Latch the thread we were called on, primarily for debugging purposes.
    
    self.clientThread = [NSThread currentThread];
    
    // Once everything is ready to go, create a data task with the new request.

    self.task = [[[self class] sharedDemux] dataTaskWithRequest:recursiveRequest delegate:self modes:self.modes];
//    assert(self.task != nil);
    
#ifdef DEBUG
    NSLog(@"APMURL-start:%@", self.task.originalRequest.URL);
#endif
    
    self.model = [[NetworkModel alloc] init];
    self.model.request = self.request;
    self.model.startTime = [[NSDate date] timeIntervalSince1970];
    self.apm_data = [NSMutableData data];
    
    [self.task resume];
}

- (void)stopLoading
{
    // The implementation just cancels the current load (if it's still running).

    [[self class] customHTTPProtocol:self logWithFormat:@"stop (elapsed %.1f)", [NSDate timeIntervalSinceReferenceDate] - self.startTime];
    
//    assert(self.clientThread != nil);           // someone must have called -startLoading

    // Check that we're being stopped on the same thread that we were started 
    // on.  Without this invariant things are going to go badly (for example, 
    // run loop sources that got attached during -startLoading may not get 
    // detached here).
    //
    // I originally had code here to bounce over to the client thread but that 
    // actually gets complex when you consider run loop modes, so I've nixed it. 
    // Rather, I rely on our client calling us on the right thread, which is what 
    // the following assert is about.
    
//    assert([NSThread currentThread] == self.clientThread);
    
    [self cancelPendingChallenge];
    if (self.task != nil) {
#ifdef DEBUG
        NSLog(@"APMURL-end:%@", self.task.response.URL);
#endif
        self.model.url = self.request.URL.absoluteString;
        self.model.host = self.request.URL.host;
        self.model.endTime = [[NSDate date] timeIntervalSince1970];
        self.model.totalDuration = self.model.endTime - self.model.startTime;
        self.model.data = self.apm_data;
        self.model.response = (NSHTTPURLResponse *)self.task.response;
        self.model.statusCode = self.model.response.statusCode;
        self.model.requestDataLength = [self getRequestHeadersLengthWithCookie] + [self getRequestBodyLength];
        self.model.responseDataLength = [self getResponseHeadersLength] + [self getResponseBodyLength] + self.model.data.length;
        self.model.totalDataLength = self.model.requestDataLength + self.model.responseDataLength;
        //入库
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.model insertToDB];
        });
    
        [self.task cancel];
        self.task = nil;
        // The following ends up calling -URLSession:task:didCompleteWithError: with NSURLErrorDomain / NSURLErrorCancelled, 
        // which specificallys traps and ignores the error.
    }
    // Don't nil out self.modes; see property declaration comments for a a discussion of this.
}

#pragma mark * Authentication challenge handling

/*! Performs the block on the specified thread in one of specified modes.
 *  \param thread The thread to target; nil implies the main thread.
 *  \param modes The modes to target; nil or an empty array gets you the default run loop mode.
 *  \param block The block to run.
 */

- (void)performOnThread:(NSThread *)thread modes:(NSArray *)modes block:(dispatch_block_t)block
{
    // thread may be nil
    // modes may be nil
//    assert(block != nil);

    if (thread == nil) {
        thread = [NSThread mainThread];
    }
    if ([modes count] == 0) {
        modes = @[ NSDefaultRunLoopMode ];
    }
    [self performSelector:@selector(onThreadPerformBlock:) onThread:thread withObject:[block copy] waitUntilDone:NO modes:modes];
}

/*! A helper method used by -performOnThread:modes:block:. Runs in the specified context 
 *  and simply calls the block.
 *  \param block The block to run.
 */

- (void)onThreadPerformBlock:(dispatch_block_t)block
{
//    assert(block != nil);
    block();
}

/*! Called by our NSURLSession delegate callback to pass the challenge to our delegate.
 *  \description This simply passes the challenge over to the main thread.
 *  We do this so that all accesses to pendingChallenge are done from the main thread, 
 *  which avoids the need for extra synchronisation.
 *
 *  By the time this runes, the NSURLSession delegate callback has already confirmed with 
 *  the delegate that it wants the challenge.
 *  
 *  Note that we use the default run loop mode here, not the common modes.  We don't want 
 *  an authorisation dialog showing up on top of an active menu (-:
 *  
 *  Also, we implement our own 'perform block' infrastructure because Cocoa doesn't have 
 *  one <rdar://problem/17232344> and CFRunLoopPerformBlock is inadequate for the 
 *  return case (where we need to pass in an array of modes; CFRunLoopPerformBlock only takes 
 *  one mode).
 *  \param challenge The authentication challenge to process; must not be nil.
 *  \param completionHandler The associated completion handler; must not be nil.
 */

- (void)didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(ChallengeCompletionHandler)completionHandler
{
//    assert(challenge != nil);
//    assert(completionHandler != nil);
//    assert([NSThread currentThread] == self.clientThread);

    [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ received", [[challenge protectionSpace] authenticationMethod]];

    [self performOnThread:nil modes:nil block:^{
        [self mainThreadDidReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    }];
}

/*! The main thread side of authentication challenge processing.
 *  \details If there's already a pending challenge, something has gone wrong and 
 *  the routine simply cancels the new challenge.  If our delegate doesn't implement 
 *  the -customHTTPProtocol:canAuthenticateAgainstProtectionSpace: delegate callback, 
 *  we also cancel the challenge.  OTOH, if all goes well we simply call our delegate 
 *  with the challenge.
 *  \param challenge The authentication challenge to process; must not be nil.
 *  \param completionHandler The associated completion handler; must not be nil.
 */

- (void)mainThreadDidReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(ChallengeCompletionHandler)completionHandler
{
//    assert(challenge != nil);
//    assert(completionHandler != nil);
//    assert([NSThread isMainThread]);
    
    if (self.pendingChallenge != nil) {

        // Our delegate is not expecting a second authentication challenge before resolving the 
        // first.  Likewise, NSURLSession shouldn't send us a second authentication challenge 
        // before we resolve the first.  If this happens, assert, log, and cancel the challenge.
        //
        // Note that we have to cancel the challenge on the thread on which we received it, 
        // namely, the client thread.

        [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ cancelled; other challenge pending", [[challenge protectionSpace] authenticationMethod]];
//        assert(NO);
        [self clientThreadCancelAuthenticationChallenge:challenge completionHandler:completionHandler];
    } else {
        id<CustomHTTPProtocolDelegate>  strongDelegate;

        strongDelegate = [[self class] delegate];

        // Tell the delegate about it.  It would be weird if the delegate didn't support this 
        // selector (it did return YES from -customHTTPProtocol:canAuthenticateAgainstProtectionSpace: 
        // after all), but if it doesn't then we just cancel the challenge ourselves (or the client 
        // thread, of course).
        
        if ( ! [strongDelegate respondsToSelector:@selector(customHTTPProtocol:canAuthenticateAgainstProtectionSpace:)] ) {
            [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ cancelled; no delegate method", [[challenge protectionSpace] authenticationMethod]];
//            assert(NO);
            [self clientThreadCancelAuthenticationChallenge:challenge completionHandler:completionHandler];
        } else {

            // Remember that this challenge is in progress. 
            
            self.pendingChallenge = challenge;
            self.pendingChallengeCompletionHandler = completionHandler;

            // Pass the challenge to the delegate.
            
            [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ passed to delegate", [[challenge protectionSpace] authenticationMethod]];
            [strongDelegate customHTTPProtocol:self didReceiveAuthenticationChallenge:self.pendingChallenge];
        }
    }
}

/*! Cancels an authentication challenge that hasn't made it to the pending challenge state.
 *  \details This routine is called as part of various error cases in the challenge handling 
 *  code.  It cancels a challenge that, for some reason, we've failed to pass to our delegate.
 * 
 *  The routine is always called on the main thread but bounces over to the client thread to 
 *  do the actual cancellation.
 *  \param challenge The authentication challenge to cancel; must not be nil.
 *  \param completionHandler The associated completion handler; must not be nil.
 */

- (void)clientThreadCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(ChallengeCompletionHandler)completionHandler
{
//    #pragma unused(challenge)
//    assert(challenge != nil);
//    assert(completionHandler != nil);
//    assert([NSThread isMainThread]);

    [self performOnThread:self.clientThread modes:self.modes block:^{
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }];
}

/*! Cancels an authentication challenge that /has/ made to the pending challenge state.
 *  \details This routine is called by -stopLoading to cancel any challenge that might be 
 *  pending when the load is cancelled.  It's always called on the client thread but 
 *  immediately bounces over to the main thread (because .pendingChallenge is a main 
 *  thread only value).
 */

- (void)cancelPendingChallenge
{
//    assert([NSThread currentThread] == self.clientThread);

    // Just pass the work off to the main thread.  We do this so that all accesses 
    // to pendingChallenge are done from the main thread, which avoids the need for 
    // extra synchronisation.

    [self performOnThread:nil modes:nil block:^{
        if (self.pendingChallenge == nil) {
            // This is not only not unusual, it's actually very typical.  It happens every time you shut down 
            // the connection.  Ideally I'd like to not even call -mainThreadCancelPendingChallenge when 
            // there's no challenge outstanding, but the synchronisation issues are tricky.  Rather than solve 
            // those, I'm just not going to log in this case.
            //
            // [[self class] customHTTPProtocol:self logWithFormat:@"challenge not cancelled; no challenge pending"];
        } else {
            id<CustomHTTPProtocolDelegate>  strongeDelegate;
            NSURLAuthenticationChallenge *  challenge;

            strongeDelegate = [[self class] delegate];

            challenge = self.pendingChallenge;
            self.pendingChallenge = nil;
            self.pendingChallengeCompletionHandler = nil;
            
            if ([strongeDelegate respondsToSelector:@selector(customHTTPProtocol:didCancelAuthenticationChallenge:)]) {
                [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ cancellation passed to delegate", [[challenge protectionSpace] authenticationMethod]];
                [strongeDelegate customHTTPProtocol:self didCancelAuthenticationChallenge:challenge];
            } else {
                [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ cancellation failed; no delegate method", [[challenge protectionSpace] authenticationMethod]];
                // If we managed to send a challenge to the client but can't cancel it, that's bad. 
                // There's nothing we can do at this point except log the problem.
//                assert(NO);
            }
        }
    }];
}

- (void)resolveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge withCredential:(NSURLCredential *)credential
{
//    assert(challenge == self.pendingChallenge);
//    // credential may be nil
//    assert([NSThread isMainThread]);
//    assert(self.clientThread != nil);
    
    if (challenge != self.pendingChallenge) {
        [[self class] customHTTPProtocol:self logWithFormat:@"challenge resolution mismatch (%@ / %@)", challenge, self.pendingChallenge];
        // This should never happen, and we want to know if it does, at least in the debug build.
//        assert(NO);
    } else {
        ChallengeCompletionHandler  completionHandler;
        
        // We clear out our record of the pending challenge and then pass the real work 
        // over to the client thread (which ensures that the challenge is resolved on 
        // the same thread we received it on).
        
        completionHandler = self.pendingChallengeCompletionHandler;
        self.pendingChallenge = nil;
        self.pendingChallengeCompletionHandler = nil;
        
        [self performOnThread:self.clientThread modes:self.modes block:^{
            if (credential == nil) {
                [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ resolved without credential", [[challenge protectionSpace] authenticationMethod]];
                completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
            } else {
                [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ resolved with <%@ %p>", [[challenge protectionSpace] authenticationMethod], [credential class], credential];
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            }
        }];
    }
}

#pragma mark * NSURLSession delegate callbacks

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSMutableURLRequest *    redirectRequest;

//    #pragma unused(session)
//    #pragma unused(task)
//    assert(task == self.task);
//    assert(response != nil);
//    assert(newRequest != nil);
//    #pragma unused(completionHandler)
//    assert(completionHandler != nil);
//    assert([NSThread currentThread] == self.clientThread);
    
    [[self class] customHTTPProtocol:self logWithFormat:@"will redirect from %@ to %@", [response URL], [newRequest URL]];

    // The new request was copied from our old request, so it has our magic property.  We actually 
    // have to remove that so that, when the client starts the new request, we see it.  If we 
    // don't do this then we never see the new request and thus don't get a chance to change 
    // its caching behaviour.
    //
    // We also cancel our current connection because the client is going to start a new request for 
    // us anyway.

//    assert([[self class] propertyForKey:kAPMRecursiveRequestFlagProperty inRequest:newRequest] != nil);
    
    redirectRequest = [newRequest mutableCopy];
    [[self class] removePropertyForKey:kAPMRecursiveRequestFlagProperty inRequest:redirectRequest];
    
    // Tell the client about the redirect.
    
    [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
    
    // Stop our load.  The CFNetwork infrastructure will create a new NSURLProtocol instance to run 
    // the load of the redirect.
    
    // The following ends up calling -URLSession:task:didCompleteWithError: with NSURLErrorDomain / NSURLErrorCancelled, 
    // which specificallys traps and ignores the error.
    
    [self.task cancel];

    [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    BOOL        result;
    id<CustomHTTPProtocolDelegate> strongeDelegate;

//    #pragma unused(session)
//    #pragma unused(task)
//    assert(task == self.task);
//    assert(challenge != nil);
//    assert(completionHandler != nil);
//    assert([NSThread currentThread] == self.clientThread);

    // Ask our delegate whether it wants this challenge.  We do this from this thread, not the main thread, 
    // to avoid the overload of bouncing to the main thread for challenges that aren't going to be customised 
    // anyway.
    
    strongeDelegate = [[self class] delegate];
    
    result = NO;
    if ([strongeDelegate respondsToSelector:@selector(customHTTPProtocol:canAuthenticateAgainstProtectionSpace:)]) {
        result = [strongeDelegate customHTTPProtocol:self canAuthenticateAgainstProtectionSpace:[challenge protectionSpace]];
    }
    
    // If the client wants the challenge, kick off that process.  If not, resolve it by doing the default thing.

    if (result) {
        [[self class] customHTTPProtocol:self logWithFormat:@"can authenticate %@", [[challenge protectionSpace] authenticationMethod]];

        [self didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    } else {
        [[self class] customHTTPProtocol:self logWithFormat:@"cannot authenticate %@", [[challenge protectionSpace] authenticationMethod]];

        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSURLCacheStoragePolicy cacheStoragePolicy;
    NSInteger               statusCode;
    
//    #pragma unused(session)
//    #pragma unused(dataTask)
//    assert(dataTask == self.task);
//    assert(response != nil);
//    assert(completionHandler != nil);
//    assert([NSThread currentThread] == self.clientThread);

    // Pass the call on to our client.  The only tricky thing is that we have to decide on a 
    // cache storage policy, which is based on the actual request we issued, not the request 
    // we were given.

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        cacheStoragePolicy = CacheStoragePolicyForRequestAndResponse(self.task.originalRequest, (NSHTTPURLResponse *) response);
        statusCode = [((NSHTTPURLResponse *) response) statusCode];
    } else {
//        assert(NO);
        cacheStoragePolicy = NSURLCacheStorageNotAllowed;
        statusCode = 42;
    }

    [[self class] customHTTPProtocol:self logWithFormat:@"received response %zd / %@ with cache storage policy %zu", (ssize_t) statusCode, [response URL], (size_t) cacheStoragePolicy];
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:cacheStoragePolicy];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
//    #pragma unused(session)
//    #pragma unused(dataTask)
//    assert(dataTask == self.task);
//    assert(data != nil);
//    assert([NSThread currentThread] == self.clientThread);

    // Just pass the call on to our client.

    [[self class] customHTTPProtocol:self logWithFormat:@"received %zu bytes of data", (size_t) [data length]];

    [[self client] URLProtocol:self didLoadData:data];
    [self.apm_data appendData:data];
    #ifdef DEBUG
        NSLog(@"APMURL-data-didReceiveData:%@", self.task.originalRequest.URL);
    #endif
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *))completionHandler
{
//    #pragma unused(session)
//    #pragma unused(dataTask)
//    assert(dataTask == self.task);
//    assert(proposedResponse != nil);
//    assert(completionHandler != nil);
//    assert([NSThread currentThread] == self.clientThread);

    // We implement this delegate callback purely for the purposes of logging.
    
    [[self class] customHTTPProtocol:self logWithFormat:@"will cache response"];

    completionHandler(proposedResponse);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
    // An NSURLSession delegate callback.  We pass this on to the client.
{
//    #pragma unused(session)
//    #pragma unused(task)
//    assert( (self.task == nil) || (task == self.task) );        // can be nil in the 'cancel from -stopLoading' case
//    assert([NSThread currentThread] == self.clientThread);

    // Just log and then, in most cases, pass the call on to our client.

    if (error == nil) {
        [[self class] customHTTPProtocol:self logWithFormat:@"success"];

        [[self client] URLProtocolDidFinishLoading:self];
    } else if ( [[error domain] isEqual:NSURLErrorDomain] && ([error code] == NSURLErrorCancelled) ) {
        // Do nothing.  This happens in two cases:
        //
        // o during a redirect, in which case the redirect code has already told the client about 
        //   the failure
        // 
        // o if the request is cancelled by a call to -stopLoading, in which case the client doesn't 
        //   want to know about the failure
    } else {
        [[self class] customHTTPProtocol:self logWithFormat:@"error %@ / %d", [error domain], (int) [error code]];

        [[self client] URLProtocol:self didFailWithError:error];
    }

    // We don't need to clean up the connection here; the system will call, or has already called, 
    // -stopLoading to do that.
}

#pragma mark - 流量统计-Request

- (NSUInteger)getRequestHeadersLengthWithCookie
{
    NSUInteger headersLength = 0;

//    if (![self.request isKindOfClass:NSURLRequest.class] || ![self.request respondsToSelector:@selector(allHTTPHeaderFields)]) {
//        NSLog(@"Network type unsupport: %@", self.request);
//        return 0;
//    }
    NSDictionary<NSString *, NSString *> *headerFields = self.request.allHTTPHeaderFields;
    NSDictionary<NSString *, NSString *> *cookiesHeader = [self getCookies];

    // 添加 cookie 信息
    if (cookiesHeader.count) {
        NSMutableDictionary *headerFieldsWithCookies = [NSMutableDictionary dictionaryWithDictionary:headerFields];
        [headerFieldsWithCookies addEntriesFromDictionary:cookiesHeader];
        headerFields = [headerFieldsWithCookies copy];
    }

    NSString *headerStr = @"";

    for (NSString *key in headerFields.allKeys) {
        headerStr = [headerStr stringByAppendingString:key];
        headerStr = [headerStr stringByAppendingString:@": "];
        if ([headerFields objectForKey:key]) {
            headerStr = [headerStr stringByAppendingString:headerFields[key]];
        }
        headerStr = [headerStr stringByAppendingString:@"\n"];
    }
    NSData *headerData = [headerStr dataUsingEncoding:NSUTF8StringEncoding];
    headersLength = headerData.length;
    return headersLength;
}

- (NSDictionary<NSString *, NSString *> *)getCookies {
    NSDictionary<NSString *, NSString *> *cookiesHeader;
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray<NSHTTPCookie *> *cookies = [cookieStorage cookiesForURL:self.request.URL];
    if (cookies.count) {
        cookiesHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    }
    return cookiesHeader;
}

- (NSUInteger)getRequestBodyLength
{
    NSUInteger bodyLength = [self.request.HTTPBody length];

    NSData *bodyData;
    if (self.request.HTTPBody == nil) {
        uint8_t d[1024] = {0};
        NSInputStream *stream = self.request.HTTPBodyStream;
        NSMutableData *data = [[NSMutableData alloc] init];
        [stream open];
        while ([stream hasBytesAvailable]) {
            NSInteger len = [stream read:d maxLength:1024];
            if (len > 0 && stream.streamError == nil) {
                [data appendBytes:(void *)d length:len];
            }
        }
        bodyData = [data copy];
        [stream close];
    } else {
        bodyData = self.request.HTTPBody;
    }
    bodyLength = bodyData.length;

    return bodyLength;
}

#pragma mark - 流量统计-Response

- (NSUInteger)getResponseHeadersLength
{
    NSUInteger headersLength = 0;
    NSDictionary<NSString *, NSString *> *headerFields = self.model.response.allHeaderFields;
    NSString *headerStr = @"";

    for (NSString *key in headerFields.allKeys) {
        headerStr = [headerStr stringByAppendingString:key];
        headerStr = [headerStr stringByAppendingString:@": "];
        if ([headerFields objectForKey:key]) {
            headerStr = [headerStr stringByAppendingString:headerFields[key]];
        }
        headerStr = [headerStr stringByAppendingString:@"\n"];
    }
    NSData *headerData = [headerStr dataUsingEncoding:NSUTF8StringEncoding];
    headersLength = headerData.length;
    return headersLength;
}

- (NSUInteger)getResponseBodyLength
{
    NSDictionary<NSString *, NSString *> *headerFields = self.model.response.allHeaderFields;
    NSUInteger bodyLength = [self.model.data length];

    if ([headerFields objectForKey:@"Content-Encoding"]) {
        NSData *gzippedData = [self.model.data gzippedData];
        bodyLength = [gzippedData length];
    }

    return bodyLength;
}

@end
