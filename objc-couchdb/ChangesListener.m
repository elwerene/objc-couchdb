//
//  ChangeListener.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "objc_couchdb.h"

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
    [self.database
     getPath:@""
     params:nil
     progressBlock:nil
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         NSDictionary* response = [completedOperation responseJSON];
         self.seq = [response objectForKey:@"update_seq"];
         [self start];
     }
     errorBlock:^(NSError* error) {
         NSLog(@"Error: %@", error);
     }];
}

-(void)start {
    if (self.delegates.count == 0) return;
    
    NSMutableDictionary* params = [@{@"feed":@"continuous",@"heartbeat":@10000,@"since":self.seq} mutableCopy];
    if (self.filter != nil) {
        [params setObject:[NSString stringWithFormat:@"%@/%@",self.filter.design.identifier,self.filter.name] forKey:@"filter"];
    }
    
    self.operation = [self.database operationWithPath:@"_changes" params:params httpMethod:@"GET"];
    [self.operation addHeaders:@{@"Accept":@"application/json"}]; //Fixes NSUrlConnection bug as couchdb returns with mimetype application/json
    [self.operation addDownloadStream:self.stream];
    
    ChangesListener* weakSelf = self;
    [self.operation addCompletionHandler:^(MKNetworkOperation* completedOperation) {
        NSLog(@"Changes stream completed");
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf start];
        });
    } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error) {
        NSLog(@"Changes stream error: %@", error);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf start];
        });
    }];
    
    [self.operation start];
}

-(void)stop {
    [self.operation cancel];
}

-(void)newChange:(NSDictionary*)changeDict {
    self.seq = [changeDict objectForKey:@"seq"];
    Change* change = [[Change alloc] initWithData:changeDict];
    
    for (NSObject<ChangesDelegate>* delegate in self.delegates) {
        [delegate newChange:change];
    }
}

@end
