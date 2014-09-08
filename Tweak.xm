static BOOL  BooverEnabled    = NO;
static float BooverX          = 0;
static float BooverY          = 0;
static float BooverR          = 1;
static float BooverG          = 0;
static float BooverB          = 0;
static float BooverSize       = 24;
static float BooverAlpha      = 1.0f;
static float BooverRadius     = 12;
static float BooverDegrees    = 0;
static bool  BooverHasBorder  = NO;
static float BooverTempColorR = 0;
static float BooverTempColorG = 0;
static float BooverTempColorB = 0;
static float BooverGotColorFromIcon       = NO;
static float BooverShouldGetColorFromIcon = NO;
static BOOL  BooverShouldHideText         = NO;

@interface SBIconView : UIView @end
@interface SBIcon : NSObject 
- (id)displayName;
- (id)getIconImage:(int)arg1;
- (id)nodeIdentifier;
- (int)badgeValue;
- (void)setBadge:(id)badge;
@end
@interface SBApplicationIcon : SBIcon
-(int)badgeValue;
@end
@interface SBDarkeningImageView : UIView 
- (void)setImage:(id)arg1;
@end
@interface SBIconBadgeView : UIView
{
  SBDarkeningImageView *_backgroundView;
}
- (void)setDominantColor:(UIImage*)image;
- (void)getAndSetColor:(UIImage*)arg1;
- (void)makeImageForValue:(CGRect)rect;
@end
@interface SBIconAccessoryImage : UIImage @end


// iOS 7
%hook SBDarkeningImageView

-(id)initWithFrame:(CGRect)arg1
{
    //%log;
    id o = %orig();
    if(BooverEnabled)
    {
        ((UIView*)o).alpha = BooverAlpha;
    }
    return o;
}

%end

%hook SBApplicationIcon
-(void)setBadge:(id)badge{
  %orig(@"");
}
-(int)badgeValue{
  return 0;
}
// -(void)setBadge:(NSString*)badge;
%end 

// Both
%hook SBIconView

//iOS 7 (and 6, apparently)
-(CGRect)_frameForAccessoryView
{
    //%log;
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
            float biggerW  = (o.size.width > BooverSize) ? o.size.width : BooverSize;
            float smallerW = (o.size.width > BooverSize) ? BooverSize : o.size.width;
            float correctionW = biggerW - smallerW;
            o.origin.x = BooverX - (correctionW/2);
            o.origin.y = BooverY;
            o.size.width  = biggerW ;//- (correctionW/4);
            //float biggerH  = (o.size.height > BooverSize) ? o.size.height : BooverSize;
            o.size.height = BooverSize;

            /// dd
            if(BooverShouldHideText){
              o.size.width = BooverSize;
            }
        }
    }
    //NSLog(@"Boover - _frameForAccessoryView returns %@",NSStringFromCGRect(o));
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
        if(v.bounds.size.height!=0&&v.bounds.size.width!=0){
            //NSLog(@"Boover - --------- %@",NSStringFromCGRect(v.bounds));
            float h = BooverSize;
            float w = BooverSize * (v.bounds.size.width/v.bounds.size.height);
            float correctionW = (w>h)?w-h:h-w;
            float x = BooverX - (correctionW/2);
            float y = BooverY - 2;
            [v setFrame:CGRectMake( x, y, w, h)];
            v.alpha = BooverAlpha;
        }
    }
}

// // -(struct CGRect)_frameForVisibleImage
// // {
  
// // }

// - (struct CGSize)iconImageVisibleSize
// {
//   return %orig();
// }
// - (struct CGPoint)iconImageCenter
// {
//   return %orig();
// }
// - (struct CGRect)iconImageFrame
// {
//   CGRect o = %orig();
//   float percentagesmaller = 0.5f; 
//   float smaller = o.size.width * percentagesmaller;
//   o.size.width -= smaller;
//   o.size.height -= smaller;
//   o.origin.x += smaller / 2;
//   o.origin.y += smaller / 2;
//   return o;  
// }

%end

%ctor
{
    //NSLog(@"Boover - loadPrefs - Boover");
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jontelang.boover.plist"];
    //NSLog(@"Boover - %@",prefs);
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
        if ( [prefs objectForKey:@"Red"] ){
            BooverR = [[prefs valueForKey:@"Red"] floatValue] / 255.0f;
        }
        if ( [prefs objectForKey:@"Green"] ){
            BooverG = [[prefs valueForKey:@"Green"] floatValue] / 255.0f;
        }
        if ( [prefs objectForKey:@"Blue"] ){
            BooverB = [[prefs valueForKey:@"Blue"] floatValue] / 255.0f;
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
        if ( [prefs objectForKey:@"BooverShouldGetColorFromIcon"] ){
            BooverShouldGetColorFromIcon = [[prefs valueForKey:@"BooverShouldGetColorFromIcon"] boolValue];   
        }
        if ( [prefs objectForKey:@"BooverShouldHideText"] ){
            BooverShouldHideText = [[prefs valueForKey:@"BooverShouldHideText"] boolValue];   
        }
        if ( [prefs objectForKey:@"hasBorder"] ){
            BooverHasBorder = [[prefs valueForKey:@"hasBorder"] boolValue];   
        }
    }
    [prefs release];
}




%hook SBIconBadgeView

+ (id)_createImageForText:(id)arg1 highlighted:(_Bool)arg2{
  if(BooverShouldHideText&&BooverEnabled){arg1 = @" ";}
  return %orig();
}
// + (id)_checkoutImageForText:(id)arg1 highlighted:(_Bool)arg2{
//   arg1 = @"";
//   return %orig();
// }
// - (void)layoutSubviews
// {
//   //NSLog(@"gggggggdsg gg g g gg g %@", self);
//   %orig();
// }
// - (void)_configureAnimatedForText:(id)arg1 highlighted:(_Bool)arg2 withPreparation:(id)arg3 animation:(id)arg4 completion:(id)arg5{
//   arg1 = @"";
//   %orig();
// }

- (void)configureAnimatedForIcon:(id)arg1 location:(int)arg2 highlighted:(_Bool)arg3 withPreparation:(id)arg4 animation:(id)arg5 completion:(id)arg6
{
  %log();
  if( BooverEnabled )
  {
    [self getAndSetColor:[(SBIcon*)arg1 getIconImage:1]];
    %orig();
    [self makeImageForValue:self.bounds];
  }
  else
  {
    %orig();
  }
  
}

- (void)configureForIcon:(id)arg1 location:(int)arg2 highlighted:(_Bool)arg3
{ 
  %log();
  if( BooverEnabled )
  {
    [self getAndSetColor:[(SBIcon*)arg1 getIconImage:1]];
    %orig();
    [self makeImageForValue:self.bounds];
  }
  else
  {
    %orig();
  }
}

struct pixel {
    unsigned char r, g, b, a;
};

%new
- (void)setDominantColor:(UIImage*)image
{
    NSUInteger red = 0;
    NSUInteger green = 0;
    NSUInteger blue = 0;

    struct pixel* pixels = (struct pixel*) calloc(1, image.size.width * image.size.height * sizeof(struct pixel));
    if (pixels != nil)
    {

        CGContextRef context = CGBitmapContextCreate(
                                                 (void*) pixels,
                                                 image.size.width,
                                                 image.size.height,
                                                 8,
                                                 image.size.width * 4,
                                                 CGImageGetColorSpace(image.CGImage),
                                                 kCGImageAlphaPremultipliedLast
                                                 );

        if (context != NULL)
        {
            // Draw the image in the bitmap

            CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), image.CGImage);

            // Now that we have the image drawn in our own buffer, we can loop over the pixels to
            // process it. This simple case simply counts all pixels that have a pure red component.

            // There are probably more efficient and interesting ways to do this. But the important
            // part is that the pixels buffer can be read directly.

            NSUInteger numberOfPixels = image.size.width * image.size.height;
            NSUInteger pixelsToOmitt = 0;
            for (int i=0; i<numberOfPixels; i++) {

                NSUInteger threshhold = 210;

                if(pixels[i].r > threshhold){
                if(pixels[i].g > threshhold){
                if(pixels[i].b > threshhold){
                  pixelsToOmitt++;
                  continue;
                }}}

                red += pixels[i].r;
                green += pixels[i].g;
                blue += pixels[i].b;
            }

            numberOfPixels -= pixelsToOmitt;

            red   /= numberOfPixels;
            green /= numberOfPixels;
            blue  /= numberOfPixels;

            CGContextRelease(context);
        }

        free(pixels);
    }

    BooverTempColorR = red/255.0f;
    BooverTempColorG = green/255.0f;
    BooverTempColorB = blue/255.0f;
}

%new
-(void)getAndSetColor:(UIImage*)arg1
{
  if(arg1)
  {
    [self setDominantColor:arg1];
    BooverGotColorFromIcon = YES;
  }
  else
  {
    BooverGotColorFromIcon = NO;
  }
}

%new
-(void)makeImageForValue:(CGRect)o
{
  // Improve this
  float biggerW  = (o.size.width > BooverSize) ? o.size.width : BooverSize;
  float smallerW = (o.size.width > BooverSize) ? BooverSize : o.size.width;
  float correctionW = biggerW - smallerW;
  o.origin.x = BooverX - (correctionW/2);
  o.origin.y = BooverY;
  o.size.width  = biggerW ;//- (correctionW/4);
  //float biggerH  = (o.size.height > BooverSize) ? o.size.height : BooverSize;
  o.size.height = BooverSize;

  /// dd
  if(BooverShouldHideText){
    o.size.width = BooverSize;
  }

  // NSLog(@"value is : %@", NSStringFromClass([value class]));
  //Create a temporary COLORED view
  UIView *bv = [[UIView alloc] initWithFrame:o];
  bv.layer.cornerRadius = ((BooverSize/2)*BooverRadius);
  
  if(BooverHasBorder)
  {
    bv.layer.borderWidth = 1;
    bv.layer.borderColor = [UIColor whiteColor].CGColor;
  }

  // Set the color
  bv.backgroundColor = [UIColor colorWithRed:BooverR green:BooverG blue:BooverB alpha:BooverAlpha];

  // Other color?
  if(BooverShouldGetColorFromIcon && BooverGotColorFromIcon)
  {
    // Set the new color
    bv.backgroundColor = [UIColor colorWithRed:BooverTempColorR green:BooverTempColorG blue:BooverTempColorB alpha:BooverAlpha];
  }

  // Start a new image context
  UIGraphicsBeginImageContextWithOptions(bv.frame.size, NO, [UIScreen mainScreen].scale);
  
  // Copy view into an image
  [bv.layer renderInContext:UIGraphicsGetCurrentContext()];
  
  // Load the image
  UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
  
  // Step one done
  UIGraphicsEndImageContext();

  // Actually set the image
  SBDarkeningImageView* v = MSHookIvar<SBDarkeningImageView*>(self,"_backgroundView");
  [v setImage:img];
}

%end