#import "RadioAppDelegate.h"

@implementation RadioAppDelegate

#pragma mark Routines

- (void) dealloc
{	
	[currentPlayingChannelIdentifier release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)setupMenu
{
	NSString *menuSettingFilePath = [[NSBundle mainBundle] pathForResource:@"menu" ofType:@"txt"];
	NSError *error;
	NSString *menuContent = [NSString stringWithContentsOfFile:menuSettingFilePath encoding:NSUTF8StringEncoding error:&error];
	NSArray *lines = [menuContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSEnumerator *e = [lines objectEnumerator];
	NSString *line = nil;
	NSMenu *menu = [[[NSMenu alloc] initWithTitle:@""] autorelease];
	[menu setAutoenablesItems:NO];
	while (line = [e nextObject]) {
		line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if (![line length]) {
			continue;
		}
		NSArray *a = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if ([a count]) {
			NSString *identifierString = [a lastObject];
			NSNumber *identifier = nil;
			NSString *name = nil;			
			if ([identifierString intValue]) {
				name = [line substringToIndex:[line length] - [identifierString length]];
				identifier = [NSNumber numberWithInt:[identifierString intValue]];
			}
			else {
				name = line;
			}
			NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:name action:NULL keyEquivalent:@""] autorelease];
			if (identifier)
				[item setRepresentedObject:identifier];
			else 
				[item setEnabled:NO];

			[menu addItem:item];
		}
	}
	
	[popupButton setMenu:menu];
	
	e = [[[popupButton menu] itemArray] objectEnumerator];
	NSMenuItem *item = nil;
	while (item = [e nextObject]) {
		if ([item isEnabled]) {
			[popupButton selectItem:item];
			break;
		}
	}

}

- (void)awakeFromNib
{
	[[self window] setDelegate:self];
	[indicator setHidden:YES];
	currentPlayingChannelIdentifier = nil;

	[self setupMenu];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnd:) name:QTMovieDidEndNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoad:) name:QTMovieLoadStateDidChangeNotification object:nil];	
}
- (NSString *)currentSelectedChannelIdentifier
{
	NSNumber *identifier = [[popupButton selectedItem] representedObject];
	if (!identifier) {
		return nil;
	}
	return [NSString stringWithFormat:@"%d", [identifier intValue]];	
}
- (BOOL)isPlaying
{
	return isPlaying;
}

#pragma mark Interface Builder actions

- (IBAction)changeChannelAction:(id)sender
{
	if (![self currentSelectedChannelIdentifier]) return;	
	if ([[self currentSelectedChannelIdentifier] isEqualToString:currentPlayingChannelIdentifier]) return;
	
	if (isPlaying || isPreparing) {
		[self stopAction:sender];
		[self playAction:sender];
	}
}
- (IBAction)playAction:(id)sender
{
	[currentPlayingChannelIdentifier release];
	currentPlayingChannelIdentifier = nil;
	
	NSError *error;
	NSString *currentSelectedChannelIdentifier = [self currentSelectedChannelIdentifier];
	if (!currentSelectedChannelIdentifier) {
		return;
	}	
	NSString *URLString = [NSString stringWithFormat:@"http://hichannel.hinet.net/player/radio/index.jsp?radio_id=%@", currentSelectedChannelIdentifier];
	NSURL *URL = [NSURL URLWithString:URLString];
	if (!URL) { return; }
	NSString *HTML = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];
	if (!HTML || ![HTML length]) { return; }
	NSRange beforeRange = [HTML rangeOfString:@"mms://"];
	if (beforeRange.location == NSNotFound) { return; }
	HTML = [HTML substringFromIndex:beforeRange.location];
	NSRange afterRange = [HTML rangeOfString:@"&id=RADIO"];
	if (afterRange.location == NSNotFound) { return; }	
	HTML = [HTML substringToIndex:afterRange.location];
	if ([HTML length] < 6) { return; }
	NSString *mmsURLString = [NSString stringWithFormat:@"http%@", [HTML substringFromIndex:3]];
	NSLog(@"mmsURLString:%@", mmsURLString);
	movie = [[QTMovie alloc] initWithURL:[NSURL URLWithString:mmsURLString] error:&error];
	if (error) {
		NSLog(@"Error");
		NSLog(@"%@", [error localizedDescription]);
		return;
	}
	isPreparing = YES;
	[playButton setTitle:NSLocalizedString(@"Stop", @"")];
	[playButton setAction:@selector(stopAction:)];

	currentPlayingChannelIdentifier = [currentSelectedChannelIdentifier retain];
	[indicator setHidden:NO];
	[indicator startAnimation:self];
	[movie autoplay];
}
- (IBAction)stopAction:(id)sender
{
	if (movie) {
		[movie stop];
		[movie release];
		movie = nil;
	}
	isPlaying = NO;
	
	[indicator setHidden:YES];
	[indicator stopAnimation:self];
	[playButton setTitle:NSLocalizedString(@"Play", @"")];
	[playButton setAction:@selector(playAction:)];
}
- (IBAction)changeVolumeAction:(id)sender
{
	if (movie) { [movie setVolume:[volumeSlider doubleValue]]; }
}

#pragma mark QTMovie notification handlers

- (void)didLoad:(NSNotification *)notification
{
	id object = [notification object];
	[(QTMovie *)object setVolume:[volumeSlider doubleValue]];
	
	[playButton setTitle:NSLocalizedString(@"Stop", @"")];
	[playButton setAction:@selector(stopAction:)];
	
	[indicator setHidden:YES];
	[indicator stopAnimation:self];

	isPreparing = NO;
	isPlaying = YES;
}
- (void)didEnd:(NSNotification *)notification
{
	[playButton setTitle:NSLocalizedString(@"Play", @"")];
	[playButton setAction:@selector(playAction:)];

	[indicator setHidden:YES];
	[indicator stopAnimation:self];
	
	isPlaying = NO;
}

- (void)windowWillClose:(NSNotification *)notification
{
	[NSApp terminate:self];
}

@end