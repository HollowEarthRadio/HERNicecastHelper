//
//  HERNicecastHelperAppDelegate.m
//  HERNicecastHelper
//
//  Created by Garrett on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HERNicecastHelperAppDelegate.h"

@implementation HERNicecastHelperAppDelegate

@synthesize window;
@synthesize artistName;
@synthesize songTitle;
@synthesize warningLabel;
@synthesize manualTitlesButton;
@synthesize offHoursTitlesButton;
@synthesize offhoursTimer;
@synthesize killController;
@synthesize changeTitleButton;
@synthesize placeholderCheckbox;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[self moveScripts];
	[self.songTitle setTarget:self];
	[self.songTitle setAction:@selector(submitButtonClicked:)];
	usePlaceHolderFile = YES;
	[self.placeholderCheckbox setState:NSOnState];
}

-(void)moveScripts {
	
	NSString *icecast_shell_script = [[NSBundle mainBundle] pathForResource:@"icecaster" ofType:@"sh"];
	NSString *icecast_ruby_script = [[NSBundle mainBundle] pathForResource:@"icecast_title_ripper" ofType:@"rb"];
	
	NSError *error;
	[[NSFileManager defaultManager] copyItemAtPath:icecast_shell_script toPath:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/icecaster.sh", NSHomeDirectory()] error:&error ];
	[[NSFileManager defaultManager] copyItemAtPath:icecast_ruby_script toPath:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/icecast_title_ripper.rb", NSHomeDirectory()] error:&error ];

}

-(void)startStopBroadcast {
	NSDictionary *scriptError = [[NSDictionary alloc] init]; 
	
	/* Create the Applescript to run with the filename and comment string... */ 
	NSString *scriptSource = @"tell application \"NiceCast\" to stop broadcast";
	NSString *scriptSource2 = @"tell application \"NiceCast\" to start broadcast";
	
	NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:scriptSource]; 
	
	/* Run the script! */ 
	if(![appleScript executeAndReturnError:&scriptError]) 
		NSLog(@"%@",[scriptError description]); 
	
	NSAppleScript *appleScript2 = [[NSAppleScript alloc] initWithSource:scriptSource2]; 
	
	if(![appleScript2 executeAndReturnError:&scriptError]) 
		NSLog(@"%@",[scriptError description]); 
}

-(void) parseOffHoursTitles {
	if (self.killController == nil) {
		self.killController = [[KillController alloc] init];
	}
	
	[self.killController updateProcesses:nil];
}


-(IBAction)useOffHoursButtonClicked:(id)sender {
	NSLog(@"Off hours track titles button clicked");
	
	offhoursButtonOn = !offhoursButtonOn;
	
	if (offhoursButtonOn) {
		[self.offHoursTitlesButton setTitle:@"Switch Back To Using iTunes"];
		[self.artistName setEnabled:NO];
		[self.songTitle setEnabled:NO];
		[self.changeTitleButton setEnabled:NO];
		[self.manualTitlesButton setEnabled:NO];
		

		NSDictionary *scriptError = [[NSDictionary alloc] init]; 
		
		/* Create the Applescript to run with the filename and comment string... */ 
		NSString *playOffHours = @"tell application \"iTunes\" to play track 1 of user playlist \"off hours\"";
		NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:playOffHours]; 
		
		/* Run the script! */ 
		if(![appleScript executeAndReturnError:&scriptError]) 
			NSLog(@"%@",[scriptError description]); 

		
		[self parseOffHoursTitles];
		[self writeToNowPlayingFile:[self.artistName stringValue] withTitle:[self.songTitle stringValue]];
		[self startStopBroadcast];
	}
	else {
		[self.offHoursTitlesButton setTitle:@"Switch To Off Hours"];
		[self.killController	killProcess:nil];
		[self.manualTitlesButton setEnabled:YES];
		[self.artistName setEnabled:YES];
		[self.songTitle setEnabled:YES];
		[self.changeTitleButton setEnabled:YES];
		
		[self clearNowPlayingFile];
		[self startStopBroadcast];
	}
}

-(IBAction)useManualTitlesButtonClicked:(id)sender {
	NSLog(@"Manual track titles button clicked");

	manualButtonOn = !manualButtonOn;
	
	if (manualButtonOn) {
		[self.offHoursTitlesButton setEnabled:NO];
		[self.manualTitlesButton setTitle:@"Switch Back To Using iTunes"];
		[self writeToNowPlayingFile:[self.artistName stringValue] withTitle:[self.songTitle stringValue]];
		[self startStopBroadcast];
		
		if (usePlaceHolderFile) {
			NSDictionary *scriptError = [[NSDictionary alloc] init]; 
			
			/* Create the Applescript to run with the filename and comment string... */ 
			NSString *playPlaceholder = @"tell application \"iTunes\" to play track 1 of user playlist \"placeholder\"";
			NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:playPlaceholder]; 
			
			/* Run the script! */ 
			if(![appleScript executeAndReturnError:&scriptError]) 
				NSLog(@"%@",[scriptError description]); 
		}
	}
	else {
		[self.offHoursTitlesButton setEnabled:YES];
		[self.manualTitlesButton setTitle:@"Start Using My Own Titles"];
		[self clearNowPlayingFile];
		[self startStopBroadcast];
	}
}

-(IBAction)submitButtonClicked:(id)sender {
	NSLog(@"Submit button clicked");
	[self writeToNowPlayingFile:[self.artistName stringValue] withTitle:[self.songTitle stringValue]];
}

-(void)createFileWithArtist:(NSString*)artist andSongTitle:(NSString*)song {
	NSString *string = [NSString stringWithFormat:@"Title: %@\nArtist: %@", song, artist];
	NSError *error;
	BOOL ok = [string writeToFile:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/NowPlaying.txt",NSHomeDirectory()] atomically:YES
						 encoding:NSUnicodeStringEncoding error:&error];
	if (!ok) {
		// an error occurred
		NSLog(@"Error writing file at %@\n%@",
              [NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/NowPlaying.txt",NSHomeDirectory()], [error localizedFailureReason]);
	}
}

-(IBAction)usePlaceholderFile:(id)sender {
	usePlaceHolderFile = !usePlaceHolderFile;
}


-(void)clearNowPlayingFile {
	NSFileManager *filemgr;
	
	filemgr = [NSFileManager defaultManager];
	
	if ([filemgr removeItemAtPath:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/NowPlaying.txt",NSHomeDirectory()] error: NULL]  == YES)
        NSLog (@"Remove successful");
	else
        NSLog (@"Remove failed");
}

-(void)writeToNowPlayingFile:(NSString*)artist withTitle:(NSString*)song {
	
	NSFileManager *filemgr;
	
	filemgr = [NSFileManager defaultManager];
	
	if ([filemgr fileExistsAtPath:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/NowPlaying.txt",NSHomeDirectory()] ] == YES) {
		[self clearNowPlayingFile];
	}
    [self createFileWithArtist:artist andSongTitle:song];
}

@end
