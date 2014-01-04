#import <Preferences/Preferences.h>

@interface booverpreferencesListController: PSListController {
}
@end

@implementation booverpreferencesListController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"booverpreferences" target:self] retain];
    }
    return _specifiers;
}

-(void)respring{

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
    {
        system("killall backboardd");
    }
    else // Under 6.0
    {
        system("killall SpringBoard");
    }


}

-(void) resetoffsetx {
  PSSpecifier* offsetspecifier = [self specifierForID:@"SliderOffsetX"];
  [self setPreferenceValue:[NSNumber numberWithFloat:0.0f] specifier:offsetspecifier];
  [self reloadSpecifier:offsetspecifier];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) increasex {
  PSSpecifier* offsetspecifier = [self specifierForID:@"SliderOffsetX"];
  int val = [[self readPreferenceValue:offsetspecifier] intValue];
  [self setPreferenceValue:[NSNumber numberWithFloat:val+1] specifier:offsetspecifier];
  [self reloadSpecifier:offsetspecifier];
  [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void) decreasex {
  PSSpecifier* offsetspecifier = [self specifierForID:@"SliderOffsetX"];
  int val = [[self readPreferenceValue:offsetspecifier] intValue];
  [self setPreferenceValue:[NSNumber numberWithFloat:val-1] specifier:offsetspecifier];
  [self reloadSpecifier:offsetspecifier];
  [[NSUserDefaults standardUserDefaults] synchronize];
}





-(void) resetoffsety {
  PSSpecifier* offsetspecifier = [self specifierForID:@"SliderOffsetY"];
  [self setPreferenceValue:[NSNumber numberWithFloat:0.0f] specifier:offsetspecifier];
  //[offsetspecifier setProperty:[NSNumber numberWithFloat:1000.0f] forKey:@"max"];
  [self reloadSpecifier:offsetspecifier];
  [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void) increasey {
  PSSpecifier* offsetspecifier = [self specifierForID:@"SliderOffsetY"];
  int val = [[self readPreferenceValue:offsetspecifier] intValue];
  [self setPreferenceValue:[NSNumber numberWithFloat:val+1] specifier:offsetspecifier];
  [self reloadSpecifier:offsetspecifier];
  [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void) decreasey {
  PSSpecifier* offsetspecifier = [self specifierForID:@"SliderOffsetY"];
  int val = [[self readPreferenceValue:offsetspecifier] intValue];
  [self setPreferenceValue:[NSNumber numberWithFloat:val-1] specifier:offsetspecifier];
  [self reloadSpecifier:offsetspecifier];
  [[NSUserDefaults standardUserDefaults] synchronize];
}




-(void) resetscale {
  PSSpecifier* scalespecifier = [self specifierForID:@"SliderScale"];
  [self setPreferenceValue:[NSNumber numberWithFloat:1.0f] specifier:scalespecifier];
  //[scalespecifier setProperty:[NSNumber numberWithFloat:1000.0f] forKey:@"max"];
  [self reloadSpecifier:scalespecifier];
  [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void) increasescale {
  PSSpecifier* scalespecifier = [self specifierForID:@"SliderScale"];
  float val = [[self readPreferenceValue:scalespecifier] floatValue];
  [self setPreferenceValue:[NSNumber numberWithFloat:val+0.1f] specifier:scalespecifier];
  [self reloadSpecifier:scalespecifier];
  [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void) decreasescale {
  PSSpecifier* scalespecifier = [self specifierForID:@"SliderScale"];
  float val = [[self readPreferenceValue:scalespecifier] floatValue];
  [self setPreferenceValue:[NSNumber numberWithFloat:val-0.1f] specifier:scalespecifier];
  [self reloadSpecifier:scalespecifier];
  [[NSUserDefaults standardUserDefaults] synchronize];
}
@end


// vim:ft=objc
