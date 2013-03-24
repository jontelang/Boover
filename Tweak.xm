%hook SBIconBadgeImage

@interface SBIconBadgeImage
 @property(readonly,  copy) NSString* text;
@end

-(id)initWithCGImage:(CGImageRef)cgimage scale:(float)scale orientation:(int)orientation text:(id)text
{
    NSDictionary *d = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jontelang.boover.plist"];
    if( d )
    {
        bool isEnabled = [[d valueForKey:@"isEnabled"] boolValue];
        if( isEnabled )
        {
            float s = [[d valueForKey:@"scale"] floatValue];
            // Default retina: 2
            // Default normal: 1 ???
            if( s ){
                scale = 3-s;
            }
        }
    }
    return %orig;
}

%end





%hook SBIconView

@interface SBIconView : UIView
    -(void)setLabelHidden:(BOOL)hidden;
    -(void)updateLabel;
@end

@interface SBIcon : NSObject
@end

@interface SBUserInstalledApplicationIcon : NSObject
    - (BOOL)_shouldShowSashForNewlyInstalledApp;
@end



-(void)updateBadge{
    %orig;

    UIImageView *v;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
    {
        v = MSHookIvar<UIImageView *>(self,  "_accessoryView");

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

    NSDictionary *d = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jontelang.boover.plist"];
    if( d )
    {
        bool isEnabled = [[d valueForKey:@"isEnabled"] boolValue];
        if( isEnabled )
        {
            // Position
            int p           = [[d valueForKey:@"BadgePosition"] intValue];
            int offsetX     = [[d valueForKey:@"offsetX"]       intValue];
            int offsetY     = [[d valueForKey:@"offsetY"]       intValue];

            // Refactor the positioningcode it looks bad.
            switch( p )
            {
                case 0: [v setFrame:CGRectMake( -9+offsetX, -9+offsetY, v.bounds.size.width, v.bounds.size.height)];               break;
                case 1: [v setCenter:CGPointMake(self.bounds.size.width/2+offsetX,  v.center.y+offsetY)];                        break;
                case 2: [v setFrame:CGRectMake(v.frame.origin.x+offsetX,  v.frame.origin.y+offsetY,  v.bounds.size.width, v.bounds.size.height)]; break;

                case 3: [v setFrame:CGRectMake(-9+offsetX, self.bounds.size.height/2-9+3-v.bounds.size.height/2+offsetY,  v.bounds.size.width, v.bounds.size.height)];  break;
                case 4: [v setCenter:CGPointMake(self.bounds.size.width/2+offsetX,  self.bounds.size.height/2-9+3+offsetY)];                  break;
                case 5: [v setFrame:CGRectMake(v.frame.origin.x+offsetX, self.bounds.size.height/2-9+3-v.bounds.size.height/2+offsetY,  v.bounds.size.width, v.bounds.size.height)]; break;

                case 6: [v setFrame:CGRectMake(-9+offsetX,  self.bounds.size.height-9+3-v.bounds.size.height+offsetY,  v.bounds.size.width, v.bounds.size.height)];       break;
                case 7: [v setCenter:CGPointMake(self.bounds.size.width/2+offsetX,  self.bounds.size.height-9+3-v.bounds.size.height/2+offsetY)];                       break;
                case 8: [v setFrame:CGRectMake(v.frame.origin.x+offsetX, self.bounds.size.height-9+3-v.bounds.size.height+offsetY, v.bounds.size.width, v.bounds.size.height)];     break;

                case 9: [v setCenter:CGPointMake(self.bounds.size.width/2+offsetX,  self.bounds.size.height-3+offsetY)]; break;
                default: break;
            }

            // Alpha
            float newAlpha = [[d valueForKey:@"alpha"] floatValue];
            if( newAlpha ){
               v.alpha = newAlpha;
            }
        }
    }
}

%end