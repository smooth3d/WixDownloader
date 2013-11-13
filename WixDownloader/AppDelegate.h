#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSTextField* site;
    IBOutlet NSTextField* domain;
    IBOutlet NSTextField* log;
    IBOutlet NSButton* download;
    IBOutlet NSProgressIndicator *loading;
    IBOutlet NSButton *media;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction) download_Click:(id)sender;
- (void) Debug:(NSString*)d;

@end
