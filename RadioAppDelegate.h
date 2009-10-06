#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@interface RadioAppDelegate : NSWindowController
{
	IBOutlet NSPopUpButton *popupButton;
	IBOutlet NSButton *playButton;
	IBOutlet NSProgressIndicator *indicator;
	IBOutlet NSSlider *volumeSlider;
	
	BOOL isPlaying;
	BOOL isPreparing;
	
	NSString *currentPlayingChannelIdentifier;
	QTMovie *movie;
}

#pragma mark Interface Builder actions

- (IBAction)changeChannelAction:(id)sender;
- (IBAction)playAction:(id)sender;
- (IBAction)stopAction:(id)sender;
- (IBAction)changeVolumeAction:(id)sender;

- (NSString *)currentSelectedChannelIdentifier;
- (BOOL)isPlaying;

- (void)didLoad:(NSNotification *)notification;
- (void)didEnd:(NSNotification *)notification;


@end
