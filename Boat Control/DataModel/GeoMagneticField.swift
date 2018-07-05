
/*
 *
 * Copyright (C) 2018 CSS Computer-System-Support Ges.m.b.H.
 * Copyright (C) 2009 The Android Open Source Project
 *
 * This is a derivative work of Android's GeomagneticField class which
 * is also published unter the same license.
 * See https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/hardware/GeomagneticField.java
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation


/**
 * Compute the ration between the Gauss-normalized associated Legendre
 * functions and the Schmidt quasi-normalized version. This is equivalent to
 * sqrt((m==0?1:2)*(n-m)!/(n+m!))*(2n-1)!!/(n-m)!
 */
fileprivate func computeSchmidtQuasiNormFactors(_ maxN: Int) -> [[Double]] {
    var schmidtQuasiNorm: [[Double]] = [];
    schmidtQuasiNorm.append([1.0]);
    for n in 1...maxN {
        let fn = Double(n)
        schmidtQuasiNorm.append([Double](repeating: 0, count: n+1))
        schmidtQuasiNorm[n][0] = schmidtQuasiNorm[n - 1][0] * (2.0 * fn - 1.0) / fn;
        for m in 1...n {
            let fm = Double(m)
            schmidtQuasiNorm[n][m] = schmidtQuasiNorm[n][m - 1]
                * sqrt((fn - fm + 1.0) * (m == 1 ? 2.0 : 1.0) / (fn + fm));
        }
    }
    return schmidtQuasiNorm;
}


/**
 * Utility class to compute a table of Gauss-normalized associated Legendre
 * functions P_n^m(cos(theta))
 */
fileprivate struct LegendreTable {
    // These are the Gauss-normalized associated Legendre functions -- that
    // is, they are normal Legendre functions multiplied by
    // (n-m)!/(2n-1)!! (where (2n-1)!! = 1*3*5*...*2n-1)
    public let mP: [[Double]];
    // Derivative of mP, with respect to theta.
    public let mPDeriv: [[Double]];
    /**
     * @param maxN
     *            The maximum n- and m-values to support
     * @param thetaRad
     *            Returned functions will be Gauss-normalized
     *            P_n^m(cos(thetaRad)), with thetaRad in radians.
     */
    init(maxN: Int, thetaRad: Double) {
        // Compute the table of Gauss-normalized associated Legendre
        // functions using standard recursion relations. Also compute the
        // table of derivatives using the derivative of the recursion
        // relations.
        let calcCos = cos(thetaRad)
        let calcSin = sin(thetaRad)
        var mP = [[Double]](repeating: [], count: maxN+1)
        var mPDeriv = [[Double]](repeating: [], count: maxN+1)
        mP[0] = [ 1.0 ]
        mPDeriv[0] = [ 0.0 ]
        for n in 1...maxN {
            mP[n] = [Double](repeating: 0.0, count: n + 1)
            mPDeriv[n] = [Double](repeating: 0.0, count: n + 1)
            for m in 0...n {
                if (n == m) {
                    mP[n][m] = calcSin * mP[n - 1][m - 1];
                    mPDeriv[n][m] = calcCos * mP[n - 1][m - 1]
                        + calcSin * mPDeriv[n - 1][m - 1];
                } else if (n == 1 || m == n - 1) {
                    mP[n][m] = calcCos * mP[n - 1][m];
                    mPDeriv[n][m] = -calcSin * mP[n - 1][m]
                        + calcCos * mPDeriv[n - 1][m];
                } else {
                    assert(n > 1 && m < n - 1)
                    let k = Double((n - 1) * (n - 1) - m * m)
                        / Double((2 * n - 1) * (2 * n - 3));
                    mP[n][m] = calcCos * mP[n - 1][m] - k * mP[n - 2][m];
                    mPDeriv[n][m] = -calcSin * mP[n - 1][m]
                        + calcCos * mPDeriv[n - 1][m] - k * mPDeriv[n - 2][m];
                }
            }
        }
        self.mP = mP
        self.mPDeriv = mPDeriv
    }
}

/**
 * Estimates magnetic field at a given point on
 * Earth, and in particular, to compute the magnetic declination from true
 * north.
 *
 * <p>This uses the World Magnetic Model produced by the United States National
 * Geospatial-Intelligence Agency.  More details about the model can be found at
 * <a href="http://www.ngdc.noaa.gov/geomag/WMM/DoDWMM.shtml">http://www.ngdc.noaa.gov/geomag/WMM/DoDWMM.shtml</a>.
 * This class currently uses WMM-2015 which is valid until 2019, but should
 * produce acceptable results for several years after that. Future versions of
 * Android may use a newer version of the model.
 */
public class GeomagneticField {
    // The magnetic field at a given point, in nonoteslas in geodetic
    // coordinates.
    private var mX: Double = 0
    private var mY: Double = 0
    private var mZ: Double = 0
    // Geocentric coordinates -- set by computeGeocentricCoordinates.
    private var mGcLatitudeRad: Double = 0
    private var mGcLongitudeRad: Double = 0
    private var mGcRadiusKm: Double = 0
    // Constants from WGS84 (the coordinate system used by GPS)
    static private let EARTH_SEMI_MAJOR_AXIS_KM: Double = 6378.137
    static private let EARTH_SEMI_MINOR_AXIS_KM: Double = 6356.7523142
    static private let EARTH_REFERENCE_RADIUS_KM: Double = 6371.2
    // These coefficients and the formulae used below are from:
    // NOAA Technical Report: The US/UK World Magnetic Model for 2010-2015
    static private let G_COEFF: [[Double]] = [
        [ 0.0 ],
        [ -29438.5, -1501.1 ],
        [ -2445.3, 3012.5, 1676.6],
        [ 1351.1, -2352.3, 1225.6, 581.9 ],
        [ 907.2, 813.7, 120.3, -335.0, 70.3 ],
        [ -232.6, 360.1, 192.4, -141.0, -157.4, 4.3 ],
        [ 69.5, 67.4, 72.8, -129.8, -29.0, 13.2, -70.9 ],
        [ 81.6, -76.1, -6.8, 51.9, 15.0, 9.3, -2.8, 6.7 ],
        [ 24.0, 8.6, -16.9, -3.2, -20.6, 13.3, 11.7, -16.0, -2.0 ],
        [ 5.4, 8.8, 3.1, -3.1, 0.6, -13.3, -0.1, 8.7, -9.1, -10.5 ],
        [ -1.9, -6.5, 0.2, 0.6, -0.6, 1.7, -0.7, 2.1, 2.3, -1.8, -3.6 ],
        [ 3.1, -1.5, -2.3, 2.1, -0.9, 0.6, -0.7, 0.2, 1.7, -0.2, 0.4, 3.5 ],
        [ -2.0, -0.3, 0.4, 1.3, -0.9, 0.9, 0.1, 0.5, -0.4, -0.4, 0.2, -0.9, 0.0 ]]
    
    static private let H_COEFF: [[Double]] = [
        [ 0.0 ],
        [ 0.0, 4796.2 ],
        [ 0.0, -2845.6, -642.0 ],
        [ 0.0, -115.3, 245.0, -538.3 ],
        [ 0.0, 283.4, -188.6, 180.9, -329.5 ],
        [ 0.0, 47.4, 196.9, -119.4, 16.1, 100.1 ],
        [ 0.0, -20.7, 33.2, 58.8, -66.5, 7.3, 62.5 ],
        [ 0.0, -54.1, -19.4, 5.6, 24.4, 3.3, -27.5, -2.3 ],
        [ 0.0, 10.2, -18.1, 13.2, -14.6, 16.2, 5.7, -9.1, 2.2 ],
        [ 0.0, -21.6, 10.8, 11.7, -6.8, -6.9, 7.8, 1.0, -3.9, 8.5 ],
        [ 0.0, 3.3, -0.3, 4.6, 4.4, -7.9, -0.6, -4.1, -2.8, -1.1, -8.7 ],
        [ 0.0, -0.1, 2.1, -0.7, -1.1, 0.7, -0.2, -2.1, -1.5, -2.5, -2.0, -2.3 ],
        [ 0.0, -1.0, 0.5, 1.8, -2.2, 0.3, 0.7, -0.1, 0.3, 0.2, -0.9, -0.2, 0.7 ]]
    
    static private let DELTA_G: [[Double]] =  [
        [ 0.0 ],
        [ 10.7, 17.9 ],
        [ -8.6, -3.3, 2.4 ],
        [ 3.1, -6.2, -0.4, -10.4 ],
        [ -0.4, 0.8, -9.2, 4.0, -4.2 ],
        [ -0.2, 0.1, -1.4, 0.0, 1.3, 3.8 ],
        [ -0.5, -0.2, -0.6, 2.4, -1.1, 0.3, 1.5 ],
        [ 0.2, -0.2, -0.4, 1.3, 0.2, -0.4, -0.9, 0.3 ],
        [ 0.0, 0.1, -0.5, 0.5, -0.2, 0.4, 0.2, -0.4, 0.3 ],
        [ 0.0, -0.1, -0.1, 0.4, -0.5, -0.2, 0.1, 0.0, -0.2, -0.1 ],
        [ 0.0, 0.0, -0.1, 0.3, -0.1, -0.1, -0.1, 0.0, -0.2, -0.1, -0.2 ],
        [ 0.0, 0.0, -0.1, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.1, -0.1 ],
        [ 0.1, 0.0, 0.0, 0.1, -0.1, 0.0, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]]
    
    static private let DELTA_H: [[Double]] = [
        [ 0.0 ],
        [ 0.0, -26.8 ],
        [ 0.0, -27.1, -13.3 ],
        [ 0.0, 8.4, -0.4, 2.3 ],
        [ 0.0, -0.6, 5.3, 3.0,-5.3 ],
        [ 0.0, 0.4, 1.6, -1.1, 3.3, 0.1 ],
        [ 0.0, 0.0, -2.2, -0.7, 0.1, 1.0, 1.3 ],
        [ 0.0, 0.7, 0.5, -0.2, -0.1, -0.7, 0.1, 0.1 ],
        [ 0.0, -0.3, 0.3, 0.3, 0.6, -0.1, -0.2, 0.3, 0.0 ],
        [ 0.0, -0.2, -0.1, -0.2, 0.1, 0.1, 0.0, -0.2, 0.4, 0.3 ],
        [ 0.0, 0.1, -0.1, 0.0, 0.0, -0.2, 0.1, -0.1, -0.2, 0.1, -0.1 ],
        [ 0.0, 0.0, 0.1, 0.0, 0.1, 0.0, 0.0, 0.1, 0.0, -0.1, 0.0, -0.1 ],
        [ 0.0, 0.0, 0.0, -0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]]
    
    static private let BASE_TIME: Double = {
        var startDateComponents = DateComponents()
        startDateComponents.year = 2015
        startDateComponents.month = 1
        startDateComponents.day = 1
        return Calendar(identifier: .gregorian).date(from: startDateComponents)!.timeIntervalSince1970 * 1000
    }()
    
    // The ratio between the Gauss-normalized associated Legendre functions and
    // the Schmid quasi-normalized ones. Compute these once staticly since they
    // don't depend on input variables at all.
    static private let SCHMIDT_QUASI_NORM_FACTORS = computeSchmidtQuasiNormFactors(G_COEFF.count);
    /**
     * Estimate the magnetic field at a given point and time.
     *
     * @param gdLatitudeDeg
     *            Latitude in WGS84 geodetic coordinates -- positive is east.
     * @param gdLongitudeDeg
     *            Longitude in WGS84 geodetic coordinates -- positive is north.
     * @param altitudeMeters
     *            Altitude in WGS84 geodetic coordinates, in meters.
     * @param timeMillis
     *            Time at which to evaluate the declination, in milliseconds
     *            since January 1, 1970. (approximate is fine -- the declination
     *            changes very slowly).
     */
    public convenience init(gdLatitudeDeg: Double,
                            gdLongitudeDeg: Double) {

        let gregorianCalendar = Calendar(identifier: .gregorian)
        let todaysDate = Date()

        var todayDateComponents = DateComponents()
        todayDateComponents.year = gregorianCalendar.component(.year, from: todaysDate)
        todayDateComponents.month = gregorianCalendar.component(.month, from: todaysDate)
        todayDateComponents.day = gregorianCalendar.component(.day, from: todaysDate)

        let today = gregorianCalendar.date(from: todayDateComponents)!
        
        self.init(gdLatitudeDeg: gdLatitudeDeg, gdLongitudeDeg: gdLongitudeDeg, altitudeMeters: 0, time: today)
    }
    
    public init(gdLatitudeDeg: Double,
                gdLongitudeDeg: Double,
                altitudeMeters: Double,
                time: Date) {
        let timeMillis = Double(time.timeIntervalSince1970 * 1000)
        let MAX_N = GeomagneticField.G_COEFF.count // Maximum degree of the coefficients.
        // We don't handle the north and south poles correctly -- pretend that
        // we're not quite at them to avoid crashing.
        var gdLatitudeDeg = gdLatitudeDeg
        gdLatitudeDeg = min(90.0 - 1e-5,
                            max(-90.0 + 1e-5, gdLatitudeDeg));
        computeGeocentricCoordinates(gdLatitudeDeg,
                                     gdLongitudeDeg,
                                     altitudeMeters)
        
        // Note: LegendreTable computes associated Legendre functions for
        // cos(theta).  We want the associated Legendre functions for
        // sin(latitude), which is the same as cos(PI/2 - latitude), except the
        // derivate will be negated.
        let legendre = LegendreTable(maxN: MAX_N - 1, thetaRad: Double.pi / 2.0 - mGcLatitudeRad)
        // Compute a table of (EARTH_REFERENCE_RADIUS_KM / radius)^n for i in
        // 0..MAX_N-2 (this is much faster than calling Math.pow MAX_N+1 times).
        var relativeRadiusPower = [Double](repeating: 0.0, count: MAX_N + 2)
        relativeRadiusPower[0] = 1.0
        relativeRadiusPower[1] = GeomagneticField.EARTH_REFERENCE_RADIUS_KM / mGcRadiusKm
        for i in 2...relativeRadiusPower.count-1 {
            relativeRadiusPower[i] = relativeRadiusPower[i - 1] * relativeRadiusPower[1]
        }
        // Compute tables of sin(lon * m) and cos(lon * m) for m = 0..MAX_N --
        // this is much faster than calling Math.sin and Math.com MAX_N+1 times.
        var sinMLon = [Double](repeating: 0, count: MAX_N)
        var cosMLon = [Double](repeating: 0, count: MAX_N)
        sinMLon[0] = 0.0
        cosMLon[0] = 1.0
        sinMLon[1] = sin(mGcLongitudeRad);
        cosMLon[1] = cos(mGcLongitudeRad);
        for m in 2...MAX_N-1 {
            // Standard expansions for sin((m-x)*theta + x*theta) and
            // cos((m-x)*theta + x*theta).
            let x = m >> 1
            sinMLon[m] = sinMLon[m-x] * cosMLon[x] + cosMLon[m-x] * sinMLon[x]
            cosMLon[m] = cosMLon[m-x] * cosMLon[x] - sinMLon[m-x] * sinMLon[x]
        }
        let inverseCosLatitude: Double = 1.0 / cos(mGcLatitudeRad);
        let yearsSinceBase =
            (timeMillis - GeomagneticField.BASE_TIME) / (365.0 * 24.0 * 60.0 * 60.0 * 1000.0);
        // We now compute the magnetic field strength given the geocentric
        // location. The magnetic field is the derivative of the potential
        // function defined by the model. See NOAA Technical Report: The US/UK
        // World Magnetic Model for 2010-2015 for the derivation.
        var gcX: Double = 0.0  // Geocentric northwards component.
        var gcY: Double = 0.0  // Geocentric eastwards component.
        var gcZ: Double = 0.0  // Geocentric downwards component.
        for n in 1...MAX_N-1 {
            let fn = Double(n)
            for m in 0...n {
                let fm = Double(m)
                // Adjust the coefficients for the current date.
                let g = GeomagneticField.G_COEFF[n][m] + yearsSinceBase * GeomagneticField.DELTA_G[n][m]
                let h = GeomagneticField.H_COEFF[n][m] + yearsSinceBase * GeomagneticField.DELTA_H[n][m]
                // Negative derivative with respect to latitude, divided by
                // radius.  This looks like the negation of the version in the
                // NOAA Techincal report because that report used
                // P_n^m(sin(theta)) and we use P_n^m(cos(90 - theta)), so the
                // derivative with respect to theta is negated.
                gcX += relativeRadiusPower[n+2]
                    * (g * cosMLon[m] + h * sinMLon[m])
                    * legendre.mPDeriv[n][m]
                    * GeomagneticField.SCHMIDT_QUASI_NORM_FACTORS[n][m];
                // Negative derivative with respect to longitude, divided by
                // radius.
                gcY += relativeRadiusPower[n+2] * fm
                    * (g * sinMLon[m] - h * cosMLon[m])
                    * legendre.mP[n][m]
                    * GeomagneticField.SCHMIDT_QUASI_NORM_FACTORS[n][m]
                    * inverseCosLatitude;
                // Negative derivative witsh respect to radius.
                gcZ -= (fn + 1.0) * relativeRadiusPower[n+2]
                    * (g * cosMLon[m] + h * sinMLon[m])
                    * legendre.mP[n][m]
                    * GeomagneticField.SCHMIDT_QUASI_NORM_FACTORS[n][m];
            }
        }
        // Convert back to geodetic coordinates.  This is basically just a
        // rotation around the Y-axis by the difference in latitudes between the
        // geocentric frame and the geodetic frame.
        let latDiffRad: Double = Double(gdLatitudeDeg).degreesToRadians - Double(mGcLatitudeRad);
        mX = Double(Double(gcX) * cos(latDiffRad) + Double(gcZ) * sin(latDiffRad));
        mY = gcY;
        mZ = Double(-Double(gcX) * sin(latDiffRad) + Double(gcZ) * cos(latDiffRad))
    }
    /**
     * @return The X (northward) component of the magnetic field in nanoteslas.
     */
    public var x: Double {
        return mX;
    }
    /**
     * @return The Y (eastward) component of the magnetic field in nanoteslas.
     */
    public var y: Double {
        return mY;
    }
    /**
     * @return The Z (downward) component of the magnetic field in nanoteslas.
     */
    public var z: Double {
        return mZ;
    }
    /**
     * @return The declination of the horizontal component of the magnetic
     *         field from true north, in degrees (i.e. positive means the
     *         magnetic field is rotated east that much from true north).
     */
    public var declination: Double {
        return atan2(mY, mX).radiansToDegrees;
    }
    /**
     * @return The inclination of the magnetic field in degrees -- positive
     *         means the magnetic field is rotated downwards.
     */
    public var inclination: Double {
        return atan2(mZ,horizontalStrength).radiansToDegrees;
        
    }
    /**
     * @return  Horizontal component of the field strength in nonoteslas.
     */
    public var horizontalStrength:  Double {
        return hypot(mX, mY);
    }
    /**
     * @return  Total field strength in nanoteslas.
     */
    public var fieldStrength: Double {
        return sqrt(mX * mX + mY * mY + mZ * mZ);
    }
    /**
     * @param gdLatitudeDeg
     *            Latitude in WGS84 geodetic coordinates.
     * @param gdLongitudeDeg
     *            Longitude in WGS84 geodetic coordinates.
     * @param altitudeMeters
     *            Altitude above sea level in WGS84 geodetic coordinates.
     * @return Geocentric latitude (i.e. angle between closest point on the
     *         equator and this point, at the center of the earth.
     */
    private func computeGeocentricCoordinates(_ gdLatitudeDeg: Double,
                                              _ gdLongitudeDeg: Double,
                                              _ altitudeMeters: Double) {
        let altitudeKm = altitudeMeters / 1000.0
        let a2 = GeomagneticField.EARTH_SEMI_MAJOR_AXIS_KM * GeomagneticField.EARTH_SEMI_MAJOR_AXIS_KM
        let b2 = GeomagneticField.EARTH_SEMI_MINOR_AXIS_KM * GeomagneticField.EARTH_SEMI_MINOR_AXIS_KM
        let gdLatRad = Double(gdLatitudeDeg).degreesToRadians
        let clat: Double = Double(cos(gdLatRad))
        let slat: Double = Double(sin(gdLatRad))
        let tlat: Double = slat / clat;
        let latRad = sqrt(a2 * clat * clat + b2 * slat * slat)
        mGcLatitudeRad = atan(tlat * (latRad * altitudeKm + b2) / (latRad * altitudeKm + a2))
        mGcLongitudeRad = gdLongitudeDeg.degreesToRadians
        let radSq = altitudeKm * altitudeKm
            + 2 * altitudeKm * sqrt(a2 * clat * clat +
                b2 * slat * slat)
            + (a2 * a2 * clat * clat + b2 * b2 * slat * slat)
            / (a2 * clat * clat + b2 * slat * slat)
        mGcRadiusKm = sqrt(radSq)
    }
    
}

fileprivate extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

extension GeomagneticField {
    
    func magneticToTrue(magneticDegree: Double) -> Double {
        return magneticDegree + self.declination
    }
    
    func trueToMagnetic(trueDegree: Double) -> Double {
        return trueDegree - self.declination
    }
    
}
