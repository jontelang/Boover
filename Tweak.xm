static BOOL  BooverEnabled = NO;
static float BooverX = 0;
static float BooverY = 0;
static float BooverA = 1.0f;



// @interface SBIconBadgeImage @end
@interface SBIconView : UIView @end
@interface SBIcon : NSObject @end

// iOS 6
// %hook SBIconBadgeImage
// -(id)initWithCGImage:(CGImageRef)cgimage scale:(float)scale orientation:(int)orientation text:(id)text
// {
//     %log;
//     NSDictionary *d = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jontelang.boover.plist"];
//     if( d )
//     {
//         bool isEnabled = [[d valueForKey:@"isEnabled"] boolValue];
//         if( isEnabled )
//         {
//             float s = [[d valueForKey:@"scale"] floatValue];
//             // Default retina: 2
//             // Default normal: 1 ???
//             if( s ){
//                 scale = 3-s;
//             }
//         }
//     }
//     return %orig;
// }
// %end

// iOS 7
%hook SBDarkeningImageView
-(id)initWithFrame:(CGRect)arg1
{
    id o = %orig();
    if(BooverEnabled)
    {
        ((UIView*)o).alpha = BooverA;
    }
    return o;
}
%end

// Both
%hook SBIconView

// iOS 7
-(CGRect)_frameForAccessoryView
{
    //%log;
    CGRect o = %orig();
    if(BooverEnabled)
    {
        // Improve this
        float correction = (o.size.width - 24) / 2.0f;
        o.origin.x = BooverX - correction;
        o.origin.y = BooverY;
    }
    return o;
}

// iOS 5 and 6
-(void)updateBadge{
    %log;
    %orig;

    if( BooverEnabled )
    {
        UIImageView *v;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
        {
            v = MSHookIvar<UIImageView *>(self,  "_accessoryView");

            if(v==nil){return;}

            SBIcon *i = MSHookIvar<SBIcon *>(self,  "_icon");
            if( [i isKindOfClass:[%c(SBUserInstalledApplicationIcon) class]] )
            {
                BOOL hasStash = MSHookIvar<BOOL>(i,  "_shouldHaveSash");
                if( hasStash )
                {
                    return; // It means they have the "new" sash
                }
            }
        }
        else // Under 6.0
        {
            v = MSHookIvar<UIImageView *>(self,  "_badgeView");
        }
    
        [v setFrame:CGRectMake( BooverX, BooverY, v.bounds.size.width, v.bounds.size.height)];
        v.alpha = BooverA;
    }
}

%end

static void loadPrefs()
{
    NSLog(@"loadPrefs - Boover");
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jontelang.boover.plist"];
    if(prefs){
        if ( [prefs objectForKey:@"isEnabled"] ){
            BooverEnabled = [[prefs valueForKey:@"isEnabled"] boolValue];
        }
        if ( [prefs objectForKey:@"X"] && [prefs objectForKey:@"Y"] ){
            BooverX = [[prefs valueForKey:@"X"] floatValue];
            BooverY = [[prefs valueForKey:@"Y"] floatValue];   
        }
        if ( [prefs objectForKey:@"A"] ){
            BooverA = [[prefs valueForKey:@"A"] floatValue];   
        }
    }
}

%ctor
{
    
    //CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.jontelang.boover"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    loadPrefs();
}
