//
//  HERNicecastHelperAppDelegate.h
//  HERNicecastHelper
//
//  Created by Garrett on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@interface HERNicecastHelperAppDelegate : NSObject <NSApplicationDelegate> {
@private
	NSWindow *window;
	NSTextField *artistName;
	NSTextField *songTitle;
	NSTextField *warningLabel;
	NSButton *manualTitlesButton;
	NSButton *offHoursTitlesButton;
	NSButton *changeTitleButton;
	NSButton *placeholderCheckbox;
	
	NSTimer *offhoursTimer;
	BOOL manualButtonOn;
	BOOL offhoursButtonOn;
	BOOL usePlaceHolderFile;
	
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain) IBOutlet NSTextField *artistName;
@property (nonatomic, retain) IBOutlet NSTextField *songTitle;
@property (nonatomic, retain) IBOutlet NSTextField *warningLabel;
@property (nonatomic, retain) IBOutlet NSButton *manualTitlesButton;
@property (nonatomic, retain) IBOutlet NSButton *offHoursTitlesButton;
@property (nonatomic, retain) IBOutlet NSTimer *offhoursTimer;
@property (nonatomic, retain) IBOutlet NSButton *changeTitleButton;
@property (nonatomic, retain) IBOutlet NSButton *placeholderCheckbox;

-(IBAction)useManualTitlesButtonClicked:(id)sender;
-(IBAction)useOffHoursButtonClicked:(id)sender;
-(IBAction)submitButtonClicked:(id)sender;
-(IBAction)usePlaceholderFile:(id)sender;


-(void)writeToNowPlayingFile:(NSString*)artist withTitle:(NSString*)song;
-(void)clearNowPlayingFile;
-(void)createFileWithArtist:(NSString*)artist andSongTitle:(NSString*)song;
-(void)startStopBroadcast;
-(void)moveScripts;

-(void)writeUseOffHoursFile;
-(void)clearOffHoursFile;

-(void)cleariTunesFile;
-(void)writeiTunesFile;

-(void)clearFile:(NSString*)filename;
-(void)writeFile:(NSString*)filename;
@end