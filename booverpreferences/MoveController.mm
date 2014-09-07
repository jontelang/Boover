#import <Preferences/Preferences.h>


@interface PSListController (ddd)
-(void)loadView;
-(void)viewDidLoad;
-(void)setView:(UIView*)v;
@end

@interface MoveController : PSListController <UIAlertViewDelegate> {
	CGPoint startPoint;
    CGPoint origin;
    UIView *badgeView;
    UISlider* slider;
    UISlider *sliderSize;
    UISlider *sliderRadius;
    UISlider *sliderRotate;
    UIView *left;
    UIView *btn;
    UIView *colorPickerView;
    UILabel *badgeLabel;
    float space;
}
//-(void)build;
//-(void)pick:(UITapGestureRecognizer*)sender;
@end

@implementation MoveController

-(void)loadView
{
	NSLog(@"LOADVIEW");
	[super loadView];
		CGRect viewRect = [UIScreen mainScreen].bounds;
		UIView *tempView = [[UIView alloc] initWithFrame:viewRect];
		//tempView.backgroundColor = [UIColor colorWithRed:0.85f green:0.86f blue:0.89f alpha:1.00f];
		tempView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
		//tempView.backgroundColor = [UIColor whiteColor];
		tempView.clipsToBounds = YES;
		//tempView.layer.borderWidth = 2;
		//tempView.layer.borderColor = [UIColor greenColor].CGColor;
		self.view = tempView;
		[self.view setAutoresizesSubviews:YES];
		[self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		
		float ios7_offset = [[UIDevice currentDevice].systemVersion floatValue] >= 7 ? 64 : 0;
		space = 35;
		ios7_offset += space;
		//float size = 40;

		NSLog(@"build stuff");


				// Defaults
                float w = [[[[UIDevice currentDevice] model] lowercaseString] rangeOfString:@"ipad"].location == NSNotFound ? 60 : 76;
                float x = [[[[UIDevice currentDevice] model] lowercaseString] rangeOfString:@"ipad"].location == NSNotFound ? 46 : 62;
                float y = -10;
                float alpha = 1;
                float radius = 1;
                float degrees = 0;
                float size = 24;
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
                    if( [prefs objectForKey:@"Alpha"] )
                    {
                        alpha = [[prefs valueForKey:@"Alpha"] floatValue];
                    }
                    // if( [prefs objectForKey:@"Color"] )
                    // {
                    //     NSString *c = [prefs valueForKey:@"Color"];
                    //     NSArray *comps = [c componentsSeparatedByString:@" "];
                    //     color = [UIColor colorWithRed:[comps[0] floatValue] green:[comps[1] floatValue] blue:[comps[2] floatValue] alpha:1];
                    // }
                    float r = 0;
                    float g = 0;
                    float b = 0;
                    if ( [prefs objectForKey:@"Red"] ){
                        r = [[prefs valueForKey:@"Red"] floatValue] / 255.0f;
                    }
                    if ( [prefs objectForKey:@"Green"] ){
                        g = [[prefs valueForKey:@"Green"] floatValue] / 255.0f;
                    }
                    if ( [prefs objectForKey:@"Blue"] ){
                        b = [[prefs valueForKey:@"Blue"] floatValue] / 255.0f;
                    }
                    color = [UIColor colorWithRed:r green:g blue:b alpha:1];

                    if( [prefs objectForKey:@"Size"] )
                    {
                        size = [[prefs valueForKey:@"Size"] floatValue];
                    }
                    if( [prefs objectForKey:@"Radius"] )
                    {
                        radius = [[prefs valueForKey:@"Radius"] floatValue];
                    }
                    if( [prefs objectForKey:@"Degrees"] )
                    {
                        degrees = [[prefs valueForKey:@"Degrees"] floatValue];
                    }
                }

                
                float width = viewRect.size.width;
    
                left = [[UIView alloc] initWithFrame:CGRectMake(0, ios7_offset, width, 160+7+43.5+43.5)]; //lol
                left.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
                left.backgroundColor = [UIColor whiteColor];
                [left setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [self.view addSubview:left];

                UIView* centerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,w*2,160)];
                [centerView setCenter:CGPointMake(viewRect.size.width/2,160/2)];
                [centerView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin)];
                [left addSubview:centerView];
                
                UIImageView *icon = [[UIImageView alloc] initWithImage:
                                                            [self maskImage:
                                                                    [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/booverpreferences.bundle/i.png"] 
                                                                withMask:
                                                                    [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/booverpreferences.bundle/m.png"]]];

                


                [icon setFrame:CGRectMake(-w/2, (160/2)-(w/2), w, w)];
                [icon setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin)];
                origin = icon.center;


                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(w,(160/2)-(w/2),w+w,w)];
                [label setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin)];
                [label setText:@"Drag here"];
                [label setTextAlignment:NSTextAlignmentCenter];
                [label setTextColor:[UIColor lightGrayColor]];
                label.backgroundColor = [UIColor clearColor];

                //badgeView = [[UIImageView alloc] initWithImage:[self imgWithColor:color]];
                //[badgeView setFrame:CGRectMake(x,y,24,24)];

                badgeView = [[UIView alloc] initWithFrame:CGRectMake(x,y,size,size)];
                badgeView.layer.cornerRadius = radius;
                badgeView.alpha = 1;
                badgeView.backgroundColor = color;

				badgeView.transform = CGAffineTransformIdentity;
			    badgeView.transform = CGAffineTransformMakeRotation(degrees * M_PI/180);

                if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f){
                    [badgeView release];
                    badgeView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/booverpreferences.bundle/SBBadgeBG.png"]];
                    [badgeView setFrame:CGRectMake(x,y,29,31)];
                    badgeView.alpha = alpha;
                }

                [icon addSubview:badgeView];


                [centerView addSubview:icon];
                [centerView addSubview:label];

                if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f){
                    badgeLabel = [[UILabel alloc] initWithFrame:badgeView.bounds];
                    badgeLabel.text = @"7";
                    badgeLabel.textColor = [UIColor whiteColor];
                    badgeLabel.backgroundColor = [UIColor clearColor];
                    badgeLabel.textAlignment = NSTextAlignmentCenter;
                    [badgeView addSubview:badgeLabel];
                }
                
                UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
                [left addGestureRecognizer:pan];

                

    // colorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 44+10, 300, 140)];
    // colorPickerView.backgroundColor = [UIColor blackColor];
    // colorPickerView.alpha = 0.75;
    // colorPickerView.layer.cornerRadius = 5;
    // colorPickerView.hidden = YES;
    // [left addSubview:colorPickerView];

                UIView* sliderViewBgBg = [[UIView alloc] initWithFrame:CGRectMake(0,0,viewRect.size.width,44)];
                sliderViewBgBg.backgroundColor = [UIColor whiteColor];
                if([[[[UIDevice currentDevice] model] lowercaseString] rangeOfString:@"ipad"].location != NSNotFound)sliderViewBgBg.layer.cornerRadius = 5;
                [sliderViewBgBg setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                // [left addSubview:sliderViewBgBg];

                [sliderViewBgBg setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                
    //         btn = [[UIView alloc] initWithFrame:CGRectMake(12, 12, 20, 20)];
    //         btn.backgroundColor = color;
    //         btn.layer.cornerRadius = 5;
    //         [sliderViewBgBg addSubview:btn];
            
    //         UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(open)];
    //         [btn addGestureRecognizer:tap];

    
    // NSArray* colors = @[
    //     [UIColor redColor],
    //     [UIColor greenColor],
    //     [UIColor blueColor],
    //     [UIColor yellowColor],
    //     [UIColor orangeColor],
    //     [UIColor purpleColor],
    //     [UIColor colorWithRed:150.0/255.0f green:150.0/255.0f blue:150.0/255.0f alpha:1],
        
    //     [UIColor colorWithRed:125.0/255.0f green:0 blue:0 alpha:1],
    //     [UIColor colorWithRed:0 green:125.0/255.0f blue:0 alpha:1],
    //     [UIColor colorWithRed:0 green:0 blue:125.0/255.0f alpha:1],
    //     [UIColor colorWithRed:109.0/255.0f green:242.0/255.0f blue:242.0/255.0f alpha:1],
    //     [UIColor colorWithRed:155.0/255.0f green:196.0/255.0f blue:222.0/255.0f alpha:1],
    //     [UIColor colorWithRed:255.0/255.0f green:173.0/255.0f blue:252.0/255.0f alpha:1],
    //     [UIColor colorWithRed:75.0/255.0f green:75.0/255.0f blue:75.0/255.0f alpha:1],
        
    //     [UIColor colorWithRed:50.0/255.0f green:0 blue:0 alpha:1], //Skip me
    //     [UIColor colorWithRed:0 green:50.0/255.0f blue:0 alpha:1],
    //     [UIColor colorWithRed:0 green:0 blue:50.0/255.0f alpha:1],
    //     [UIColor colorWithRed:191.0/255.0f green:157.0/255.0f blue:77.0/255.0f alpha:1],
    //     [UIColor colorWithRed:159.0/255.0f green:222.0/255.0f blue:155.0/255.0f alpha:1],
    //     [UIColor colorWithRed:178.0/255.0f green:150.0/255.0f blue:235.0/255.0f alpha:1],
    //     [UIColor colorWithRed:0 green:0 blue:0 alpha:1],
    // ];
    
    // // What the fuck am I doing.. 
    // int xx = 12;
    // int yy = 12;
    // int cc = 0;
    // for (int i = 0; i < [colors count]; i++) {
    //     if(i!=14){//...
    //         int size = 30;
    //         if(i==20){size=28;}
    //      UIView *temp = [[UIView alloc] initWithFrame:CGRectMake(xx, yy, size, size)];
    //      temp.backgroundColor = [colors objectAtIndex:i];
    //      temp.layer.cornerRadius = 5;
    //      if(i==20){temp.layer.borderWidth=1;temp.layer.borderColor=[UIColor darkGrayColor].CGColor;}
    //      [colorPickerView addSubview:temp];
    //     }
    //     xx += 30 + 10 + 1;
    //     cc ++;
    //     if(cc>=7){
    //         cc = 0;
    //         xx = 12;
    //         yy += 30 + 11 + 2;
    //     }
    // }
    
    // UITapGestureRecognizer *chosecolor = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pick:)];
    // [colorPickerView addGestureRecognizer:chosecolor];

                // slider = [[UISlider alloc] initWithFrame:CGRectMake(10+24+10, 0, viewRect.size.width-60, 44)];
                // [slider setMaximumValue:1];
                // [slider setMinimumValue:0];
                // [slider setValue:alpha];
                // [slider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                // [slider addTarget:self action:@selector(sliderAlpha:) forControlEvents:UIControlEventValueChanged];
                // [slider addTarget:self action:@selector(saveChanges) forControlEvents:(UIControlEventTouchUpOutside|UIControlEventTouchUpInside)];
                // [sliderViewBgBg addSubview:slider];

                sliderSize = [[UISlider alloc] initWithFrame:CGRectMake(10, 160+7, viewRect.size.width-20, 44)];
                [sliderSize setMaximumValue:72];
                // [sliderSize setMinimumValue:24];
                // [sliderSize setMinimumValue:12];
                [sliderSize setValue:size]; // s
                [sliderSize setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [sliderSize addTarget:self action:@selector(sliderSize:) forControlEvents:UIControlEventValueChanged];
                [sliderSize addTarget:self action:@selector(saveChanges) forControlEvents:(UIControlEventTouchUpOutside|UIControlEventTouchUpInside)];
                [left addSubview:sliderSize];

                sliderRadius = [[UISlider alloc] initWithFrame:CGRectMake(10, 160+7+43.5, viewRect.size.width-20, 44)];
                [sliderRadius setMaximumValue:1];
                [sliderRadius setMinimumValue:0];
                [sliderRadius setValue:radius]; // s
                [sliderRadius setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [sliderRadius addTarget:self action:@selector(sliderCorners:) forControlEvents:UIControlEventValueChanged];
                [sliderRadius addTarget:self action:@selector(saveChanges) forControlEvents:(UIControlEventTouchUpOutside|UIControlEventTouchUpInside)];
                [left addSubview:sliderRadius];

                // sliderRotate = [[UISlider alloc] initWithFrame:CGRectMake(10+24+10, 43.5+160+7+43.5+43.5, viewRect.size.width-60, 44)];
                // [sliderRotate setMaximumValue:360];
                // [sliderRotate setMinimumValue:0];
                // [sliderRotate setValue:degrees]; // s
                // [sliderRotate setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                // [sliderRotate addTarget:self action:@selector(sliderRotate:) forControlEvents:UIControlEventValueChanged];
                // [sliderRotate addTarget:self action:@selector(saveChanges) forControlEvents:(UIControlEventTouchUpOutside|UIControlEventTouchUpInside)];
                //[left addSubview:sliderRotate];

                //sliderViewBgBg.layer.borderWidth = 1;
                //centerView.layer.borderWidth = 1;
                //left.layer.borderWidth = 1;

                // Borders
                UIColor *borderColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0];
                UIView *border1 = [[UIView alloc] initWithFrame:CGRectMake(0,0,viewRect.size.width,0.5)];
                border1.backgroundColor = borderColor;
                [border1 setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [left addSubview:border1];
                
                // UIView *border2 = [[UIView alloc] initWithFrame:CGRectMake(0,43.5,viewRect.size.width,0.5)];
                // border2.backgroundColor = borderColor;
                // [border2 setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                // [sliderViewBgBg addSubview:border2];
                
                UIView *border3 = [[UIView alloc] initWithFrame:CGRectMake(0,160+7,viewRect.size.width,0.5)];
                border3.backgroundColor = borderColor;
                [border3 setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [left addSubview:border3];

                UIView *border4 = [[UIView alloc] initWithFrame:CGRectMake(0,160+7+44,viewRect.size.width,0.5)];
                border4.backgroundColor = borderColor;
                [border4 setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [left addSubview:border4];

                UIView *border5 = [[UIView alloc] initWithFrame:CGRectMake(0,160+7+44+43,viewRect.size.width,0.5)];
                border5.backgroundColor = borderColor;
                [border5 setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [left addSubview:border5];

                //left.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2f];
                //fsliderSize.userInteractionEnabled = YES;

        NSLog(@"done building");

        [self sliderRotate:nil];
        [self s];
}

// -(void)open
// {
//     NSLog(@"openn");

//     if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
//     {
//         if(colorPickerView.hidden)
//         {
//             colorPickerView.alpha = 0;
//             colorPickerView.hidden = NO;
//             [UIView animateWithDuration:0.5f animations:^{
//                 colorPickerView.alpha = 1;
//             }];
//         }
//         else if(!colorPickerView.hidden)
//         {
//             colorPickerView.alpha = 1;
//             [UIView animateWithDuration:0.5f animations:^{
//                 colorPickerView.alpha = 0;
//             }
//             completion:^(BOOL finished){
//                 if(finished)
//                     colorPickerView.hidden = YES;
//             }];   
//         }
//     }
//     else
//     {
//         UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil 
//             message:@"Changing color is an iOS7+ only feature right now. You can still theme your badges with winterboard though!" 
//             delegate:self 
//             cancelButtonTitle:@"Ok" 
//             otherButtonTitles:nil] autorelease];
//         [alert show];
//     }
// }

// -(void)pick:(UITapGestureRecognizer*)sender{
//     int found = 0;
//     for (int i = 0; i < [sender.view.subviews count]; i++) {
//         if( CGRectContainsPoint(((UIView*)[sender.view.subviews objectAtIndex:i]).frame, [sender locationInView:sender.view]) ){
//             btn.backgroundColor = ((UIView*)[sender.view.subviews objectAtIndex:i]).backgroundColor;
//             badgeView.backgroundColor = btn.backgroundColor;
//             found++;
//             [self saveChanges]; // I hope people don't spam
//             break;
//         }
//     }
//     if(found==0){[self open];}
// }


-(void)sliderAlpha:(id)sender
{
    //badgeView.alpha = slider.value;
}

-(void)sliderSize:(id)sender
{
	[self s];
}

-(void)sliderCorners:(id)sender
{
	[self s];
}

-(void)sliderRotate:(id)sender
{
	badgeView.transform = CGAffineTransformIdentity;
    badgeView.transform = CGAffineTransformMakeRotation(sliderRotate.value * M_PI/180);
    NSLog(@"cornerDegrees: %f",sliderRotate.value);
}

-(void)s
{	
	CGAffineTransform savedTransform = badgeView.transform;

	badgeView.transform = CGAffineTransformIdentity;

	CGPoint center   = badgeView.center; 
	CGRect rect      = badgeView.frame;
	rect.size.width  = sliderSize.value;
	rect.size.height = sliderSize.value;
	[badgeView setFrame:rect];
    [badgeView setCenter:center];
    [badgeLabel setFrame:badgeView.bounds];

    badgeView.layer.cornerRadius = (sliderSize.value/2)*sliderRadius.value;
    NSLog(@"cornerRadius: %f",badgeView.layer.cornerRadius);
    NSLog(@"cornerSize: %f",sliderSize.value);

    badgeView.transform = savedTransform;
}

-(void)update
{ 
    NSLog(@"Update in hear");
    [badgeView setFrame:CGRectMake(badgeView.frame.origin.x,
                                   badgeView.frame.origin.y,
                                   44,
                                   44)];
}

-(void)pan:(UIPanGestureRecognizer*)rec
{
    //if(!colorPickerView.hidden){[self open];} // Don't mind me.

    CGPoint current = [rec locationInView:rec.view];

    if(current.y > 44 && current.y < 44+160)
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
            [badgeView setCenter:CGPointMake(origin.x+offset.x/5, origin.y+offset.y/5)];
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
    [prefs setValue:[NSNumber numberWithFloat:badgeView.frame.origin.x]     forKey:@"tempX"];
    [prefs setValue:[NSNumber numberWithFloat:badgeView.frame.origin.y]     forKey:@"tempY"];
    [prefs setValue:[NSNumber numberWithFloat:1.0]                          forKey:@"tempAlpha"];
    [prefs setValue:[NSNumber numberWithFloat:sliderSize.value]             forKey:@"tempSize"];
    [prefs setValue:[NSNumber numberWithFloat:sliderRadius.value]  			forKey:@"tempRadius"];
    [prefs setValue:[NSNumber numberWithFloat:sliderRotate.value]           forKey:@"tempDegrees"];

    // Get the colors
    // CGFloat r,g,b,a;
    // [badgeView.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    // [prefs setValue:[NSString stringWithFormat:@"%f %f %f",r,g,b] forKey:@"tempColor"];

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

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"MoveController" target:self] retain];
		NSLog(@"specifiers");
	}
	return _specifiers;
}




@end

// vim:ft=objc
