import Foundation
import SharedTypes

@objc class EventProcessor: NSObject {
  @objc func process(payload: Data) -> Data {
    let bytes = [UInt8](payload as Data)
    let event: Event = try! .bincodeDeserialize(input: bytes)
    print(event)
    let effects = [UInt8](processEvent(payload))
    let requests: [Request] = try! .bincodeDeserialize(input: effects)
    for request in requests {
        print(request)
    }
    return Data(effects)
  }
  
  @objc func viewModel() -> Data {
    let viewModel = [UInt8](view())
    return Data(viewModel)
  }
}
