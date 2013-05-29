//
//  Update.m
//  objc-couchdb
//
//  Created by René Rössler on 09.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC-CouchDB.h"
#import <CocoaLumberjack/DDLog.h>
extern int ddLogLevel;

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

-(void)updateDocument:(Document*)document withProperties:(NSDictionary*)properties finishedBlock:(UpdateDocumentFinishedBlock)finishedBlock errorBlock:(UpdateDocumentErrorBlock)errorBlock progressBlock:(UpdateDocumentProgressBlock)progressBlock {
    
    [self updateDocumentWithIdentifier:document.identifier withProperties:properties finishedBlock:finishedBlock errorBlock:errorBlock progressBlock:progressBlock];
}

-(void)updateDocumentWithIdentifier:(NSString*)identifier withProperties:(NSDictionary*)properties finishedBlock:(UpdateDocumentFinishedBlock)finishedBlock errorBlock:(UpdateDocumentErrorBlock)errorBlock progressBlock:(UpdateDocumentProgressBlock)progressBlock {
    DDLogVerbose(@"[Update] Updating document with identifier:%@ with update methode:%@ in design:%@", identifier, self.name, self.design);
    
    [self.design.database
     putPath:[NSString stringWithFormat:@"%@/_update/%@/%@",self.design.identifier,self.name,identifier]
     params:properties
     progressBlock:^(double progress) {
         if (progressBlock) {
             progressBlock(progress);
         }
     }
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         DDLogVerbose(@"[Update] Done updating document with identifier:%@ with update methode:%@ in design:%@", identifier, self.name, self.design);
         if (finishedBlock) {
             finishedBlock(completedOperation);
         }
     }
     errorBlock:^(NSError* error) {
         DDLogError(@"[Update] Error:%@ updating document with identifier:%@ with update methode:%@ in design:%@", error.localizedDescription, identifier, self.name, self.design);
         
         if (errorBlock) {
             errorBlock(error);
         }
         if (self.design.database.globalErrorBlock) {
             self.design.database.globalErrorBlock(error);
         }
     }
     jsonParams:NO];
}

@end
