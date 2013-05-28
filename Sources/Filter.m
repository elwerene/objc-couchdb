//
//  Filter.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "objc_couchdb.h"

@implementation Filter

-(id)initWithDesign:(Design*)design name:(NSString*)name {
    self = [super init];
    if (self) {
        _design = design;
        _name = name;
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<Filter: design=%@ name=%@>",self.design,self.name];
}

@end
