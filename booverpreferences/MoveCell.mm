#include "_own_/Preferences5/Preferences.h"
//#import <QuartzCore/QuartzCore.h>

@interface MoveCell : PSTableCell <PreferencesTableCustomView> {
    CGPoint startPoint;
    CGPoint origin;
    UIView *badgeView;
    UISlider* slider;
    UIView *left;
    UIView *btn;
    UIView *colorPickerView;
}
@end

@implementation MoveCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    NSLog(@"SPECIFIER: %@", specifier);

        self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
        if (self) {

                self.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];

                [self setAutoresizesSubviews:YES];
                [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

                float width = 320;
    
                left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 160+44)];
                left.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
                [left setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [self addSubview:left];

                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(160,0,160,160)];
                [label setText:@"Drag here"];
                [label setTextAlignment:NSTextAlignmentCenter];
                [label setTextColor:[UIColor lightGrayColor]];
                label.backgroundColor = [UIColor clearColor];
                
                UIImageView *icon = [[UIImageView alloc] initWithImage:
                                                            [self maskImage:
                                                                    [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/booverpreferences.bundle/i.png"] 
                                                                withMask:
                                                                    [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/booverpreferences.bundle/m.png"]]];

                // Defaults
                float w = [[[[UIDevice currentDevice] model] lowercaseString] rangeOfString:@"ipad"].location == NSNotFound ? 60 : 76;
                float x = [[[[UIDevice currentDevice] model] lowercaseString] rangeOfString:@"ipad"].location == NSNotFound ? 46 : 62;
                float y = -10;
                float a = 1.0f;
                UIColor *color = [UIColor redColor];
                
                NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jontelang.boover.plist"];
                NSLog(@"Loading and setting from PREFS FILE");
                NSLog(@"%@",prefs);
                if(prefs)
                {
                    if ( [prefs objectForKey:@"X"] && [prefs objectForKey:@"Y"] )
                    {
                        x = [[prefs valueForKey:@"X"] floatValue];
                        y = [[prefs valueForKey:@"Y"] floatValue];   
                    }
                    if( [prefs objectForKey:@"A"] )
                    {
                        a = [[prefs valueForKey:@"A"] floatValue];
                    }
                    if( [prefs objectForKey:@"C"] )
                    {
                        NSString *c = [prefs valueForKey:@"C"];
                        NSArray *comps = [c componentsSeparatedByString:@" "];
                        color = [UIColor colorWithRed:[comps[0] floatValue] green:[comps[1] floatValue] blue:[comps[2] floatValue] alpha:1];
                    }
                }


                [icon setFrame:CGRectMake(0, 0, w, w)];
                [icon setCenter:CGPointMake(160/2,160/2)];
                origin = icon.center;

                //badgeView = [[UIImageView alloc] initWithImage:[self imgWithColor:color]];
                //[badgeView setFrame:CGRectMake(x,y,24,24)];

                badgeView = [[UIView alloc] initWithFrame:CGRectMake(x,y,24,24)];
                badgeView.layer.cornerRadius = 12;
                badgeView.alpha = a;
                badgeView.backgroundColor = color;
                

                if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f){
                    [badgeView release];
                    badgeView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/booverpreferences.bundle/SBBadgeBG.png"]];
                    [badgeView setFrame:CGRectMake(x,y,29,31)];
                    badgeView.alpha = a;
                }

                [icon addSubview:badgeView];

                if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f){
                    UILabel *l = [[UILabel alloc] initWithFrame:badgeView.bounds];
                    l.text = @"7";
                    l.textColor = [UIColor whiteColor];
                    l.backgroundColor = [UIColor clearColor];
                    l.textAlignment = NSTextAlignmentCenter;
                    [badgeView addSubview:l];
                }
                
                UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
                [left addGestureRecognizer:pan];

                UIView* centerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,160)];
                [centerView addSubview:icon];
                [centerView addSubview:label];
                [centerView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
                [left addSubview:centerView];

    colorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 140)];
    colorPickerView.backgroundColor = [UIColor blackColor];
    colorPickerView.alpha = 0.75;
    colorPickerView.layer.cornerRadius = 5;
    colorPickerView.hidden = YES;
    [left addSubview:colorPickerView];

                UIView* sliderViewBgBg = [[UIView alloc] initWithFrame:CGRectMake(0,160,320,44)];
                sliderViewBgBg.backgroundColor = [UIColor whiteColor];
                if([[[[UIDevice currentDevice] model] lowercaseString] rangeOfString:@"ipad"].location != NSNotFound)sliderViewBgBg.layer.cornerRadius = 5;
                [left addSubview:sliderViewBgBg];

                [sliderViewBgBg setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                
            btn = [[UIView alloc] initWithFrame:CGRectMake(12, 12, 20, 20)];
            btn.backgroundColor = color;
            btn.layer.cornerRadius = 5;
            [sliderViewBgBg addSubview:btn];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(open)];
            [btn addGestureRecognizer:tap];

    
    NSArray* colors = @[
        [UIColor redColor],
        [UIColor greenColor],
        [UIColor blueColor],
        [UIColor yellowColor],
        [UIColor orangeColor],
        [UIColor purpleColor],
        [UIColor colorWithRed:150.0/255.0f green:150.0/255.0f blue:150.0/255.0f alpha:1],
        
        [UIColor colorWithRed:125.0/255.0f green:0 blue:0 alpha:1],
        [UIColor colorWithRed:0 green:125.0/255.0f blue:0 alpha:1],
        [UIColor colorWithRed:0 green:0 blue:125.0/255.0f alpha:1],
        [UIColor colorWithRed:109.0/255.0f green:242.0/255.0f blue:242.0/255.0f alpha:1],
        [UIColor colorWithRed:155.0/255.0f green:196.0/255.0f blue:222.0/255.0f alpha:1],
        [UIColor colorWithRed:255.0/255.0f green:173.0/255.0f blue:252.0/255.0f alpha:1],
        [UIColor colorWithRed:75.0/255.0f green:75.0/255.0f blue:75.0/255.0f alpha:1],
        
        [UIColor colorWithRed:50.0/255.0f green:0 blue:0 alpha:1], //Skip me
        [UIColor colorWithRed:0 green:50.0/255.0f blue:0 alpha:1],
        [UIColor colorWithRed:0 green:0 blue:50.0/255.0f alpha:1],
        [UIColor colorWithRed:191.0/255.0f green:157.0/255.0f blue:77.0/255.0f alpha:1],
        [UIColor colorWithRed:159.0/255.0f green:222.0/255.0f blue:155.0/255.0f alpha:1],
        [UIColor colorWithRed:178.0/255.0f green:150.0/255.0f blue:235.0/255.0f alpha:1],
        [UIColor colorWithRed:0 green:0 blue:0 alpha:1],
    ];
    
    // What the fuck am I doing.. 
    int xx = 12;
    int yy = 12;
    int cc = 0;
    for (int i = 0; i < [colors count]; i++) {
        if(i!=14){//...
            int size = 30;
            if(i==20){size=28;}
         UIView *temp = [[UIView alloc] initWithFrame:CGRectMake(xx, yy, size, size)];
         temp.backgroundColor = [colors objectAtIndex:i];
         temp.layer.cornerRadius = 5;
         if(i==20){temp.layer.borderWidth=1;temp.layer.borderColor=[UIColor darkGrayColor].CGColor;}
         [colorPickerView addSubview:temp];
        }
        xx += 30 + 10 + 1;
        cc ++;
        if(cc>=7){
            cc = 0;
            xx = 12;
            yy += 30 + 11 + 2;
        }
    }
    
    UITapGestureRecognizer *chosecolor = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pick:)];
    [colorPickerView addGestureRecognizer:chosecolor];

                slider = [[UISlider alloc] initWithFrame:CGRectMake(10+24+10, 160, 320-60, 44)];
                [slider setMaximumValue:1];
                [slider setMinimumValue:0];
                [slider setValue:a];
                [slider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [slider addTarget:self action:@selector(slider:) forControlEvents:UIControlEventValueChanged];
                [slider addTarget:self action:@selector(saveChanges) forControlEvents:(UIControlEventTouchUpOutside|UIControlEventTouchUpInside)];
                [self addSubview:slider];
        }
        return self;
}

-(void)pick:(UITapGestureRecognizer*)sender{
    int found = 0;
    for (int i = 0; i < [sender.view.subviews count]; i++) {
        if( CGRectContainsPoint(((UIView*)[sender.view.subviews objectAtIndex:i]).frame, [sender locationInView:sender.view]) ){
            btn.backgroundColor = ((UIView*)[sender.view.subviews objectAtIndex:i]).backgroundColor;
            badgeView.backgroundColor = btn.backgroundColor;
            found++;
            [self saveChanges]; // I hope people don't spam
            break;
        }
    }
    if(found==0){[self open];}
}


-(void)open{
    NSLog(@"openn");

    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
    {
        if(colorPickerView.hidden)
        {
            colorPickerView.alpha = 0;
            colorPickerView.hidden = NO;
            [UIView animateWithDuration:0.5f animations:^{
                colorPickerView.alpha = 1;
            }];
        }
        else if(!colorPickerView.hidden)
        {
            colorPickerView.alpha = 1;
            [UIView animateWithDuration:0.5f animations:^{
                colorPickerView.alpha = 0;
            }
            completion:^(BOOL finished){
                if(finished)
                    colorPickerView.hidden = YES;
            }];   
        }
    }
    else
    {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Warning" 
            message:@"Changing color is an iOS7+ only feature right now. You can still theme your badges with winterboard though!" 
            delegate:self 
            cancelButtonTitle:@"Ok" 
            otherButtonTitles:nil] autorelease];
        [alert show];
    }
}

-(void)slider:(id)sender
{
    badgeView.alpha = slider.value;
}

-(void)update
{ 
    NSLog(@"Update in hear");
    [badgeView setFrame:CGRectMake(badgeView.frame.origin.x,
                                   badgeView.frame.origin.y,
                                   44,
                                   44)];
}

- (float)preferredHeightForWidth:(float)arg1
{
    // Return a custom cell height.
    if([[[[UIDevice currentDevice] model] lowercaseString] rangeOfString:@"ipad"].location != NSNotFound){
        return 160+44+35;
    }

    return 160.0f + 44.0f;
}

-(void)pan:(UIPanGestureRecognizer*)rec
{
    if(!colorPickerView.hidden){[self open];} // Don't mind me.

    CGPoint current = [rec locationInView:rec.view];

    if(current.y < 160)
    {
        if (rec.state==UIGestureRecognizerStateBegan)
        {
            startPoint = [rec locationInView:rec.view];
            origin = badgeView.center;
        }
        else if(rec.state==UIGestureRecognizerStateChanged)
        {
            CGPoint currentPoint = [rec locationInView:rec.view];
            CGPoint offset = CGPointMake(currentPoint.x-startPoint.x, currentPoint.y-startPoint.y);
            [badgeView setCenter:CGPointMake(origin.x+offset.x/4, origin.y+offset.y/2)];
        }
    }
    
    if(rec.state==UIGestureRecognizerStateEnded)
    {
        [self saveChanges];
    }
}

-(void)saveChanges
{
    NSLog(@"Save!");
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jontelang.boover.plist"];
    if(!prefs){
        prefs = [[NSMutableDictionary alloc] init];
    }
    [prefs setValue:[NSNumber numberWithFloat:badgeView.frame.origin.x]   forKey:@"tempX"];
    [prefs setValue:[NSNumber numberWithFloat:badgeView.frame.origin.y]   forKey:@"tempY"];
    [prefs setValue:[NSNumber numberWithFloat:slider.value]               forKey:@"tempA"];

    // Get the colors
    CGFloat r,g,b,a;
    [badgeView.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    [prefs setValue:[NSString stringWithFormat:@"%f %f %f",r,g,b] forKey:@"tempC"];

    [prefs writeToFile:@"/var/mobile/Library/Preferences/com.jontelang.boover.plist" atomically:YES];
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    return [UIImage imageWithCGImage:masked];
    
}

// - (UIImage *) imgWithColor:(UIColor*)color
// {
//     // Create a temporary red view
//     UIView *bv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
//     bv.backgroundColor = color;
//     bv.layer.cornerRadius = 12;

//     UILabel *l = [[UILabel alloc] initWithFrame:bv.bounds];
//     l.text = @"7";
//     l.textColor = [UIColor whiteColor];
//     l.textAlignment = NSTextAlignmentCenter;
//     [bv addSubview:l];
    
//     // Start a new image context
//     UIGraphicsBeginImageContextWithOptions(bv.bounds.size, NO, 0.0);
    
//     // // Copy view into an image
//     [bv.layer renderInContext:UIGraphicsGetCurrentContext()];
    
//     // // load the image
//     UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
//     // // Step one done
//     UIGraphicsEndImageContext();
    
//     // // Begin a new image context, to draw our colored image onto
//     // UIGraphicsBeginImageContextWithOptions(img.size, NO, [UIScreen mainScreen].scale);
    
//     // // get a reference to that context we created
//     // CGContextRef context = UIGraphicsGetCurrentContext();
    
//     // // translate/flip the graphics context (for transforming from CG* coords to UI* coords
//     // CGContextTranslateCTM(context, 0, img.size.height);
//     // CGContextScaleCTM(context, 1.0, -1.0);
    
//     // // ??
//     // CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    
//     // // First make white
//     // [[UIColor whiteColor] setFill];
    
//     // // set the blend mode to color burn, and the original image
//     // CGContextSetBlendMode(context, kCGBlendModeNormal);
//     // CGContextDrawImage(context, rect, img.CGImage);

//     // // First make then new
//     // [color setFill];
    
//     // // set the blend mode to color burn, and the original image
//     // CGContextSetBlendMode(context, kCGBlendModeLighten);
//     // CGContextDrawImage(context, rect, img.CGImage);
    
//     // // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
//     // CGContextClipToMask(context, rect, img.CGImage);
//     // CGContextAddRect(context, rect);
//     // CGContextDrawPath(context,kCGPathFill);
    
//     // // generate a new UIImage from the graphics context we drew onto
//     // UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    
//     // // Fin.
//     // UIGraphicsEndImageContext();
    
//     return img;
// }
@end