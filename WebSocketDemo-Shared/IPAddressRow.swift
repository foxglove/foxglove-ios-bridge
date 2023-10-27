import Network
import SwiftUI

extension IPAddress {
  var withoutInterface: IPAddress {
    Self(rawValue, nil) ?? self
  }

  var urlString: String {
    if let v6 = self as? IPv6Address {
      return "[\(v6)]"
    }
    return "\(self)"
  }
}

struct IPAddressRow: View {
  let address: IPAddress
  let port: NWEndpoint.Port

  @State
  var showInterfaceName = false

  var icon: Text {
    switch address.interface?.type {
    case .wifi?:
      Text(Image(systemName: "wifi"))
    case .wiredEthernet?:
      Text(Image(systemName: "cable.connector.horizontal"))
    case .cellular?:
      Text(Image(systemName: "antenna.radiowaves.left.and.right"))
    case .loopback?:
      Text(Image(systemName: "arrow.counterclockwise"))
    case .other?:
      Text(Image(systemName: "questionmark"))
    default:
      Text("")
    }
  }

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Group {
        if showInterfaceName, let name = address.interface?.name {
          Text("\(name)").font(.footnote)
        } else {
          icon
        }
      }
      .foregroundColor(.secondary)
      .frame(minWidth: 30) // hack to make icons look more aligned
      .onTapGesture {
        showInterfaceName.toggle()
      }

      Text("\(address.withoutInterface.urlString):\(String(port.rawValue))")
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .monospaced()
        .tracking(-0.5)
      Spacer()
      let shareURL: URL = {
        var url = URL(string: "https://studio.foxglove.dev/")!
        url.append(queryItems: [
          URLQueryItem(name: "ds", value: "foxglove-websocket"),
          URLQueryItem(name: "ds.url", value: "ws://\(address.withoutInterface.urlString):\(String(port.rawValue))"),
        ])
        return url
      }()
      ShareLink(item: shareURL) {
        Image(systemName: "square.and.arrow.up")
      }
      .buttonStyle(.borderless) // https://stackoverflow.com/a/59402642/23649
    }
  }
}

struct IPAddressRow_Previews: PreviewProvider {
  static var previews: some View {
    List {
      IPAddressRow(address: IPv4Address("255.255.255.255%en0")!, port: 13245)
      IPAddressRow(address: IPv4Address("0.0.0.0%lo0")!, port: 13245)
      IPAddressRow(address: IPv6Address("::%lo0")!, port: 13245)
      IPAddressRow(address: IPv6Address("ffff:ffff::ffff:ffff:ffff")!, port: 13245)
      IPAddressRow(address: IPv6Address("ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!, port: 13245)
    }
  }
}
