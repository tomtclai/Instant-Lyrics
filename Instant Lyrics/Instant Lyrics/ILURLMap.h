//
//  LyricsURLMap.h
//  Instant Lyrics
//
//  Created by Tom Lai on 6/25/15.
//  Copyright © 2015 Tom. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LyricsURL;
@interface ILURLMap : NSObject

- (NSURL *)URLForArtistTitle:(NSString *) at;
- (void)addURL:(NSURL *)url
        forArtistTitle:(NSString *) at;
- (LyricsURL *)lastEntry;
@end
