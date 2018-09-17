//
//  ModelManager.swift
//  Boat Control
//
//  Created by Thomas Trageser on 30/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation
import CoreMotion

class ModelManager: NMEAReceiverDelegate {
    
    fileprivate let concurrentNMEA_GGAQueue = DispatchQueue(label: "com.arohanui.boat_control.NMEA_GGA", attributes: .concurrent)
    fileprivate let concurrentNMEA_GLLQueue = DispatchQueue(label: "com.arohanui.boat_control.NMEA_GLL", attributes: .concurrent)
    fileprivate let concurrentNMEA_HDGQueue = DispatchQueue(label: "com.arohanui.boat_control.NMEA_HDG", attributes: .concurrent)
    fileprivate let concurrentNMEA_MWVQueue = DispatchQueue(label: "com.arohanui.boat_control.NMEA_MWV", attributes: .concurrent)
    fileprivate let concurrentNMEA_RMCQueue = DispatchQueue(label: "com.arohanui.boat_control.NMEA_RMC", attributes: .concurrent)
    fileprivate let concurrentNMEA_VHWQueue = DispatchQueue(label: "com.arohanui.boat_control.NMEA_VHW", attributes: .concurrent)

    fileprivate let concurrentWindQueue = DispatchQueue(label: "com.arohanui.boat_control.Wind", attributes: .concurrent)
    fileprivate let concurrentGPSQueue = DispatchQueue(label: "com.arohanui.boat_control.GPS", attributes: .concurrent)

    private var _delegate: ModelManagerDelegate?
    
    private var _lastGGA: NMEA_GGA?
    private var _lastGLL: NMEA_GLL?
    private var _lastMWV: NMEA_MWV?
    private var _lastMWVDate: Date
    private var _lastRMC: NMEA_RMC?

    private var _lastDBT: NMEA_DBT?
    private var _lastHDG: NMEA_HDG?
    private var _lastHDM: NMEA_HDM?
    private var _lastHDGDate: Date
    private var _lastVHW: NMEA_VHW?
    private var _lastVHWDate: Date
    
    //private var lastDBT: NMEA_DBT?
    //private var lastMTW: NMEA_MTW?
    //private var lastVLW: NMEA_VLW?
    
    private var altimeter: CMAltimeter?
    private var _wind: Wind
    private let _windHistory: WindHistory
    private let _navigation: Navigation
    private let _navigationHistory: NavigationHistory
    private var _geoMagneticField: GeomagneticField?
    
    // object should be singleton so when notificaton is received it is easy to get the data
    // must be thread safe sooo!!!!!!
    
    init() {
        _windHistory = WindHistory()
        _navigationHistory = NavigationHistory()
        
        _wind = Wind(windAngle: 0.0, windSpeed: 0.0, reference: "R", cog: 0.0, sog: 0.0, hdg: 0.0)
        _navigation = Navigation(speedThroughWater: 0.0, speedOverGround: 0.0, headingMagnetic: 0.0, headingTrue: 0.0, courseOverGroundTrue: 0.0, courseOverGroundMagnetic: 0.0, latitude: 0.0, latitudeDirection: "N", longitude: 0.0, longitudeDirection: "E", gpsTimeStamp: Date(timeIntervalSince1970: TimeInterval(exactly: 0)!))
        
        _lastMWVDate = Date()
        _lastHDGDate = Date()
        _lastVHWDate = Date()
        
        initBaromaterRrading()
    }
    
    private func initBaromaterRrading() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            if altimeter == nil {
                altimeter = CMAltimeter()
            }
            altimeter?.startRelativeAltitudeUpdates(to: OperationQueue.init(), withHandler: { (altimeterData, error) in
                if error == nil {
                    self.concurrentGPSQueue.async(flags: .barrier) {
                        self._navigation.baromericPressure = Double(truncating: altimeterData?.pressure ?? 0.0)
                    }
                }
            })
        }
    }
    
    public func setDelegate(_ delegate: ModelManagerDelegate) {
        print("Received new deledate: \(type(of: delegate))")
        _delegate = delegate
    }
    
    public func removeDelegate() {
        _delegate = nil
    }
    
    public func sendCurrentData() {
        concurrentWindQueue.async {
            self._delegate?.modelManager(didReceiveWind: self._wind.clone())
            self._delegate?.modelManager(didReceiveWindHistory: self._windHistory.historyAggregate)
        }
        concurrentGPSQueue.async {
            self._delegate?.modelManager(didReceiveNavigation: self._navigation.clone())
            self._delegate?.modelManager(didReceiveNavigationHistory: self._navigationHistory.historyAggregate)
        }
    }
    
    public var geomagneticField: GeomagneticField? {
        var geoMF: GeomagneticField? = nil
        concurrentGPSQueue.sync {
            geoMF = _geoMagneticField
        }
        return geoMF
    }
    
    public func nmeaReceived(data: NMEA_BASE) {
        switch(data.identifier) {
        case "MWV":
            processNmea(data: data as! NMEA_MWV)
            break
        case "GGA":
            processNmea(data: data as! NMEA_GGA)
            break
        case "GLL":
            processNmea(data: data as! NMEA_GLL)
            break
        case "RMC":
            processNmea(data: data as! NMEA_RMC)
            break
        case "HDG":
            processNmea(data: data as! NMEA_HDG)
            break
        case "HDM":
            processNmea(data: data as! NMEA_HDM)
            break
        case "VHW":
            processNmea(data: data as! NMEA_VHW)
            break
        case "DBT":
            processNmea(data: data as! NMEA_DBT)
            break
        case "MTW":
            //processNmea(data: data as! NMEA_MTW)
            break
        default:
            print("Not known data object received; \(data.identifier)")
        }
        
        _delegate?.modelManager(didReceiveSentence: data)
    }
    
    public func socket(received message: String, of type: MessageType) {
        _delegate?.modelManager(didReceiveSystemMessage: message, of: type)

    }

    private func processNmea(data: NMEA_MWV) {
        concurrentNMEA_MWVQueue.async(flags: .barrier) {
            self._lastMWV = data
            self._lastMWVDate = Date()
            
            self.createWind()
        }
    }
    
    private func processNmea(data: NMEA_GGA) {
        concurrentNMEA_GGAQueue.async(flags: .barrier) {
            self._lastGGA = data

            self.updateNavigation()
        }
    }
    
    private func processNmea(data: NMEA_GLL) {
        concurrentNMEA_GLLQueue.async(flags: .barrier) {
            self._lastGLL = data
            
            self.updateNavigation()
        }
    }
    
    private func processNmea(data: NMEA_RMC) {
        concurrentNMEA_RMCQueue.async(flags: .barrier) {
            if data._talker == "II" && data.Latitude == 0.0 && data.Longitude == 0.0 {
                return
            }
            
            self._lastRMC = data
        
            self.createWind()
            self.updateNavigation()
        }
    }
    
    private func processNmea(data: NMEA_HDG) {
        concurrentNMEA_HDGQueue.async(flags: .barrier) {
            self._lastHDG = data
            self._lastMWVDate = Date()
            
            self.createWind()
            self.updateNavigation()
        }
    }

    private func processNmea(data: NMEA_HDM) {
        concurrentNMEA_HDGQueue.async(flags: .barrier) {
            self._lastHDM = data
            self._lastMWVDate = Date()
            
            self.createWind()
            self.updateNavigation()
        }
    }

    private func processNmea(data: NMEA_VHW) {
        concurrentNMEA_VHWQueue.async(flags: .barrier) {
            self._lastVHW = data
            self._lastVHWDate = Date()
            
            self.createWind()
            self.updateNavigation()
        }
    }

    private func processNmea(data: NMEA_DBT) {
        concurrentNMEA_HDGQueue.async(flags: .barrier) {
            self._lastDBT = data
            
            self.updateNavigation()
        }
    }

    private func createWind() {
        concurrentWindQueue.async(flags: .barrier) {
            if self._lastMWV == nil {
                return
            }
            
            var cog: Double  = -1.0
            var sog: Double  = 0.0
            let (_, hdgTrue) = self.getLatestHeading()

            if self._lastRMC != nil {
                cog = self._lastRMC!.CourseOverGround
                sog = self._lastRMC!.SpeedOverGround
            }
            
            if cog == -1.0 {
                cog = hdgTrue
            }
            
            self._wind = Wind(windAngle: self._lastMWV!.WindAngle, windSpeed: self._lastMWV!.WindSpeed, reference: self._lastMWV!.Reference, cog: cog, sog: sog, hdg: hdgTrue)
            
            self._windHistory.add(self._wind)
            
            self._delegate?.modelManager(didReceiveWind: self._wind.clone())
            self._delegate?.modelManager(didReceiveWindHistory: self._windHistory.historyAggregate)
        }
    }
    
    private func updateNavigation() {
        concurrentGPSQueue.async(flags: .barrier) {
            
            let (latitude, latitudeDirection, longitude, longitudeDirection, timeUTC) = self.getLatestGPSCoordinates()
            self._navigation.latitude = latitude
            self._navigation.latitudeDirection = latitudeDirection
            self._navigation.longitude = longitude
            self._navigation.longitudeDirection = longitudeDirection
            self._navigation.gpsTimeStamp = timeUTC

            self.setGeomagneticField(latitude: latitude, latitudeDirection: latitudeDirection, longitude: longitude, longitudeDirection: longitudeDirection)
            
            if self._lastVHW != nil {
                self._navigation.speedThroughWater = self._lastVHW!.BoatSpeedKnots
            }

            if self._lastDBT != nil {
                if self._lastDBT!.DepthMeters >= 0.0 {
                    self._navigation.depth = self._lastDBT!.DepthMeters
                } else {
                    self._navigation.depth = self._lastDBT!.DepthFeet * 0.3048
                }
            }

            let (headingMagnetic, headingTrue) = self.getLatestHeading()
            self._navigation.headingMagnetic = headingMagnetic
            self._navigation.headingTrue = headingTrue

            if self._lastRMC != nil {
                self._navigation.speedOverGround = self._lastRMC!.SpeedOverGround
                self._navigation.courseOverGroundTrue = self._lastRMC!.CourseOverGround
            }

            if self._navigation.courseOverGroundTrue == -1.0 {
               self._navigation.courseOverGroundTrue = headingTrue
            }

            self._navigation.courseOverGroundMagnetic = self._geoMagneticField?.trueToMagnetic(trueDegree: self._navigation.courseOverGroundTrue) ?? headingMagnetic
            
            let (currentSpeed, currentDirection) = self.calculateCurrent(headingMagnetic: self._navigation.headingMagnetic,
                                                                         courseOverGroundMagnetic: self._navigation.courseOverGroundMagnetic,
                                                                         speedOverGround: self._navigation.speedOverGround,
                                                                         speedThroughWater: self._navigation.speedThroughWater)
            
            self._navigation.currentSpeed = currentSpeed
            self._navigation.currentDirection = currentDirection
            
            
            self._navigation.timeStamp = Date()
            
            self._navigationHistory.add(self._navigation.clone())

            self._delegate?.modelManager(didReceiveNavigation: self._navigation.clone())
            self._delegate?.modelManager(didReceiveNavigationHistory: self._navigationHistory.historyAggregate)
        }
    }
    
    private func getLatestHeading() -> (headingMagnetic: Double, headingTrue: Double) {

        if _lastHDG == nil && _lastVHW == nil && _lastHDM == nil {
            if _lastRMC != nil {
                return (self._geoMagneticField?.trueToMagnetic(trueDegree: self._lastRMC!.CourseOverGround) ?? _lastRMC!.CourseOverGround, _lastRMC!.CourseOverGround)
            } else {
                return (0.0, 0.0)
            }
        }

        var headingMagnetic: Double = 0.0

        if _lastHDM != nil {
            headingMagnetic = _lastHDM!.MagneticHeading
        } else if _lastHDG != nil {
            headingMagnetic = _lastHDG!.MagneticHeading
        } else if _lastVHW != nil {
            headingMagnetic = _lastVHW!.MagneticHeading
        }
        
        let headingTrue = _geoMagneticField?.magneticToTrue(magneticDegree: headingMagnetic) ?? headingMagnetic
        
        return (headingMagnetic, headingTrue)
    }

    private func getLatestGPSCoordinates() -> (Double, String, Double, String, Date) {
        if _lastRMC == nil && _lastGGA == nil && _lastGLL == nil {
            return (0.0, "N", 0.0, "E", Date(timeIntervalSince1970: TimeInterval(0)))
        }
        
        if _lastRMC != nil && _lastGGA == nil && _lastGLL == nil {
            return (_lastRMC!.Latitude, _lastRMC!.LatitudeDirection, _lastRMC!.Longitude, _lastRMC!.LongitudeDirection, _lastRMC!.TimeUTC)
        }

        if _lastRMC == nil && _lastGGA != nil && _lastGLL == nil {
            return (_lastGGA!.Latitude, _lastGGA!.LatitudeDirection, _lastGGA!.Longitude, _lastGGA!.LongitudeDirection, _lastGGA!.TimeUTC)
        }

        if _lastRMC == nil && _lastGGA == nil && _lastGLL != nil {
            return (_lastGLL!.Latitude, _lastGLL!.LatitudeDirection, _lastGLL!.Longitude, _lastGLL!.LongitudeDirection, _lastGLL!.TimeUTC)
        }

        if _lastRMC != nil && _lastGGA != nil && _lastGLL == nil && _lastRMC!.TimeUTC >= _lastGGA!.TimeUTC {
            return (_lastRMC!.Latitude, _lastRMC!.LatitudeDirection, _lastRMC!.Longitude, _lastRMC!.LongitudeDirection, _lastRMC!.TimeUTC)
        }
        
        if _lastRMC != nil && _lastGGA != nil && _lastGLL == nil && _lastRMC!.TimeUTC < _lastGGA!.TimeUTC {
            return (_lastGGA!.Latitude, _lastGGA!.LatitudeDirection, _lastGGA!.Longitude, _lastGGA!.LongitudeDirection, _lastGGA!.TimeUTC)
        }

        if _lastRMC != nil && _lastGGA == nil && _lastGLL != nil && _lastRMC!.TimeUTC >= _lastGLL!.TimeUTC {
            return (_lastRMC!.Latitude, _lastRMC!.LatitudeDirection, _lastRMC!.Longitude, _lastRMC!.LongitudeDirection, _lastRMC!.TimeUTC)
        }
        
        if _lastRMC != nil && _lastGGA == nil && _lastGLL != nil && _lastRMC!.TimeUTC < _lastGLL!.TimeUTC {
            return (_lastGLL!.Latitude, _lastGLL!.LatitudeDirection, _lastGLL!.Longitude, _lastGLL!.LongitudeDirection, _lastGLL!.TimeUTC)
        }

        if _lastRMC == nil && _lastGGA != nil && _lastGLL != nil && _lastGGA!.TimeUTC >= _lastGLL!.TimeUTC {
            return (_lastGGA!.Latitude, _lastGGA!.LatitudeDirection, _lastGGA!.Longitude, _lastGGA!.LongitudeDirection, _lastGGA!.TimeUTC)
        }
        
        if _lastRMC == nil && _lastGGA != nil && _lastGLL != nil && _lastGGA!.TimeUTC < _lastGLL!.TimeUTC {
            return (_lastGLL!.Latitude, _lastGLL!.LatitudeDirection, _lastGLL!.Longitude, _lastGLL!.LongitudeDirection, _lastGLL!.TimeUTC)
        }

        if _lastRMC!.TimeUTC >= _lastGGA!.TimeUTC && _lastRMC!.TimeUTC >= _lastGLL!.TimeUTC {
            return (_lastRMC!.Latitude, _lastRMC!.LatitudeDirection, _lastRMC!.Longitude, _lastRMC!.LongitudeDirection, _lastRMC!.TimeUTC)
        }

        if _lastRMC!.TimeUTC >= _lastGGA!.TimeUTC && _lastRMC!.TimeUTC < _lastGLL!.TimeUTC {
            return (_lastGLL!.Latitude, _lastGLL!.LatitudeDirection, _lastGLL!.Longitude, _lastGLL!.LongitudeDirection, _lastGLL!.TimeUTC)
        }

        if _lastRMC!.TimeUTC < _lastGGA!.TimeUTC && _lastRMC!.TimeUTC < _lastGLL!.TimeUTC  && _lastGGA!.TimeUTC >= _lastGLL!.TimeUTC {
            return (_lastGGA!.Latitude, _lastGGA!.LatitudeDirection, _lastGGA!.Longitude, _lastGGA!.LongitudeDirection, _lastGGA!.TimeUTC)
        } else {
            return (_lastGLL!.Latitude, _lastGLL!.LatitudeDirection, _lastGLL!.Longitude, _lastGLL!.LongitudeDirection, _lastGLL!.TimeUTC)
        }
    }
    
    private func calculateCurrent(headingMagnetic: Double, courseOverGroundMagnetic: Double, speedOverGround: Double, speedThroughWater: Double) -> (Double, Double) {
        // get HDG and COG angle difference with direction (needed for calculating direction in sense of degree)
        let difference = headingMagnetic - courseOverGroundMagnetic
        let phi = abs(difference).truncatingRemainder(dividingBy: 360.0)
        let alpha = phi > 180 ? 360 - phi : phi
        let sign = ((difference) >= 0 && (difference) <= 180) || ((difference) <= -180 && (difference) >= 360) ? 1 : -1
        
        // calculate current speed
        let currentSpeed = sqrt(pow(speedOverGround, 2) + pow(speedThroughWater, 2) - (2*speedOverGround*speedThroughWater*cos(alpha)))
        
        // calculate current direction
        let ceta = acos((pow(currentSpeed, 2) + pow(speedThroughWater, 2) - pow(speedOverGround, 2))/(2*currentSpeed*speedThroughWater))
        let currentDirection = sign == 1 ? ceta : 360 - ceta

        return (currentSpeed, currentDirection)
    }

    
    private func setGeomagneticField(latitude: Double, latitudeDirection: String, longitude: Double, longitudeDirection: String) {
        var geoLatitude = latitude/100
        var geoLongitude = longitude/100
        
        if latitudeDirection == "S" && geoLatitude > 0 {
            geoLatitude *= -1
        }
        
        if longitudeDirection == "W" && geoLongitude > 0 {
            geoLongitude *= -1
        }
        
        self._geoMagneticField = GeomagneticField(gdLatitudeDeg: geoLatitude, gdLongitudeDeg: geoLongitude)
    }
    
}
