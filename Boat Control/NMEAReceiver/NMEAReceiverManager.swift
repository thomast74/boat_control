//
//  NMEAReceiverManager.swift
//  Boat Control
//
//  Created by Thomas Trageser on 26/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//


// 1. Start Connection to NMEA Server, if settings are good to do
// 1.1 Send notification of error message if connection failes
// 2. Receive NMEA data in sentences
// 3. Parse Sentences (at least the type)
// 4. Send notification about new sentence
// 4.1 Send notification in case of any error
//
// Needs to disconnect in case application is going to sleep
// Needs to connect in case application comes back from sleep
//
// If Settings Changed Received
// Stop connection if running and restart with new values


import Foundation
import CocoaAsyncSocket


public class NMEAReceiverManager: NSObject, GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate {
    
    var isRunning: Bool = false
    var socketTcp: GCDAsyncSocket? = nil
    var socketUdp: GCDAsyncUdpSocket? = nil
    
    var connectionType: Int = -1
    var ipAddress: String = "0.0.0.0"
    var port: UInt16 = 0
    
    override init() {
        super.init()
    }
    
    public func activate() {
        startReceiving()
        NotificationCenter.default.addObserver(self, selector: #selector(settingsUpdated), name: NotificationNames.SETTINGS_UPDATED, object: nil)
    }
    
    public func deactivate() {
        stopReceiving()
        NotificationCenter.default.removeObserver(self)
    }
    
    public func startReceiving() {
        print("Try to start receiving NMEA data")
        
        readSettings()
        
        switch(connectionType) {
        case 0: // TCP
            print("Prepare TCP Socket")
            if ipAddress == "0.0.0.0" || port < 1024 || port > 65355 {
                print("ERROR: No proper port configured in settings")
                return
            }
            
            print("TCP Socket initialising")
            socketTcp = GCDAsyncSocket.init(delegate: self, delegateQueue: DispatchQueue.global(qos: .background))
            do {
                try socketTcp!.connect(toHost: ipAddress, onPort: port)
                socketTcp!.readData(to: String("\r\n").data(using: .utf8)!, withTimeout: -1, tag: 0)
            } catch {
                print(error)
            }
            print("TCP Socket ready for receiving")
            break;
        case 1: // UDP
            print("Prepare UDP Socket")
            if port < 1024 || port > 65355 {
                print("ERROR: No proper port configured in settings")
                return
            }
            
            print("UDP Socket initialising")
            socketUdp = GCDAsyncUdpSocket.init(delegate: self, delegateQueue: DispatchQueue.global(qos: .background))
            do {
                socketUdp!.setIPv4Enabled(true)
                socketUdp!.setIPv6Enabled(false)
                socketUdp!.setUserData("\r\n")
                socketUdp!.setReceiveFilter({ (data, address, context) -> Bool in
                    return self.filterNmeaData(data: data)
                }, with: DispatchQueue.global(qos: .background))

                try socketUdp!.bind(toPort: port)
                try socketUdp!.beginReceiving()
            } catch {
                print(error)
            }
            print("UDP Socket ready for receiving")
            break
        default:
            print("ERROR: Not sure what was configured")
        }
    }
    
    public func stopReceiving() {
        print("Try to stop receiving NMEA data")
        if socketTcp != nil {
            if socketTcp!.isConnected {
                socketTcp!.delegate = nil
                socketTcp!.disconnect()
                socketTcp = nil
            }
        }
        if socketUdp != nil {
            if !socketUdp!.isClosed() {
                socketUdp!.setDelegate(nil)
                socketUdp!.close()
                socketUdp = nil
            }
        }
    }
    
    func filterNmeaData(data: Data) -> Bool {
        if let sentence = String.init(data: data, encoding: .utf8) {
            if sentence.starts(with: "!AI") {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    @objc func settingsUpdated() {
        stopReceiving()
        startReceiving()
    }
    
    func readSettings() {
        connectionType = Int(UserDefaults.standard.value(forKey: "nmea_connection_type") as? String ?? "0")!
        ipAddress = UserDefaults.standard.value(forKey: "nmea_ip_address") as! String
        port = UInt16(UserDefaults.standard.value(forKey: "nmea_port") as? String ?? "0")!
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        sentenceReceived(data)
    }
    
    public func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        //NotificationCenter.default.post(name: <#T##NSNotification.Name#>, object: <#T##Any?#>)
    }
    
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        if filterNmeaData(data: data) {
            return
        }
        sentenceReceived(data)
        socketTcp!.readData(to: String("\r\n").data(using: .utf8)!, withTimeout: -1, tag: 0)
    }
    
    func sentenceReceived(_ data: Data) {
        var sentence = String.init(data: data, encoding: .utf8) ?? "?"
        sentence = sentence.replacingOccurrences(of: "\r\n", with: "")
        
        // parse sentence and store into dedicated object
        let nmeaObj = NMEAParser.convert(sentence: sentence)
        print(nmeaObj.toString())
        
        // send notification about type with dedicated object to dedicated Notiication Area
    }
    
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print(err)
    }
}
