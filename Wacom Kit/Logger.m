//
//  Rect.m
//  Wacom Kit
//
//  Created by khang on 2/4/23.
//

#import "Logger.h"

@implementation WLogger

- (id)init:(NSString *_Nonnull)inputPath {
  self = [super init];
  self->path = inputPath;
  return self;
}

- (void)start:(NSString *)text {
  text = [NSString stringWithFormat:@"%@\n", text];
  [text writeToFile:[self logFilePath] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

- (void)log:(NSString *)text {
  text = [NSString stringWithFormat:@"%@\n", text];
  NSFileHandle *fh = [self logFile];
  [fh seekToEndOfFile];
  [fh writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
  [fh closeFile];
}

- (void)log:(NSString *)title detail:(NSString *)detail {
  [self log:[NSString stringWithFormat:@"%@: %@", title, detail]];
}

- (void)log:(NSString *)text val:(int)val {
  [self log:[NSString stringWithFormat:@"%@: %d", text, val]];
}

- (void)log:(NSString *)text prev:(int)prev next:(int)next {
  [self log:[NSString stringWithFormat:@"%@: %d -> %d", text, prev, next]];
}

- (void)log:(NSString *)base t:(bool)t y:(NSString *)y n:(NSString *)n {
  [self log:[NSString stringWithFormat:@"%@ %@", base, t ? y : n]];
}

- (NSFileHandle *)logFile {
  return [NSFileHandle fileHandleForWritingAtPath:[self logFilePath]];
}

- (NSString *)logFilePath {
  NSArray *parts = [NSArray arrayWithObjects:NSHomeDirectory(), path, nil];
  return [NSString pathWithComponents:parts];
}

@end
