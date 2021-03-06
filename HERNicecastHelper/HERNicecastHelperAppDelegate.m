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
  
  [self writeToNowPlayingFile:@"Switching..." withTitle:@"the Broadcast..."];
  [self writeiTunesFile];
}

-(void)moveScripts {
	
	NSString *icecast_shell_script = [[NSBundle mainBundle] pathForResource:@"icecaster" ofType:@"sh"];
	NSString *itunes_shell_script = [[NSBundle mainBundle] pathForResource:@"itunes_ripper" ofType:@"sh"];

  NSString *icecast_ruby_script = [[NSBundle mainBundle] pathForResource:@"icecast_title_ripper" ofType:@"rb"];
	NSString *itunes_song_ripper_script = [[NSBundle mainBundle] pathForResource:@"itunes_song_ripper" ofType:@"rb"];

	NSString *current_xml = [[NSBundle mainBundle] pathForResource:@"current_title" ofType:@"xml"];
	
	NSError *error;
	[[NSFileManager defaultManager] copyItemAtPath:icecast_shell_script toPath:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/icecaster.sh", NSHomeDirectory()] error:&error ];
  [[NSFileManager defaultManager] copyItemAtPath:itunes_shell_script toPath:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/itunes_ripper.sh", NSHomeDirectory()] error:&error ];

  [[NSFileManager defaultManager] copyItemAtPath:icecast_ruby_script toPath:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/icecast_title_ripper.rb", NSHomeDirectory()] error:&error ];
	[[NSFileManager defaultManager] copyItemAtPath:itunes_song_ripper_script toPath:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/itunes_song_ripper.rb", NSHomeDirectory()] error:&error ];
  [[NSFileManager defaultManager] copyItemAtPath:current_xml toPath:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/current_title.xml", NSHomeDirectory()] error:&error ];
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

    [self writeToNowPlayingFile:@"Switching..." withTitle:@"the Broadcast..."];
    [self writeUseOffHoursFile];
  }
	else {
		[self.offHoursTitlesButton setTitle:@"Switch To Off Hours"];
		[self.manualTitlesButton setEnabled:YES];
		[self.artistName setEnabled:YES];
		[self.songTitle setEnabled:YES];
		[self.changeTitleButton setEnabled:YES];
            
    [self clearOffHoursFile];
    [self writeiTunesFile];
	}
}

-(IBAction)useManualTitlesButtonClicked:(id)sender {
	NSLog(@"Manual track titles button clicked");

	manualButtonOn = !manualButtonOn;
	
	if (manualButtonOn) {
    [self clearOffHoursFile];
		[self clearNowPlayingFile];
    [self cleariTunesFile];
    
		[self.offHoursTitlesButton setEnabled:NO];
		[self.manualTitlesButton setTitle:@"Switch Back To Using iTunes"];
		[self writeToNowPlayingFile:[self.artistName stringValue] withTitle:[self.songTitle stringValue]];		
	}
	else {
    [self.offHoursTitlesButton setEnabled:YES];
		[self.manualTitlesButton setTitle:@"Start Using My Own Titles"];
    [self writeToNowPlayingFile:@"Switching..." withTitle:@"the Broadcast..."];
    [self writeiTunesFile];
	}
}



-(void)clearNowPlayingFile {
	NSFileManager *filemgr;
	
	filemgr = [NSFileManager defaultManager];
	
	if ([filemgr removeItemAtPath:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/NowPlaying.txt",NSHomeDirectory()] error: NULL]  == YES)
    NSLog (@"Remove successful");
	else
    NSLog (@"Remove failed");
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

-(void)writeToNowPlayingFile:(NSString*)artist withTitle:(NSString*)song {
	
	NSFileManager *filemgr;
	
	filemgr = [NSFileManager defaultManager];
	
	if ([filemgr fileExistsAtPath:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/NowPlaying.txt",NSHomeDirectory()] ] == YES) {
		[self clearNowPlayingFile];
	}
    [self createFileWithArtist:artist andSongTitle:song];
}

//Get rid of the off hours file so we won't use off hours titles anymore.
-(void)clearOffHoursFile {
	[self clearFile:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/use_off_hours.txt",NSHomeDirectory()]];
}

//This create a file in the Nicecast directory that we will use to see if we can use off hours 
//It's presence will tell our ruby script to go ahead and use off hours. (cron is always runnning and pulling 
//titles from the off hours service
-(void)writeUseOffHoursFile {
	[self cleariTunesFile];
  [self writeFile:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/use_off_hours.txt",NSHomeDirectory()]];
}

-(void)cleariTunesFile {
	[self clearFile:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/use_itunes.txt",NSHomeDirectory()]];
}

-(void)writeiTunesFile {
	[self clearOffHoursFile];
	[self writeFile:[NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/use_itunes.txt",NSHomeDirectory()]];
}


-(void)clearFile:(NSString*)filename {
	NSFileManager *filemgr;
	
	filemgr = [NSFileManager defaultManager];
	
	if ([filemgr removeItemAtPath:filename error: NULL]  == YES)
    NSLog (@"Remove successful");
	else
    NSLog (@"Remove failed");
}

-(void)writeFile:(NSString*)filename {
	
	NSFileManager *filemgr;
	
	filemgr = [NSFileManager defaultManager];
	
	if ([filemgr fileExistsAtPath:filename ] == YES) {
		[self clearNowPlayingFile];
	}
  
  NSError *error;
  BOOL ok = [@"Using Off Hours Titles" writeToFile:filename atomically:YES
                                          encoding:NSUnicodeStringEncoding error:&error];
	if (!ok) {
		// an error occurred
		NSLog(@"Error writing file at %@\n%@", filename, [error localizedFailureReason]);
	}
}





@end
