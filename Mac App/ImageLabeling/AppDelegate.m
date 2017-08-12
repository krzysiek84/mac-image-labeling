//
//  AppDelegate.m
//  ImageLabeling
//
//  Created by Krzysztof on 17/06/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import "AppDelegate.h"
#import "ViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Application finished launching
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Save anything in progress
}


// Open Recent:
- (void)application:(NSApplication *)sender openFiles:(NSArray<NSString *> *)filenames {
    if (filenames.count != 1) {
        return;
        
    }
    NSString *fileName = [filenames firstObject];
    NSURL *url = [NSURL fileURLWithPath:fileName];
    
    NSWindowController *windowController = [sender.mainWindow windowController];
    ViewController *viewController = (ViewController *)windowController.contentViewController;
    [viewController openDirectory:url];
}



@end
