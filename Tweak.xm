static BOOL  BooverEnabled = NO;
static float BooverX = 0;
static float BooverY = 0;
static float BooverAlpha = 1.0f;
static float BooverR = 1;
static float BooverG = 0;
static float BooverB = 0;
static float BooverSize = 24;
static float BooverRadius = 12;
static float BooverDegrees = 0;

// @interface SBIconBadgeImage @end
@interface SBIconView : UIView @end
@interface SBIcon : NSObject @end

// iOS 7
%hook SBDarkeningImageView

-(id)initWithFrame:(CGRect)arg1
{
    id o = %orig();
    if(BooverEnabled)
    {
        ((UIView*)o).alpha = BooverAlpha;
    }
    return o;
}

// I hope this does not disturb winterboard. If it even works on iOS7 badges.
-(void)setImage:(id)arg1
{
    if( BooverEnabled==FALSE )
    {
        %orig();
    }
    else
    {
        //Create a temporary COLORED view
        UIView *bv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BooverSize, BooverSize)];
        bv.layer.cornerRadius = ((BooverSize/2)*BooverRadius);

        // Set the color
        bv.backgroundColor = [UIColor colorWithRed:BooverR green:BooverG blue:BooverB alpha:1];
        
        //
        //bv.transform = CGAffineTransformIdentity;
        //bv.transform = CGAffineTransformMakeRotation(50 * M_PI/180);

        // Start a new image context
        UIGraphicsBeginImageContextWithOptions(bv.frame.size, NO, [UIScreen mainScreen].scale);
        
        // // Copy view into an image
        [bv.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        // // load the image
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        
        // // Step one done
        UIGraphicsEndImageContext();

        // return
        %orig(img);
    }
}
%end

// Both
%hook SBIconView

//iOS 7 (and 6, apparently)
-(CGRect)_frameForAccessoryView
{
    CGRect o = %orig();
    if(BooverEnabled)
    {
        // Okay here's the deal. This one actually gets called in iOS 6 also
        // but I already have so much code inside the 'updateBadge' method 
        // which grabs ivars and all that jazz. I think this method gets called
        // way more often and I think (no basis) that it is better to keep the
        // other code in the other method which only gets called every now and then
        // 
        // The next version might remove some iOS5/6 compability. The settings 
        // already looks like crap in iOS6.
        // 
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            // Improve this
            float correction = (o.size.width > BooverSize) ? o.size.width - 24 : 0;

            o.origin.x = BooverX - (correction/2);
            o.origin.y = BooverY;

            o.size.width  = BooverSize + correction;
            o.size.height = BooverSize;
        }
    }
    return o;
}

// iOS 5 and 6
-(void)updateBadge
{
    %orig;

    if( BooverEnabled )
    {
        UIImageView *v;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
        {
            v = MSHookIvar<UIImageView *>(self,  "_accessoryView");

            SBIcon *i = MSHookIvar<SBIcon *>(self,  "_icon");
            if( [i isKindOfClass:[%c(SBUserInstalledApplicationIcon) class]] )
            {
                BOOL hasStash = MSHookIvar<BOOL>(i,  "_shouldHaveSash");
                if(hasStash)
                {
                    return;
                }
            }
        }
        else // Under 6.0
        {
            v = MSHookIvar<UIImageView *>(self,  "_badgeView");
        }
        
        // -1 up because the images seems to be 29x31 so 31-29=2 /2 = 1
        float correction = (v.bounds.size.width - 29) / 2.0f; 
        [v setFrame:CGRectMake( BooverX - correction - 1, BooverY - 2, v.bounds.size.width, v.bounds.size.height)];
        v.alpha = BooverAlpha;
    }
}

%end


%ctor
{
    NSLog(@"loadPrefs - Boover");
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jontelang.boover.plist"];
    NSLog(@"%@",prefs);
    if(prefs){
        if ( [prefs objectForKey:@"isEnabled"] ){
            BooverEnabled = [[prefs valueForKey:@"isEnabled"] boolValue];
        }
        if ( [prefs objectForKey:@"X"] && [prefs objectForKey:@"Y"] ){
            BooverX = [[prefs valueForKey:@"X"] floatValue];
            BooverY = [[prefs valueForKey:@"Y"] floatValue];   
        }
        if ( [prefs objectForKey:@"Alpha"] ){
            BooverAlpha = [[prefs valueForKey:@"Alpha"] floatValue];   
        }
        if ( [prefs objectForKey:@"Color"] ){
            NSString *tempC = [prefs valueForKey:@"Color"];   
            NSArray *comps = [tempC componentsSeparatedByString:@" "];
            BooverR = [comps[0] floatValue];
            BooverG = [comps[1] floatValue];
            BooverB = [comps[2] floatValue];
        }
        if ( [prefs objectForKey:@"Size"] ){
            BooverSize = [[prefs valueForKey:@"Size"] floatValue];   
        }
        if ( [prefs objectForKey:@"Radius"] ){
            BooverRadius = [[prefs valueForKey:@"Radius"] floatValue];  
        }
        if ( [prefs objectForKey:@"Degrees"] ){
            BooverDegrees = [[prefs valueForKey:@"Degrees"] floatValue];   
        }
    }
    [prefs release];
}
