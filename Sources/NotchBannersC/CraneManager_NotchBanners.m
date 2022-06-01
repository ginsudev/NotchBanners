//
//  CraneManager_NotchBanners.m
//  
//
//  Created by Noah Little on 3/4/2022.
//

#import <Foundation/Foundation.h>
#import "include/libCrane.h"

#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation CraneManager_NotchBanners

+ (instancetype)sharedManager {
    return [NSClassFromString(@"CraneManager") sharedManager];
}

@end
