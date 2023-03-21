import SwiftUI
import Network

extension IPAddress {
  var withoutInterface: IPAddress {
    return Self.init(rawValue, nil) ?? self
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

  var icons: Text {
    let text: Text
    switch address.interface?.type {
    case .wifi?:
      text = Text(Image(systemName: "wifi"))
    case .wiredEthernet?:
      text = Text(Image(systemName: "cable.connector.horizontal"))
    case .cellular?:
      text = Text(Image(systemName: "antenna.radiowaves.left.and.right"))
    case .loopback?:
      text = Text(Image(systemName: "arrow.counterclockwise"))
    case .other?:
      text = Text(Image(systemName: "questionmark"))
    default:
      text = Text("")
    }
    return text.foregroundColor(.secondary)
  }

  var body: some View {
    HStack {
      icons
        .frame(minWidth: 30) // hack to make icons look more aligned
      Text("\(address.withoutInterface.urlString):\(String(port.rawValue))")
      Spacer()
      let shareURL: URL = {
        var url = URL(string: "https://studio.foxglove.dev/")!
        url.append(queryItems: [
          URLQueryItem(name: "ds", value: "foxglove-websocket"),
          URLQueryItem(name: "ds.url", value: "ws://\(address.withoutInterface.urlString):\(String(port.rawValue))")
        ])
        return url
      }()
      ShareLink(item: shareURL) {
        Image(systemName: "square.and.arrow.up")
      }
      .buttonStyle(.borderless) // https://stackoverflow.com/a/59402642/23649
    }
    .lineLimit(1)
    .minimumScaleFactor(0.6)
    .monospaced()
    .tracking(-0.5)
  }
}

struct IPAddressRow_Previews: PreviewProvider {
  static var previews: some View {
    List {
      IPAddressRow(address: IPv4Address("255.255.255.255%en0")!, port: 13245)
        .previewLayout(.sizeThatFits)
      IPAddressRow(address: IPv4Address("0.0.0.0%lo0")!, port: 13245)
        .previewLayout(.sizeThatFits)
      IPAddressRow(address: IPv6Address("::%lo0")!, port: 13245)
        .previewLayout(.sizeThatFits)
      IPAddressRow(address: IPv6Address("ffff:ffff::ffff:ffff:ffff")!, port: 13245)
        .previewLayout(.sizeThatFits)
    }
  }
}
