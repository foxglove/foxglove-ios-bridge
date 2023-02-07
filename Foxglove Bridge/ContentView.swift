import SwiftUI
import Network
import Darwin

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

extension NWConnection: Hashable, Comparable, Identifiable {
  public static func < (lhs: NWConnection, rhs: NWConnection) -> Bool {
    switch (lhs.endpoint, rhs.endpoint) {
    case (.hostPort(let host1, _), .hostPort(host: let host2, _)):
      return host1.debugDescription < host2.debugDescription

    default:
      return ObjectIdentifier(lhs) < ObjectIdentifier(rhs)
    }
  }

  public static func == (lhs: NWConnection, rhs: NWConnection) -> Bool {
    return lhs === rhs
  }

  public func hash(into hasher: inout Hasher) {
    ObjectIdentifier(self).hash(into: &hasher)
  }

  public var id: ObjectIdentifier {
    return ObjectIdentifier(self)
  }
}

class Server: ObservableObject {
  let queue = DispatchQueue(label: "ServerQueue")

  let address = getIPAddress() ?? "<no address>"

  @MainActor @Published var port: NWEndpoint.Port?

  @MainActor @Published var clients: [NWConnection: NWConnection.State] = [:]

  init() {
    do {
      let params = NWParameters(tls: nil)
//      params.includePeerToPeer = true
      print(params.defaultProtocolStack.applicationProtocols)
      params.defaultProtocolStack.applicationProtocols.append(NWProtocolWebSocket.Options())

      let listener = try NWListener(using: params)
      listener.stateUpdateHandler = { newState in
        if let port = listener.port {
          print("Listening on \(self.address):\(port)")
        }
        Task { @MainActor in
          self.port = listener.port
        }
      }
      listener.newConnectionHandler = { [weak self] newConnection in
        guard let self else { return }
        print("New conn: \(newConnection)")

        Task { @MainActor in
          self.clients[newConnection] = newConnection.state
        }

        func receive() {
          newConnection.receiveMessage { data, context, isComplete, error in
            if let data, let context {
              self.handleClientMessage(data, context, isComplete, error)
              receive()
            }
          }

          newConnection.stateUpdateHandler = { state in
            print("connection state \(state)")

            Task { @MainActor in
              if case .failed(_) = newConnection.state {
                self.clients[newConnection] = nil
              } else if newConnection.state == .cancelled {
                self.clients[newConnection] = nil
              } else {
                self.clients[newConnection] = newConnection.state
              }
            }
          }
        }
        receive()


        newConnection.start(queue: self.queue)
      }
      listener.start(queue: queue)

    } catch let error {
      print("Error \(error)")
    }
  }

  func handleClientMessage(_ data: Data, _ context: NWConnection.ContentContext, _ isComplete: Bool, _ error: NWError?) {
  }
}

@MainActor
struct ContentView: View {
  @StateObject var server = Server()

  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
      if let port = server.port {
        Text("Listening on \(server.address):\(port.debugDescription)")
      }
      ForEach(server.clients.keys.sorted()) { client in
        Text("\(client.endpoint.debugDescription): \(String(describing: client.state))")
      }
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
