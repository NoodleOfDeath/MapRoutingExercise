//
//  FutureExerciseApp.swift
//  Shared
//
//  Created by tmorgan on 2/16/22.
//

import SwiftUI
import MapKit

@main
struct FutureExerciseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(waypoints: loadWaypoints(from: "waypoints"))
        }
    }
}

/// Simple data structure representing an identifiable waypoint.
struct Waypoint: Identifiable, CustomStringConvertible {
    
    let id = UUID()
    
    /// Latitude of this waypoint.
    let latitude: Double
    /// Longitude of this waypoint.
    let longitude: Double
    /// Heartrate of this waypoint.
    let heartrate: Int
    
    /// An invalid waypoint with magnitudes set to NaN, NaN, and zero, respectively.
    static let nan = Waypoint(latitude: .nan, longitude:  .nan, heartrate: 0)
    
    /// Overridden for debugging purposes.
    var description: String {
        return "\(id): (\(latitude), \(longitude), \(heartrate))"
    }
    
    /// 2D coordinate of this waypoint.
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Returns `true` if either latitude or longitude are equal to `.nan`.
    var isNaN: Bool {
        return latitude == .nan || longitude == .nan
    }
    
}

/// Loads all waypoints from a specified JSON file. Expected file format is a JSON
/// array of `(n, 3)` shape where `n` is the number of waypoints each represented
/// by a 3-tuple containing latitude (`Double`), longitude (`Double`), and heartrate (`int`).
///
/// - Parameter file: in the main bundle to load waypoints from.
///
/// - Returns: an array of waypoints, if successfully parsed; an empty array, othewise.
func loadWaypoints(from file: String) -> Array<Waypoint> {

    var waypoints = Array<Waypoint>();

    // If issues are encountered during file reading return no waypoints.
    guard
        let path = Bundle.main.path(forResource: file, ofType: "json"),
        let data = (try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)),
        let jsonResult = (try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)),
        let data = jsonResult as? Array<Array<NSNumber>>
        else { return waypoints }

    // Convert each tuple into a Waypoint object.
    for datum in data {
        guard datum.count >= 3 else { continue }
        let (latitude, longitude, heartrate) = (datum[0].doubleValue, datum[1].doubleValue, datum[2].intValue)
        waypoints.append(Waypoint(latitude: latitude,
                                  longitude: longitude,
                                  heartrate: heartrate))
    }

    return waypoints
    
}
