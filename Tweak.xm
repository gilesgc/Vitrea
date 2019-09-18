#import <substrate.h>
#import "Tweak.h"

@implementation CustomizableUIBlur
+ (instancetype)effectWithStyle:(UIBlurEffectStyle)style {
	id result = [super effectWithStyle:style];
	object_setClass(result, self);

	return result;
}
- (id)effectSettings {
	id settings = [super effectSettings];
	[settings setValue:@5 forKey:@"blurRadius"];
	return settings;
}
@end

static SBFStaticWallpaperView *homescreenWallpaper;
static _SBWallpaperWindow *wallpaperWindow;

static UIVisualEffectView *blurView;
static BOOL blurViewAdded = NO;

%hook _SBWallpaperWindow

-(void)layoutSubviews {
	%orig;

	wallpaperWindow = self;
	[self setBackgroundColor:[UIColor clearColor]];
}

%end

%hook SBFStaticWallpaperView
-(id)initWithFrame:(CGRect)arg1 wallpaperImage:(id)arg2 cacheGroup:(id)arg3 variant:(long long)variant options:(unsigned long long)arg5 wallpaperSettingsProvider:(id)arg6{
	id wallpaperView = %orig;

	if([[self variantCacheIdentifier] isEqualToString:@"home"] || [[self variantCacheIdentifier] isEqualToString:@"shared"])
		homescreenWallpaper = wallpaperView;

	return wallpaperView;
}

-(void)setHidden:(BOOL)arg1 {
	if(homescreenWallpaper && self == homescreenWallpaper)
		%orig(NO);
	else
		%orig(YES);
}

-(void)setAlpha:(CGFloat)arg1 {
	if(homescreenWallpaper && self == homescreenWallpaper)
		%orig(1.0);
	else
		%orig;
}
%end

%hook UIWindow

-(void)setWindowLevel:(double)arg1 {
	if(wallpaperWindow && self == wallpaperWindow)
		%orig(-3.0);
	else
		%orig;
}

%end

%hook _SBFakeBlurView

-(void)didMoveToWindow {
	%orig;

	if([NSStringFromClass([[self window] class]) isEqualToString:@"SBCoverSheetWindow"])
		[self setHidden:YES];
}

%end

%hook SBCoverSheetBlurView

-(void)layoutSubviews {
	%orig;
	[self setHidden:YES];

	//Add blur view
	if(blurViewAdded)
		return;
	
	UIView *superview = [self superview];

	blurView = [[UIVisualEffectView alloc] initWithEffect:[CustomizableUIBlur effectWithStyle:UIBlurEffectStyleDark]];
	[blurView setFrame:[superview bounds]];
	[superview addSubview:blurView];
	[superview sendSubviewToBack:blurView];

	blurViewAdded = YES;
}

%end

%hook SBCoverSheetPositionView

- (void)setProgress:(CGFloat)progress {
	%orig;
	
	//Unblur as user swipes up
	[blurView setAlpha:(1.0 - progress)];
}

%end