//
//  LyricsURLMap.h
//  Instant Lyrics
//
//  Created by Tom Lai on 6/25/15.
//  Copyright © 2015 Tom. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ILURLEntry;
@interface ILURLLog : NSObject <NSCoding>

- (NSURL *)URLForArtistTitle:(NSString *) at;
- (void)addURL:(NSURL *)url
        forArtistTitle:(NSString *) at;
- (ILURLEntry *)lastEntry;
+ (instancetype)sharedLog;
- (BOOL)saveChanges;
@end
