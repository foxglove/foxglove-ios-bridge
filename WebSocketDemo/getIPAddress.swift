import Foundation

// https://stackoverflow.com/a/73853838/23649
func getIPAddress() -> String? {
  var address : String?

  // Get list of all interfaces on the local machine:
  var ifaddr : UnsafeMutablePointer<ifaddrs>?
  guard getifaddrs(&ifaddr) == 0 else { return nil }
  guard let firstAddr = ifaddr else { return nil }

  // For each interface ...
  for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
    let interface = ifptr.pointee

    // Check for IPv4 or IPv6 interface:
    let addrFamily = interface.ifa_addr.pointee.sa_family
    if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

      // Check interface name:
      // wifi = ["en0"]
      // wired = ["en2", "en3", "en4"]
      // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]

      let name = String(cString: interface.ifa_name)
      if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {

        // Convert interface address to a human readable string:
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                    &hostname, socklen_t(hostname.count),
                    nil, socklen_t(0), NI_NUMERICHOST)
        address = String(cString: hostname)
      }
    }
  }
  freeifaddrs(ifaddr)

  return address
}
