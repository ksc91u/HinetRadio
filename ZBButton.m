//
//  ZBButton.m
//  Radio
//
//  Created by zonble on 10/19/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "ZBButton.h"


@implementation ZBButton

- (void)drawRect:(NSRect)dirtyRect
{
	[[self image] drawInRect:[self bounds] fromRect:NSZeroRect operation: NSCompositeSourceOver fraction:1.0];
}

@synthesize image;
@synthesize alternateImage;

@end
