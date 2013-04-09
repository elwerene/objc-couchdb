//
//  Update.m
//  objc-couchdb
//
//  Created by René Rössler on 09.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "objc_couchdb.h"

@implementation Update

-(id)initWithDesign:(Design*)design name:(NSString*)name {
    self = [super init];
    if (self) {
        _design = design;
        _name = name;
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<Update: design=%@ name=%@>",self.design,self.name];
}

#pragma mark - operations

-(void)updateDocument:(Document*)document withProperties:(NSDictionary*)properties finishedBlock:(DeleteDocumentFinishedBlock)finishedBlock errorBlock:(DeleteDocumentErrorBlock)errorBlock {
    //TODO
}

@end
