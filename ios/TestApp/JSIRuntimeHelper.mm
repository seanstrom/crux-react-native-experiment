// JSIRuntimeHelper.mm
#import "JSIRuntimeHelper.h"
#import <React/RCTBridge+Private.h>
#import <jsi/jsi.h>
#import <cxxreact/CxxModule.h>
#import <RCTAppDelegate.h>
#import "TestApp-Swift.h"

using namespace facebook;
using namespace facebook::jsi;

static void bridgePlatformFunctions(jsi::Runtime &jsi) {
  auto getDeviceName = Function::createFromHostFunction(jsi,
                                                        PropNameID::forAscii(jsi, "getDeviceName"),
                                                        0,
                                                        [](Runtime &runtime,
                                                           const Value &thisValue,
                                                           const Value *arguments,
                                                           size_t count) -> Value {

    return String::createFromUtf8(runtime, [[[UIDevice currentDevice] name] UTF8String]);
  });
  
  NSLog(@"installJSIBindingsWithRuntime called");
  auto greet = [](jsi::Runtime &runtime, const jsi::Value &thisValue,
                  const jsi::Value *args, size_t count) -> jsi::Value {
    // Check for the correct argument count and type
    if (count != 1 || !args[0].isString()) {
      throw jsi::JSError(runtime, "Expected one string argument");
    }
    
    // Extract the argument and create a response
    std::string name = args[0].asString(runtime).utf8(runtime);
    std::string greeting = "Hello, " + name + "!";
    
    // Return the response as a JSI string
    return jsi::String::createFromUtf8(runtime, greeting);
  };
  
  auto view = [](jsi::Runtime &runtime, const jsi::Value &thisValue,
                  const jsi::Value *args, size_t count) -> jsi::Value {
    
    EventProcessor *processor = [[EventProcessor alloc] init];
    NSData *response = [processor viewModel];
    
    const uint8_t *dataBytes = (const uint8_t *)[response bytes];
    size_t responseLength = [response length];
    
    // Create a new ArrayBuffer in JSI
    auto responseArrayBuffer = runtime.global()
      .getPropertyAsFunction(runtime, "ArrayBuffer")
      .callAsConstructor(runtime, static_cast<int>(responseLength))
      .getObject(runtime)
      .getArrayBuffer(runtime);
    
    // Copy NSData bytes into the ArrayBuffer
    memcpy(responseArrayBuffer.data(runtime), dataBytes, responseLength);
    
    jsi::Function uint8ArrayConstructor = runtime.global().getPropertyAsFunction(runtime, "Uint8Array");
    jsi::Object uint8Array = uint8ArrayConstructor.callAsConstructor(runtime, responseArrayBuffer).getObject(runtime);
    
    return jsi::Value(std::move(uint8Array));
  };

  
  auto processEvent = [](jsi::Runtime &runtime, const jsi::Value &thisValue,
                  const jsi::Value *args, size_t count) -> jsi::Value {
    // Extract the argument and create a response
    jsi::Object object = args[0].asObject(runtime);
    
    if (object.hasProperty(runtime, "buffer")) {
      jsi::Value bufferValue = object.getProperty(runtime, "buffer");
      
      if (bufferValue.isObject() && bufferValue.asObject(runtime).isArrayBuffer(runtime)) {
        jsi::ArrayBuffer arrayBuffer = bufferValue.asObject(runtime).getArrayBuffer(runtime);
        
        const uint8_t* data = arrayBuffer.data(runtime);
        size_t length = arrayBuffer.size(runtime);
        
        NSData *nsData = [NSData dataWithBytes:data length:length];
        EventProcessor *processor = [[EventProcessor alloc] init];
        NSData *response = [processor processWithPayload:nsData];
        
        const uint8_t *dataBytes = (const uint8_t *)[response bytes];
        size_t responseLength = [response length];
        
        // Create a new ArrayBuffer in JSI
        auto responseArrayBuffer = runtime.global()
          .getPropertyAsFunction(runtime, "ArrayBuffer")
          .callAsConstructor(runtime, static_cast<int>(responseLength))
          .getObject(runtime)
          .getArrayBuffer(runtime);
        
        // Copy NSData bytes into the ArrayBuffer
        memcpy(responseArrayBuffer.data(runtime), dataBytes, responseLength);
       
        jsi::Function uint8ArrayConstructor = runtime.global().getPropertyAsFunction(runtime, "Uint8Array");
        jsi::Object uint8Array = uint8ArrayConstructor.callAsConstructor(runtime, responseArrayBuffer).getObject(runtime);
        
        return jsi::Value(std::move(uint8Array));
      } else {
        throw jsi::JSError(runtime, "Expected an ArrayBuffer");
      }
    } else {
        throw jsi::JSError(runtime, "Expected an ArrayBuffer");
    }
  };
  
  jsi::Function greetFunction = jsi::Function::createFromHostFunction(jsi, jsi::PropNameID::forAscii(jsi, "greet"), 1, greet);
  jsi::Function viewFunction = jsi::Function::createFromHostFunction(jsi, jsi::PropNameID::forAscii(jsi, "view"), 1, view);
  jsi::Function processEventFunction = jsi::Function::createFromHostFunction(jsi, jsi::PropNameID::forAscii(jsi, "processEvent"), 1, processEvent);
  
  jsi.global().setProperty(jsi, "greet", std::move(greetFunction));
  jsi.global().setProperty(jsi, "getDeviceName", std::move(getDeviceName));
  jsi.global().setProperty(jsi, "processEvent", std::move(processEventFunction));
  jsi.global().setProperty(jsi, "view", std::move(viewFunction));
}


@implementation JSIRuntimeHelper

+ (void)installJSIHelpers:(RCTBridge*)bridge {
  RCTCxxBridge* cxxBridge = (RCTCxxBridge*)bridge;
  jsi::Runtime *runtime = (jsi::Runtime *) cxxBridge.runtime;
  bridgePlatformFunctions(*runtime);
}

@end

