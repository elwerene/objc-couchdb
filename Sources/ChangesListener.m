//
//  ChangeListener.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC-CouchDB.h"
#import <PathHelper/PathHelper.h>
#import <CocoaLumberjack/DDLog.h>
extern int ddLogLevel;

@interface ChangesListener ()
@property (nonatomic) NSMutableSet* delegates;
@property (nonatomic) ChangesOutputStream* stream;
@property (nonatomic) MKNetworkOperation* operation;
@property (nonatomic) NSNumber* seq;
@end

@implementation ChangesListener

-(id)initWithDatabase:(Database*)database filter:(Filter*)filter {
    self = [super init];
    if (self) {
        _database = database;
        _filter = filter;
        _delegates = [NSMutableSet set];
        _stream = [[ChangesOutputStream alloc] initWithDelegate:self];
        _seq = @0;
    }
    return self;
}

-(void)addDelegate:(NSObject<ChangesDelegate>*)delegate {
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
    
    if (self.delegates.count == 1) {
        [self getSeqAndStart];
    }
}

-(void)removeDelegate:(NSObject<ChangesDelegate>*)delegate {
    if ([self.delegates containsObject:delegate]) {
        [self.delegates removeObject:delegate];
    }
    
    if (self.delegates.count == 0) {
        [self stop];
    }
}

-(void)getSeqAndStart {
    DDLogVerbose(@"[ChangesListener] Loading current update_seq and start listening for changes. Filter:%@", self.filter);
    [self.database
     getPath:@""
     params:nil
     progressBlock:nil
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         NSDictionary* response = [completedOperation responseJSON];
         self.seq = [response getNumberWithPath:@"update_seq"];
         DDLogVerbose(@"[ChangesListener] Done loading current update_seq:%@. Starting listening for changes. Filter:%@", self.seq, self.filter);
         [self start];
     }
     errorBlock:^(NSError* error) {
         DDLogError(@"[ChangesListener] Error:%@ loading current update_seq and start listening for changes. Filter:%@", error.localizedDescription, self.filter);
         if (self.database.globalErrorBlock) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.database.globalErrorBlock(error);
             });
         }
     }
     jsonParams:NO];
}

-(void)start {
    if (self.delegates.count == 0) return;
    DDLogVerbose(@"[ChangesListener] Start listening for changes. Filter:%@", self.filter);
    
    NSMutableDictionary* params = [@{@"feed":@"continuous",@"heartbeat":@10000,@"since":self.seq} mutableCopy];
    if (self.filter != nil) {
        [params addEntriesFromDictionary:self.filter.options];
        [params setObject:[NSString stringWithFormat:@"%@/%@",[self.filter.design.identifier substringFromIndex:8],self.filter.name] forKey:@"filter"];
    }
    
    self.operation = [self.database operationWithPath:@"_changes" params:params httpMethod:@"GET" jsonParams:YES];
    [self.operation addHeaders:@{@"Accept":@"application/json"}]; //Fixes NSUrlConnection bug as couchdb returns with mimetype application/json
    [self.operation addDownloadStream:self.stream];
    
    ChangesListener* weakSelf = self;
    [self.operation addCompletionHandler:^(MKNetworkOperation* completedOperation) {
        if (weakSelf.database.globalErrorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.database.globalErrorBlock([NSError errorWithDomain:@"ChangesStreamError" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Changes stream completed."}]);
            });
        }
    } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf performSelector:@selector(start) withObject:nil afterDelay:0.1];
            if (weakSelf.database.globalErrorBlock) {
                weakSelf.database.globalErrorBlock(error);
            }
        });
    }];
    
    [self.operation start];
}

-(void)stop {
    DDLogVerbose(@"[ChangesListener] Stop listening for changes. Filter:%@", self.filter);

    [self.operation cancel];
}

-(void)newChange:(NSDictionary*)changeDict {
    self.seq = [changeDict getNumberWithPath:@"seq"];
    Change* change = [[Change alloc] initWithData:changeDict];
    
    DDLogVerbose(@"[ChangesListener] New change:%@. Filter:%@", change, self.filter);
    
    for (NSObject<ChangesDelegate>* delegate in self.delegates) {
        [delegate newChange:change];
    }
}

@end
