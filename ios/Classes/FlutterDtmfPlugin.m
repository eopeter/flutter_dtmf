#import "FlutterDtmfPlugin.h"
#import <flutter_dtmf/flutter_dtmf-Swift.h>

@implementation FlutterDtmfPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterDtmfPlugin registerWithRegistrar:registrar];
}
@end
