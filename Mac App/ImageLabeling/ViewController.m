//
//  ViewController.m
//  ImageLabeling
//
//  Created by Krzysztof on 17/06/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import "ViewController.h"
#import "Appearance.h"
#import "NSArray+Utils.h"
#import "FrameEditorView.h"



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Private Interface


@interface ViewController() <FrameEditorViewDelegage>

@property (nonatomic, strong) FrameEditorView *preview;

@property (nonatomic, weak) Label *infoLabel;


@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) NSString *directory;
@property (nonatomic, assign) NSInteger currentIndex;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation ViewController

- (void)viewDidLoad {
    __weak typeof(self) weakSelf = self;
    
    
    // Define the interface
    
    View *view = [[View alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];

    
    FrameEditorView *preview = [[FrameEditorView alloc] initWithDelegate:self];
    self.preview = preview;
    [view addSubview:preview];
    
    
    Font *iconFont = [NSFont fontelloWithSize:20];
    
    View *backgroundView = [View new];
    backgroundView.layer.cornerRadius = 5.0;
    backgroundView.backgroundColor = [NSColor colorWithWhite:1.0 alpha:0.75];
    backgroundView.layer.masksToBounds = YES;
    backgroundView.userInteractionEnabled = YES;
    [backgroundView setOnMouseClicked:^(View *view) {
        // Eat
    }];
    [preview addSubview:backgroundView];
    
    
    Button *next = [Button new];
    next.title = [NSString fontelloIconStringForEnum:FOIconRight_Big];
    next.toolTip = @"Save frames and go to next image";
    [next setFont:iconFont];
    unichar rightArrowKey = NSRightArrowFunctionKey;
    [next setKeyEquivalent:[NSString stringWithCharacters:&rightArrowKey length:1]];
    [next setOnClick:^(id sender){
        [weakSelf nextAction:sender];
    }];
    [preview addSubview:next];
    
    Button *previous = [Button new];
    previous.title = [NSString fontelloIconStringForEnum:FOIconLeft_Big];
    previous.toolTip = @"Save frames and go to previous image";
    [previous setFont:iconFont];
    unichar leftArrowKey = NSLeftArrowFunctionKey;
    [previous setKeyEquivalent:[NSString stringWithCharacters:&leftArrowKey length:1]];
    [previous setOnClick:^(id sender){
        [weakSelf previousAction:sender];
    }];
    [preview addSubview:previous];
    
    
    Button *delete = [Button new];
    delete.title = [NSString fontelloIconStringForEnum:FOIconTrash_Empty];
    [delete setFont:iconFont];
    [delete setKeyEquivalent:@"d"];
    delete.toolTip = @"Remove image image - there are no correct frames in it";
    [delete setKeyEquivalentModifierMask:NSEventModifierFlagCommand];
    [delete setOnClick:^(id sender){
        [weakSelf deleteAction:sender];
    }];
    [preview addSubview:delete];
    

    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"welcome_text" withExtension:@"md"];
    NSString *markdown = [NSString stringWithContentsOfURL:url
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    
    NSArray *lines = [markdown componentsSeparatedByString:@"\n"];
    
    NSColor *textColor = [NSColor colorWithWhite:0.10 alpha:1.0];
    NSDictionary *bodyAttributes = @{NSFontAttributeName : [NSFont withSize:15],
                                     NSForegroundColorAttributeName : textColor };
    NSDictionary *headerAttributes = @{NSFontAttributeName : [NSFont boldWithSize:16],
                                       NSForegroundColorAttributeName : textColor
                                       };
    
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    for (NSString *line in lines) {
        NSString *fullLine = [NSString stringWithFormat:@"%@\n", line];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:fullLine attributes:bodyAttributes];
        if ([line hasPrefix:@"#"]) {
            string = [[NSAttributedString alloc] initWithString:fullLine attributes:headerAttributes];
        }
        
        [attributedString appendAttributedString:string];
        
    }
    
    
    // Help Info
    Label *infoLabel = [Label new];
    self.infoLabel = infoLabel;
    infoLabel.attributedStringValue = attributedString;
    [view addSubview:infoLabel];
    [view setOnLayout:^(NSView *view){
        // Preview
        preview.frame = view.bounds;
        
        // Welcome / Message
        infoLabel.l_position = CGPointMake(20, 20);
        infoLabel.l_size = [infoLabel sizeThatFits:CGSizeMake(view.l_width-infoLabel.l_left * 2,
                                                                  view.l_height-infoLabel.l_top * 2)];
        
        // Toolbar
        
        CGSize buttonSize = CGSizeMake(40, 40);
        
        CGFloat middleY = 18;
        previous.l_size = buttonSize;
        previous.l_left = 20;
        previous.l_centerY = middleY;
        
        next.l_size = buttonSize;
        next.l_left = previous.l_right + 14;
        next.l_centerY = middleY;
        
        delete.l_size = buttonSize;
        delete.l_left = next.l_right + 20;
        delete.l_centerY = middleY;
        
        CGFloat left = previous.l_left-10;
        backgroundView.l_frame = CGRectMake(left, -5,
                                    delete.l_right + 10 - left, previous.l_bottom + 10);
        
        
        
    }];
    
    preview.visible = false;
    infoLabel.visible = true;
}


- (void)viewDidLayout {
    View *view = [[self.view subviews] firstObject];
    view.requiresLayout = YES;
    view.frame = self.view.bounds;
}


- (void)frameChanged {
    // Display frame size
}



- (NSString *)dataPath {
    return [self.directory stringByAppendingPathComponent:@"images_info.json"];
}





- (void)imageChanged {
    NSString *imageName = self.images[self.currentIndex];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:[self.directory stringByAppendingPathComponent:imageName]];
    
    NSDictionary *info = self.data[imageName];
    NSArray *frames = info[@"frames"];
    BOOL framesConfirmed = YES;
    
    
    if (![frames isKindOfClass:[NSArray class]] || frames.count == 0) {
        
        CGRect frame = CGRectMake(100, 100, 100, 100);
        // If frame was picked reuse the previous one
        if (!CGRectIsNull(self.preview.selectedArea)) {
            frame = self.preview.selectedArea;
        }
        
        frames = @[jsonFromFrame(frame)];
        framesConfirmed = NO;
    }
    
    [self.preview updateWithImage:image frames:frames framesConfirmed:framesConfirmed];
    
    self.view.window.title = [NSString stringWithFormat:@"%@ (%@ x %@),  %@ from %@",
                              imageName, @(image.size.width), @(image.size.height),
                              @(self.currentIndex), @(self.images.count)];

    
    [[self view] setNeedsLayout:YES];
}




- (void)viewWillAppear {
    [super viewWillAppear];
}


- (void)showOpenDialog {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    
    __weak typeof(self) weakSelf = self;
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            
            NSArray* urls = [panel URLs];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf openDirectory:[urls firstObject]];
            });
        }
    }];
}


- (void)openDirectory:(NSURL *)directoryURL {
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryURL.path isDirectory:&isDirectory]) {
        NSAlert *alert = [NSAlert new];
        alert.messageText = @"Directory does not exist";
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    
    if (!isDirectory) {
        NSAlert *alert = [NSAlert new];
        alert.messageText = @"Selected file is not a directory";
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryURL.path error:nil];
    NSArray *jpgFiles = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"]];
    NSArray *pngFiles = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"]];
    
    NSMutableArray *images = [NSMutableArray new];
    [images addObjectsFromArray:jpgFiles];
    [images addObjectsFromArray:pngFiles];
    
    
    if (images.count == 0) {
        NSAlert *alert = [NSAlert new];
        alert.messageText = @"Directory does not contain any image file";
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        
        return;
        
        
    }
    
    // Add to recent items
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:directoryURL];
    
    self.directory = directoryURL.path;
    
    
    NSData *data = [NSData dataWithContentsOfFile:[self dataPath]];
    NSDictionary *json  = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        self.data = [json mutableCopy];
                
        // Remove any non existing keys ?
        //            NSArray *keys = [self.data allKeys];
        //            for (NSString *name in keys){
        //                if (![files containsObject:name]) {
        //                    self.data[name] = nil;
        //                }
        //            }
        
    } else {
        self.data = [NSMutableDictionary dictionary];
    }
    
    // Sort so that all processed are on front
    [images sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        BOOL obj1Processed = self.data[obj1] != nil;
        BOOL obj2Processed = self.data[obj1] != nil;
        
        if (obj1Processed != obj2Processed) {
            if (obj1Processed) {
                return NSOrderedAscending;
            }
            return NSOrderedDescending;
        }
        
        return [obj1 compare:obj2];
        
    }];
    
    self.images = images;
    
    // Find first not processed item
    NSInteger index = 0;
    for (NSString *name in self.images) {
        if (self.data[name] == nil) {
            break;
        }
        index++;
    }
    
    if (index >= self.images.count) {
        index = 0;
    }
    
    
    self.infoLabel.hidden = YES;
    self.preview.hidden = NO;
    
    
    // Move to first one
    self.currentIndex = index;
    [self imageChanged];
    
    
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Menu Items 


- (void)deleteAction:(id)sender {
    NSString *imageName = self.images[self.currentIndex];
    NSMutableArray *images = [self.images mutableCopy];
    [images removeObject:imageName];
    self.images = images;
    
    
    NSString *path = [self.directory stringByAppendingPathComponent:imageName];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
    // Move onto next one
    self.currentIndex --;
    
    if (self.images.count == 0) {
        self.infoLabel.visible = YES;
        self.preview.visible = NO;
        self.view.window.title = @"";
        return;
    } else {
        [self nextAction:nil];
    }
    
}




- (void)save {
    NSString *imageName = self.images[self.currentIndex];
    
    // Save current frames
    NSMutableDictionary *imageInfo = [self.data[imageName] mutableCopy];
    if (imageInfo == nil) {
        imageInfo = [NSMutableDictionary dictionary];
    }
    imageInfo[@"frames"] = self.preview.selectedAreas;
    
    self.data[imageName] = imageInfo;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.data
                                                       options:(NSJSONWritingOptions) NSJSONWritingPrettyPrinted
                                                         error:NULL];
    
    if (jsonData) {
        [jsonData writeToFile:[self dataPath] atomically:YES];
    }
}

- (void)previousAction:(id)sender {
    [self save];
    
    // Update image index
    self.currentIndex --;
    if (self.currentIndex < 0) {
        self.currentIndex = self.images.count - 1;
    }
    
    [self imageChanged];
}

- (void)nextAction:(id)sender {
    [self save];
    
    // Update image index
    self.currentIndex ++;
    if (self.currentIndex >= self.images.count) { self.currentIndex = 0; }
    
    [self imageChanged];
}


// Those are used by menu items in storyboard
- (void)openDocument:(id)sender {
    [self showOpenDialog];
}
- (void)delete:(id)sender {
    [self deleteAction:sender];
}




@end

