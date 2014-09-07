#include "_own_/Preferences5/Preferences.h"
#import <Foundation/Foundation.h>


@interface ColorDisplayCell : PSTableCell <PreferencesTableCustomView> {
}
@end

@implementation ColorDisplayCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        
        [self updateColor];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateColor)];
        [self addGestureRecognizer:tap];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateColor) name:@"com.jontelang.boover" object:nil];

        NSLog(@"Creating new ColorDisplayCell");
    }
    return self;
}

-(void)updateColor{
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jontelang.boover.plist"];
    if(prefs){
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
        self.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1];
    }
}

- (CGFloat)preferredHeightForWid//th:(CGFloat)arg1
//- (float)preferredHeightForWidth:(float)arg1
{
    return 40;
}

@end