@interface SpringBoard : UIApplication
-(id) _accessibilityFrontMostApplication;
@end

@interface SBApplication
-(id) bundleIdentifier;
@end

@interface BBBulletinRequest : NSObject
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* message;
@property (nonatomic, copy) NSString* sectionID;
@property (nonatomic, retain) NSDate* date;
@end

@interface SBBulletinBannerController
+(id)sharedInstance;
-(void)observer:(id)arg1 addBulletin:(id)arg2 forFeed:(unsigned long long)arg3;
-(void)observer:(id)arg1 addBulletin:(id)arg2 forFeed:(unsigned long long)arg3 playLightsAndSirens:(BOOL)arg4 withReply:(id)arg5;
@end

%hook SBScreenShotter

- (void)saveScreenshot:(_Bool)arg1 {

  // get current open application identifier
  SBApplication *frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
  NSString *currentAppID = [frontApp bundleIdentifier];

  // load user preferences
  NSString *settingsPath = @"/var/mobile/Library/Preferences/me.urandom.noscreenshotty.plist";
  NSMutableDictionary *settingsDict = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];

  // get value of the user preference about the current opened application
  // 0 == user wants to screenshot the app/
  //      user did not set any preference
  // 1 == user do not wants to screenshot the app

  BOOL valueForCurrentApp = [settingsDict[[NSString stringWithFormat:@"%@%@", @"NoScreenshotty-", currentAppID]] boolValue];

  if(valueForCurrentApp == 1) {
    BBBulletinRequest* banner = [[%c(BBBulletinRequest) alloc] init];
    [banner setTitle: @"NoScreenshotty"];
    [banner setMessage: @"Screenshot feature is disabled in this application."];
    [banner setDate: [NSDate date]];
    [banner setSectionID: @"com.apple.camera"];
    if([%c(SBBulletinBannerController) instancesRespondToSelector:@selector(observer:addBulletin:forFeed:playLightsAndSirens:withReply:)]) {
        [(SBBulletinBannerController *)[%c(SBBulletinBannerController) sharedInstance] observer:nil addBulletin:banner forFeed:2 playLightsAndSirens:YES withReply:nil];
    } else {
      [(SBBulletinBannerController *)[%c(SBBulletinBannerController) sharedInstance] observer:nil addBulletin:banner forFeed:2];
    }
    [banner release];
    [settingsDict release];
  } else {
    [settingsDict release];
    %orig(arg1);
  }

}

%end
