#include "_own_/Preferences5/Preferences.h"

@interface MoveCell : PSTableCell <PreferencesTableCustomView> {
    CGPoint startPoint;
    CGPoint origin;
    UIView *badgeView;
    UISlider* slider;
    float percent;
}
@end

@implementation MoveCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    NSLog(@"SPECIFIER: %@", specifier);

        self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
        if (self) {

                percent = 1.0f;

                self.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];

                [self setAutoresizesSubviews:YES];
                [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

                float width = 320;
    
                UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 160+44)];
                left.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
                [left setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [self addSubview:left];

                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(160,0,160,160)];
                [label setText:@"Drag here"];
                [label setTextAlignment:NSTextAlignmentCenter];
                [label setTextColor:[UIColor lightGrayColor]];
                
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
                        percent = a;
                    }
                }


                [icon setFrame:CGRectMake(0, 0, w, w)];
                [icon setCenter:CGPointMake(160/2,160/2)];
                origin = icon.center;

                badgeView = [[UIView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                badgeView.backgroundColor = [UIColor redColor];
                badgeView.layer.cornerRadius = 12;
                badgeView.alpha = a;
                [icon addSubview:badgeView];
                
                UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
                [left addGestureRecognizer:pan];

                UIView* centerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,160)];
                [centerView addSubview:icon];
                [centerView addSubview:label];
                [centerView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
                [left addSubview:centerView];

                UIView* sliderViewBgBg = [[UIView alloc] initWithFrame:CGRectMake(0,160,320,44)];
                sliderViewBgBg.backgroundColor = [UIColor whiteColor];
                if([[[[UIDevice currentDevice] model] lowercaseString] rangeOfString:@"ipad"].location != NSNotFound)sliderViewBgBg.layer.cornerRadius = 5;
                [left addSubview:sliderViewBgBg];

                [sliderViewBgBg setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                
                slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 160, 320-40, 44)];
                [slider setMaximumValue:1];
                [slider setMinimumValue:0];
                [slider setValue:percent];
                [slider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [slider addTarget:self action:@selector(slider:) forControlEvents:UIControlEventValueChanged];
                [slider addTarget:self action:@selector(saveChanges) forControlEvents:(UIControlEventTouchUpOutside|UIControlEventTouchUpInside)];
                [self addSubview:slider];
        }
        return self;
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

-(void)pan:(UIPanGestureRecognizer*)rec{
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
@end