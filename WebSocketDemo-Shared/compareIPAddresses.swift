import Foundation
import Network

fileprivate struct BytewiseLess: Comparable {
  let data: Data
  static func <(lhs: BytewiseLess, rhs: BytewiseLess) -> Bool {
    if lhs.data.count < rhs.data.count {
      return true
    }
    for (a, b) in zip(lhs.data, rhs.data) {
      if a < b {
        return true
      } else if a > b {
        return false
      }
    }
    return true
  }
}

fileprivate struct TrueLess: Comparable {
  let value: Bool
  static func <(lhs: TrueLess, rhs: TrueLess) -> Bool {
    return lhs.value && !rhs.value
  }
}

/**
 Comparator for sorting IP addresses by:
 - v4 first
 - wifi first
 - fall back to comparing raw addresses
 */
func compareIPAddresses(_ lhs: IPAddress, _ rhs: IPAddress) -> Bool {
  return (
    TrueLess(value: lhs is IPv4Address),
    TrueLess(value: lhs.interface?.type == .wifi),
    TrueLess(value: lhs.interface?.type == .wiredEthernet),
    BytewiseLess(data: lhs.rawValue)
  ) < (
    TrueLess(value: rhs is IPv4Address),
    TrueLess(value: rhs.interface?.type == .wifi),
    TrueLess(value: rhs.interface?.type == .wiredEthernet),
    BytewiseLess(data: rhs.rawValue)
  )
}
