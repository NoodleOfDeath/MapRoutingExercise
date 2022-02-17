//
//  ContentView.swift
//  Shared
//
//  Created by tmorgan on 2/16/22.
//

import SwiftUI
import MapKit

/// View that displays a map with an annotation indicating waypoint traversal over time and heartrate.
struct ContentView: View {
    
    /// Waypoints of this content view.
    private let waypoints: Array<Waypoint>
    
    /// Map region to clip the map to.
    @State private var mapRegion: MKCoordinateRegion
    /// Current step.
    @State private var step: Int = 0
    
    /// Current waypoint at the current step. Will return `.nan` if `step` is
    /// out of the bounds of `waypoints`.
    private var currentWaypoint: Waypoint {
        guard step < waypoints.count else { return .nan }
        return waypoints[step]
    }
    
    /// Timer allows us to update the current waypoint by one step each second.
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    /// Creates a new content view instance with an initial collection of waypoints.
    ///
    /// - Parameter waypoints: to initialize this content view with.
    ///
    /// - Returns: A new content view instance with initial waypoints set to `waypoints`.
    init(waypoints: Array<Waypoint>) {
        // Determine the map region most appropriate for the entire route.
        var mapRect: MKMapRect = .null;
        for waypoint in waypoints {
            let point = MKMapPoint(waypoint.coordinate)
            let pointRect = MKMapRect(origin: point,
                                      size: MKMapSize(width: 0.1, height: 0.1))
            mapRect = mapRect.union(pointRect)
        }
        self.waypoints = waypoints
        mapRegion = MKCoordinateRegion(mapRect)
    }
    
    /// Displays a map that dynamically draws a circle at the current waypoint and a label containing the heartrate at the current time step.
    var body: some View {
        VStack {
            Text("Steps Elapsed: \(step + 1)")
            Text("Coordindate: (\(currentWaypoint.coordinate.latitude), \(currentWaypoint.coordinate.longitude))")
            Text("Heart Rate: \(currentWaypoint.heartrate) BPM")
            Map(coordinateRegion: $mapRegion, annotationItems: [currentWaypoint]) { waypoint in
                MapAnnotation(coordinate: waypoint.coordinate) {
                    Circle()
                        .strokeBorder(.blue)
                        .background(Circle().foregroundColor(.blue))
                        .frame(width: 15.0, height: 15.0)
                    Text("❤️ \(waypoint.heartrate)")
                        .frame(width: 100.0, height: 20.0, alignment: .center)
                        .background(.white)
                        .offset(x: 0.0, y: -50.0)
                }
            }
        }.onReceive(timer) { _ in
            // Prevent IOOB error
            if step + 1 < waypoints.count {
                step += 1
            }
        }
    }
    
}

/// Simple preview provider for the content view class.
struct ContentView_Previews : PreviewProvider {
    
    typealias Previews = ContentView
    
    static var previews: Previews {
        ContentView(waypoints: [Waypoint(latitude: 37.794828600000002,
                                         longitude: -122.41646771000001,
                                         heartrate: 76)])
    }
    
}
