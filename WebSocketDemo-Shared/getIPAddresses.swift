import Foundation
import Network

/**
 Get all IP addresses for the host across all network interfaces

 Adapted from:
 - https://stackoverflow.com/a/73853838/23649
 - https://stackoverflow.com/q/62041244/23649
 */
func getIPAddresses() -> [IPAddress] {
  var interfaces: UnsafeMutablePointer<ifaddrs>?
  guard getifaddrs(&interfaces) == 0, let interfaces else {
    return []
  }
  defer {
    freeifaddrs(interfaces)
  }

  var result: [IPAddress] = []
  for interfacePtr in sequence(first: interfaces, next: { $0.pointee.ifa_next }) {
    let interface = interfacePtr.pointee

    let interfaceName = String(cString: interface.ifa_name)
    let addrFamily = interface.ifa_addr.pointee.sa_family
    guard addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) else {
      continue
    }

    var addressCString = [CChar](repeating: 0, count: Int(NI_MAXHOST))
    let err = getnameinfo(
      interface.ifa_addr,
      socklen_t(interface.ifa_addr.pointee.sa_len),
      &addressCString,
      socklen_t(addressCString.count),
      nil,
      socklen_t(0),
      NI_NUMERICHOST | NI_NUMERICSERV
    )
    if err != 0 {
      print("Error in getnameinfo: \(String(cString: gai_strerror(err)))")
      return []
    }

    let address = String(cString: addressCString)
    if addrFamily == UInt8(AF_INET), let v4 = IPv4Address("\(address)%\(interfaceName)") {
      result.append(v4)
    } else if addrFamily == UInt8(AF_INET6), let v6 = IPv6Address("\(address)%\(interfaceName)") {
      result.append(v6)
    } else {
      print("Failed to parse address: \(address) on \(interfaceName)")
    }
  }

  return result
}
