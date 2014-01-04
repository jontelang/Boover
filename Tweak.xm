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
    -(CGRect)newRectAtPosition:(int)pos withOffsetX:(int)offsetX andOffsetY:(int)offsetY andOriginalRect:(CGRect)orect;
@end

@interface SBIcon : NSObject
@end

@interface SBUserInstalledApplicationIcon : NSObject
    - (BOOL)_shouldShowSashForNewlyInstalledApp;
@end

%new
-(CGRect)newRectAtPosition:(int)pos withOffsetX:(int)offsetX andOffsetY:(int)offsetY andOriginalRect:(CGRect)orect
{
    CGRect newRect;

    switch( pos )
    {
        case 0: newRect = CGRectMake(-9+offsetX, -9+offsetY, orect.size.width, orect.size.height);               break;
        case 1: newRect = CGRectMake((self.bounds.size.width/2)-(orect.size.width/2)+offsetX, -9+offsetY, orect.size.width, orect.size.height);                  break;
        case 2: newRect = CGRectMake(orect.origin.x+offsetX,  orect.origin.y+offsetY,  orect.size.width, orect.size.height); break;

        case 3: newRect = CGRectMake(-9+offsetX, self.bounds.size.height/2-9+3-orect.size.height/2+offsetY,  orect.size.width, orect.size.height);  break;
        case 4: newRect = CGRectMake((self.bounds.size.width/2)-(orect.size.width/2)+offsetX,  (self.bounds.size.height/2)-(orect.size.height/2)-9+3+offsetY, orect.size.width, orect.size.height);                  break;
        case 5: newRect = CGRectMake(orect.origin.x+offsetX, self.bounds.size.height/2-9+3-orect.size.height/2+offsetY,  orect.size.width, orect.size.height); break;

        case 6: newRect = CGRectMake(-9+offsetX,  self.bounds.size.height-9+3-orect.size.height+offsetY,  orect.size.width, orect.size.height);       break;
        case 7: newRect = CGRectMake((self.bounds.size.width/2)-(orect.size.width/2)+offsetX, self.bounds.size.height-9+3-orect.size.height+offsetY, orect.size.width, orect.size.height);                  break;
        case 8: newRect = CGRectMake(orect.origin.x+offsetX, self.bounds.size.height-9+3-orect.size.height+offsetY, orect.size.width, orect.size.height);     break;

        default: newRect = orect; break;
    }
    
    return newRect;
}

// iOS 7
-(CGRect)_frameForAccessoryView
{
    %log;
    CGRect o = %orig();
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
            o = [self newRectAtPosition:p withOffsetX:offsetX andOffsetY:offsetY andOriginalRect:o];
        }
    }    
    return o;
}

// iOS 5 and 6
-(void)updateBadge{
    %log;
    %orig;

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

            //Refactor the positioningcode it looks bad.
            // iOS7 notes. For now I'll actually keep this bad code as it actually solves some other preoblems
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