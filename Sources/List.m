//
//  List.m
//  objc-couchdb
//
//  Created by René Rössler on 09.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC_CouchDB.h"
#import <CocoaLumberjack/DDLog.h>
extern int ddLogLevel;

@implementation List

-(id)initWithDesign:(Design*)design name:(NSString*)name {
    self = [super init];
    if (self) {
        _design = design;
        _name = name;
        _view = nil;
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<List: design=%@ name=%@ view=%@>",self.design,self.name,self.view];
}

-(void)queryWithFinishedBlock:(ListQueryFinishedBlock)finishedBlock errorBlock:(ListQueryErrorBlock)errorBlock {
    DDLogVerbose(@"[List] Querying list:%@ with view:%@", self.name, self.view);
    
    if (self.view == nil) {
        NSError* error = [NSError errorWithDomain:@"UsageError" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Can't query list without view."}];
        DDLogError(@"[List] Error:%@ querying list:%@ with view:%@", error.localizedDescription, self.name, self.view);
        if (errorBlock) {
            errorBlock(error);
        }
        if (self.design.database.globalErrorBlock) {
            self.design.database.globalErrorBlock(error);
        }
        return;
    }
    if (self.view.design != self.design) {
        NSError* error = [NSError errorWithDomain:@"UsageError" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Can't query list with view of another design document."}];
        DDLogError(@"[List] Error:%@ querying list:%@ with view:%@", error.localizedDescription, self.name, self.view);
        if (errorBlock) {
            errorBlock(error);
        }
        if (self.design.database.globalErrorBlock) {
            self.design.database.globalErrorBlock(error);
        }
        return;
    }
    
    [self.design.database getPath:[NSString stringWithFormat:@"%@/_list/%@/%@",self.design.identifier,self.name,self.view.name]
                           params:self.view.options
                    progressBlock:nil
                    finishedBlock:^(MKNetworkOperation* completedOperation) {
                        DDLogVerbose(@"[List] Done querying list:%@ with view:%@", self.name, self.view);
                        
                        if (finishedBlock) {
                            finishedBlock(completedOperation);
                        }
                    }
                       errorBlock:^(NSError* error) {
                           DDLogError(@"[List] Error:%@ querying list:%@ with view:%@", error.localizedDescription, self.name, self.view);
                           if (errorBlock) {
                               errorBlock(error);
                           }
                           if (self.design.database.globalErrorBlock) {
                               self.design.database.globalErrorBlock(error);
                           }
                       }
                       jsonParams:YES
     ];
}

@end
