//
//  KillController.m
//  OpenFileKiller
//
//  Created by Matt Gallagher on 4/05/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "KillController.h"
#import "NSTask+OneLineTasksWithOutput.h"
#import "NSString+SeparatingIntoComponents.h"


@implementation KillController

@synthesize timer;

//
// updateProcesses:
//
// Runs "lsof" to get the processes that have the current file path open.
// The result is parsed and the process names and process IDs are stored in the
// "processes" array.
//
// Parameters:
//    sender - the text field or nil
//
- (IBAction)updateProcesses:(id)sender
{
	if (self.timer == nil) {
		self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(ripTitles) userInfo:nil repeats:YES];
	}
}

-(void)ripTitles {
	NSError *error;
	NSString *outputString = [NSTask stringByLaunchingPath:@"/bin/bash" withArguments: [NSArray arrayWithObjects: [NSString stringWithFormat:@"%@/Library/Application Support/Nicecast/icecaster.sh", NSHomeDirectory()], nil] error:&error];
    NSLog(@"outputString %@", outputString);
}

//
// killProcess:
//
// Invoked when the "Kill Process" button is clicked. Requests elevated
// privileges and kills the selected process ID.
//
// Parameters:
//    sender - the button.
//
- (IBAction)killProcess:(id)sender
{
	[self.timer invalidate];
	self.timer = nil;
}

//
// dealloc
//
// Releases instance memory
//
- (void)dealloc
{
	[timer release];
	[super dealloc];
}


@end
