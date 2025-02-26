#if os(Linux)

import NetService
import Foundation


//    MARK: - Denon Finding Protocol Definition -

///	A Type that will find Denon Amps on the network.
protocol DenonFinder {
	var findingDelegate: DenonFindingDelegate? { get set }
	func find()
}

///	A Type that will be informed of the finding of Denon Amps
protocol DenonFindingDelegate {
	func denonDeviceFound(addressString: String)
}

//    MARK: - Main Entry Point -

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

	//    MARK: - NetServiceBrowserDelegate Conformation

	func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
		print("🔎 Starting mDNS search...")
	}
	
	public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
		print("Did find: \(service.name)")
//		let searchContainsAVR = "AVR"

        //    Only resolve the first service...
        if firstAmpService == nil {
            firstAmpService = service
            findingDelegate?.denonDeviceFound(addressString: firstAmpService.name)
            firstAmpService?.delegate = self
            firstAmpService?.resolve(withTimeout: 5)
        }

	}
	
	
	//    MARK: - NetServiceDelegate Conformation

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

#else
	fatalError("This code should only be run on Linux…")
#endif
