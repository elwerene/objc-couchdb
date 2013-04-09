//
//  View.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "objc_couchdb.h"

@implementation View

-(id)initWithDesign:(Design*)design name:(NSString*)name {
    self = [super init];
    if (self) {
        _design = design;
        _name = name;
        _options = nil;
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<View: design=%@ name=%@>",self.design,self.name];
}

#pragma mark - operations

-(void)queryWithFinishedBlock:(ViewQueryFinishedBlock)finishedBlock errorBlock:(ViewQueryErrorBlock)errorBlock {
    [self.design.database getPath:[NSString stringWithFormat:@"%@/_view/%@",self.design.identifier,self.name]
                           params:self.options
                    progressBlock:nil
                    finishedBlock:^(MKNetworkOperation* completedOperation) {
                        if (finishedBlock) {
                            ViewResult* result = [[ViewResult alloc] initWithView:self properties:completedOperation.responseJSON];
                            finishedBlock(result);
                        }
                    }
                       errorBlock:^(NSError* error) {
                           if (errorBlock) {
                               errorBlock(error);
                           } else if (self.design.database.globalErrorBlock) {
                               self.design.database.globalErrorBlock(error);
                           }
                       }
     ];
}

@end
