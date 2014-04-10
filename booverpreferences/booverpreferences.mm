#import <_own_/Preferences5/Preferences.h>


@interface booverpreferencesListController: PSListController @end

@implementation booverpreferencesListController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"booverpreferences" target:self] retain];

        PSSpecifier *spec = [self specifierForID:@"RespringID"];
        [spec setProperty:@"2" forKey:@"alignment"];
        [self reloadSpecifier:spec];
    }
    return _specifiers;
}

-(void)respring
{
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jontelang.boover.plist"];
    if(!prefs){
        prefs = [[NSMutableDictionary alloc] init];
    }
    
    // This causes a "bug" where if the tempXYA is not set already the values saved will be 0 (zero)
    // casuing the settings panel to have the badge at 0 0 and alpha 0.
    // Easy to fix, but why bother, who would ever go to the settings - NOT change anything and then
    // save.. Then again, this comment probably took me longer to write than adding a fix soo...
    [prefs setValue:[NSNumber numberWithFloat:[[prefs valueForKey:@"tempX"] floatValue]] forKey:@"X"];
    [prefs setValue:[NSNumber numberWithFloat:[[prefs valueForKey:@"tempY"] floatValue]] forKey:@"Y"];
    [prefs setValue:[NSNumber numberWithFloat:[[prefs valueForKey:@"tempSize"] floatValue]] forKey:@"Size"];
    [prefs setValue:[NSNumber numberWithFloat:[[prefs valueForKey:@"tempRadius"] floatValue]] forKey:@"Radius"];
    [prefs setValue:[NSNumber numberWithFloat:[[prefs valueForKey:@"tempDegrees"] floatValue]] forKey:@"Degrees"];
    // [prefs setValue:[prefs valueForKey:@"tempColor"] forKey:@"Color"];
    // [prefs setValue:[NSNumber numberWithFloat:[[prefs valueForKey:@"tempAlpha"] floatValue]] forKey:@"Alpha"];
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
// -(void)reload
// {
//     NSLog(@"reload");
//     NSLog(@"self: %@",self);
//     NSLog(@"self.view: %@",self.view);
//     [((UITableView*)self.view) reloadData];
// }

@end


// vim:ft=objc
