#import "DtmfPlugin.h"
#import <flutter_dtmf/flutter_dtmf-Swift.h>

@implementation DtmfPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDtmfPlugin registerWithRegistrar:registrar];
}
@end
