//
//  ChangeListener.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ChangesListener.h"
#import "Database.h"
#import "Change.h"
#import "Filter.h"
#import "Design.h"
#import <MKNetworkKit/MKNetworkEngine.h>

@interface ChangesListener ()
@property (nonatomic) NSMutableSet* delegates;
@property (nonatomic) ChangesOutputStream* stream;
@property (nonatomic) MKNetworkOperation* operation;
@end

@implementation ChangesListener

-(id)initWithDatabase:(Database*)database filter:(Filter*)filter {
    self = [super init];
    if (self) {
        _database = database;
        _filter = filter;
        _delegates = [NSMutableSet set];
        _stream = [[ChangesOutputStream alloc] initWithDelegate:self];
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
    MKNetworkOperation* getSeq = [self.database operationWithPath:@"" params:nil httpMethod:@"GET"];
    [getSeq addCompletionHandler:^(MKNetworkOperation* completedOperation) {
        NSDictionary* response = [completedOperation responseJSON];
        NSNumber* updateSeq = [response objectForKey:@"update_seq"];
        
        NSMutableDictionary* params = [@{@"feed":@"continuous",@"heartbeat":@10000,@"since":updateSeq} mutableCopy];
        if (self.filter != nil) {
            [params setObject:[NSString stringWithFormat:@"%@/%@",self.filter.design.identifier,self.filter.name] forKey:@"filter"];
        }
        
        self.operation = [self.database operationWithPath:@"_changes" params:params httpMethod:@"GET"];
        [self.operation addHeaders:@{@"Accept":@"application/json"}]; //Fixes NSUrlConnection bug as couchdb returns with mimetype application/json
        [self.operation addDownloadStream:self.stream];
        [self.operation addCompletionHandler:^(MKNetworkOperation* completedOperation) {
            //TODO
            NSLog(@"Completion");
        } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error) {
            //TODO
            NSLog(@"Error: %@", error);
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self start];
        });
    } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error) {
        //TODO
        NSLog(@"Error: %@", error);
    }];
    
    [self.database.engine enqueueOperation:getSeq];
}

-(void)start {
    [self.operation start];
}

-(void)stop {
    [self.operation cancel];
}

-(void)newChange:(NSDictionary*)changeDict {
    Change* change = [[Change alloc] initWithData:changeDict];
    
    for (NSObject<ChangesDelegate>* delegate in self.delegates) {
        [delegate newChange:change];
    }
}

@end
