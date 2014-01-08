#import <_own_/Preferences5/Preferences.h>


@interface booverpreferencesListController: PSListController @end

@implementation booverpreferencesListController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"booverpreferences" target:self] retain];
    }
    return _specifiers;
}

-(void)respring
{
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jontelang.boover.plist"];
    if(!prefs){
        prefs = [[NSMutableDictionary alloc] init];
    }

    [prefs setValue:[NSNumber numberWithFloat:[[prefs valueForKey:@"tempX"] floatValue]] forKey:@"X"];
    [prefs setValue:[NSNumber numberWithFloat:[[prefs valueForKey:@"tempY"] floatValue]] forKey:@"Y"];
    [prefs setValue:[NSNumber numberWithFloat:[[prefs valueForKey:@"tempA"] floatValue]] forKey:@"A"];
    [prefs writeToFile:@"/var/mobile/Library/Preferences/com.jontelang.boover.plist" atomically:YES];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
    {
        system("killall backboardd");
    }
    else // Under 6.0
    {
        system("killall SpringBoard");
    }
}
@end


// vim:ft=objc
