//
//  LyricsURL.h
//  Instant Lyrics
//
//  Created by Tom Lai on 6/25/15.
//  Copyright © 2015 Tom. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ILURLEntry : NSObject
NS_ASSUME_NONNULL_BEGIN
@property (strong, nonatomic) NSString* artistTitle;
@property (readonly) NSURL* originUrl;
@property (strong, nonatomic) NSURL* destUrl;
NS_ASSUME_NONNULL_END

- (nullable instancetype) initWithUrl:(nonnull NSURL *)url
                          artistTitle:(nonnull NSString *) at;
@end
