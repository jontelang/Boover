static BOOL  BooverEnabled = NO;
static float BooverX = 0;
static float BooverY = 0;
static float BooverA = 1.0f;
static float BooverR = 1;
static float BooverG = 0;
static float BooverB = 0;



// @interface SBIconBadgeImage @end
@interface SBIconView : UIView @end
@interface SBIcon : NSObject @end



// // iOS 6
//  %hook SBIconBadgeImage
// // -(id)initWithCGImage:(CGImageRef)cgimage scale:(float)scale orientation:(int)orientation text:(id)text
// // {

// //     %log;
// //     NSDictionary *d = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jontelang.boover.plist"];
// //     if( d )
// //     {
// //         bool isEnabled = [[d valueForKey:@"isEnabled"] boolValue];
// //         if( isEnabled )
// //         {
// //             float s = [[d valueForKey:@"scale"] floatValue];
// //             // Default retina: 2
// //             // Default normal: 1 ???
// //             if( s ){
// //                 scale = 3-s;
// //             }
// //         }
// //     }
// //     return %orig;
// // }
//  - (id)initWithCGImage:(struct CGImage *)arg1 scale:(float)arg2 orientation:(int)arg3 text:(id)arg4
//  {
//     %log;
//     [UIImagePNGRepresentation([UIImage imageWithCGImage:arg1]) writeToFile:@"/var/mobile/arg1_LAT.png" atomically:YES];
//     return %orig();
//  }
// %end

// iOS7
// %hook SBIconAccessoryImage
// -(id)initWithImage:(id)arg1
// {
//     %log;

//     [UIImagePNGRepresentation(arg1) writeToFile:@"/var/mobile/arg1.png" atomically:YES];

//     // Create a temporary red view
//     // UIView *bv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
//     // bv.backgroundColor = [UIColor blueColor];
//     // bv.layer.cornerRadius = 12;
    
//     // // Start a new image context
//     // UIGraphicsBeginImageContextWithOptions(bv.frame.size, NO, [UIScreen mainScreen].scale);
    
//     // // // Copy view into an image
//     // [bv.layer renderInContext:UIGraphicsGetCurrentContext()];
    
//     // // // load the image
//     // UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
//     // // // Step one done
//     // UIGraphicsEndImageContext();

//     // [UIImagePNGRepresentation(img) writeToFile:@"/var/mobile/img.png" atomically:YES];

//      id orig = %orig(arg1); //img);

//     // [UIImagePNGRepresentation(orig) writeToFile:@"/var/mobile/orig.png" atomically:YES];

//     // return
//     return orig;

//     // //
//     // // Thanks, http://coffeeshopped.com/2010/09/iphone-how-to-dynamically-color-a-uiimage
//     // //

//     // // // draw tint color
//     // // CGContextSetBlendMode(context, kCGBlendModeNormal);
//     // // [tintColor setFill];
//     // // CGContextFillRect(context, rect);

//     // // // mask by alpha values of original image
//     // // CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
//     // // CGContextDrawImage(context, rect, myIconImage.CGImage);

//     // // load the image
//     // UIImage *img = arg1;

//     //  // Begin a new image context, to draw our colored image onto
//     // UIGraphicsBeginImageContextWithOptions(img.size, NO, [UIScreen mainScreen].scale);
    
//     // // get a reference to that context we created
//     // CGContextRef context = UIGraphicsGetCurrentContext();
    
//     // // translate/flip the graphics context (for transforming from CG* coords to UI* coords
//     // CGContextTranslateCTM(context, 0, img.size.height);
//     // CGContextScaleCTM(context, 1.0, -1.0);
    
//     // // ??
//     // CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    
//     // // First make white
//     // // [[UIColor whiteColor] setFill];
    
//     // // // set the blend mode to color burn, and the original image
//     // // CGContextSetBlendMode(context, kCGBlendModeNormal);
//     // // CGContextDrawImage(context, rect, img.CGImage);

//     // // First make then new
//     // [[UIColor blueColor] setFill];
    
//     // // set the blend mode to color burn, and the original image
//     // CGContextSetBlendMode(context, kCGBlendModeNormal);
//     // CGContextDrawImage(context, rect, img.CGImage);
    
//     // // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
//     // CGContextClipToMask(context, rect, img.CGImage);
//     // CGContextAddRect(context, rect);
//     // CGContextDrawPath(context,kCGPathFill);
    
//     // // generate a new UIImage from the graphics context we drew onto
//     // UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    
//     // // Fin.
//     // UIGraphicsEndImageContext();
    
//     // return %orig(coloredImg);
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
        UIView *bv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        bv.layer.cornerRadius = 12;

        // Set the color
        bv.backgroundColor = [UIColor colorWithRed:BooverR green:BooverG blue:BooverB alpha:1];
        
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

// iOS 7 (and 6, apparently)
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
            float correction = (o.size.width - 24) / 2.0f;
            o.origin.x = BooverX - correction;
            o.origin.y = BooverY;
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
        v.alpha = BooverA;
    }
}

%end


%ctor
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
        if ( [prefs objectForKey:@"C"] ){
            NSString *tempC = [prefs valueForKey:@"C"];   
            NSArray *comps = [tempC componentsSeparatedByString:@" "];
            BooverR = [comps[0] floatValue];
            BooverG = [comps[1] floatValue];
            BooverB = [comps[2] floatValue];
        }
    }
    [prefs release];
}
