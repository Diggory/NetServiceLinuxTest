#if os(Linux)

import NetService
import Foundation

let finderClient = FindingClient()
let denonFinderLinux = DenonFinderLinux()
denonFinderLinux.findingDelegate = finderClient
denonFinderLinux.find()

let runLoop = RunLoop.current
let distantFuture = Date.distantFuture
///	Set this to false when we want to exit the app...
let shouldKeepRunning = true
//	Run forever
while shouldKeepRunning == true &&
		runLoop.run(mode:.default, before: distantFuture) {}


protocol DenonFinder {
	var findingDelegate: DenonFindingDelegate? { get set }
	func find()
}

protocol DenonFindingDelegate {
	func denonDeviceFound(addressString: String)
}


class FindingClient: DenonFindingDelegate {
	func denonDeviceFound(addressString: String) {
		print("Found device: \(addressString)")
	}
}

class DenonFinderLinux: NetServiceBrowserDelegate, NetServiceDelegate, DenonFinder {
	
	var findingDelegate: DenonFindingDelegate?
	var firstAmpService: NetService?
	let browser = NetServiceBrowser()

	func find() {
		print("find()")
		browser.delegate = self
		browser.searchForServices(ofType: "_http._tcp.", inDomain: "local.")
	}

	//	NetServiceBrowserDelegate

	func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
		print("🔎 Starting mDNS search...")
	}
	
	public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
		print("Did find: \(service.name)")
		let searchContainsAVR = "AVR"
		if service.name.contains(searchContainsAVR) {
			print("🧐 Found HTTP service that contains: \(searchContainsAVR)")
			print("Service name: \(service.name)")
			findingDelegate?.denonDeviceFound(addressString: service.name)

			service.delegate = self
			service.resolve(withTimeout: 5)
		}
	}
	
	//	NetServiceDelegate

	func netServiceWillResolve(_ sender: NetService) {
		print("netServiceWillResolve(\(sender.name))")
	}
	
	func netService(_ sender: NetService, didNotResolve errorDict: [String: NSNumber]) {
		print("netServiceDidNotResolve()")
	}

	func netServiceDidResolveAddress(_ sender: NetService) {
		print("netServiceDidResolve()")
	}

}

#endif
