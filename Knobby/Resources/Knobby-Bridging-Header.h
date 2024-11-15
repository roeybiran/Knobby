// from: https://github.com/cmsj/Hammertime/blob/c8b302cc622d44626a55139f20833467196312e4/Hammertime/Headers/Private-CoreGraphics.h

#import <AppKit/AppKit.h>

#ifndef DisplayServicesBridge_h
#define DisplayServicesBridge_h

int DisplayServicesGetBrightness(CGDirectDisplayID display, float *brightness);
int DisplayServicesSetBrightness(CGDirectDisplayID display, float brightness);

#endif
