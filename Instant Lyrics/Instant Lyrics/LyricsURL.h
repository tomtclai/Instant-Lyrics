//
//  LyricsURL.h
//  Instant Lyrics
//
//  Created by Tom Lai on 6/25/15.
//  Copyright © 2015 Tom. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface LyricsURL : NSObject
NS_ASSUME_NONNULL_BEGIN
@property (strong, nonatomic) NSString* artistTitle;
@property (strong, nonatomic) NSURL* url;
NS_ASSUME_NONNULL_END

- (nullable instancetype) initWithUrl:(nonnull NSURL *)url
                          artistTitle:(nonnull NSString *) at;
@end