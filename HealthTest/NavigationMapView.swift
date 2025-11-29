import SwiftUI
import MapKit

struct NavigationMapView: View {
    @StateObject var locationManager = LocationManager()
    @StateObject var routeManager = RouteManager()
    @State var checkpoints = sampleCheckpoints
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isDemoMode = false // ✅ Demo mode flag


    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                UserAnnotation()
                
                // Checkpoing Maker
                ForEach(checkpoints) { point in
                    Annotation(point.name, coordinate: point.coordinate) {
                        Image(systemName: point.isVisited ? "flag.checkered.circle.fill" : "flag.circle.fill")
                            .resizable()
                            .foregroundStyle(point.isVisited ? .green : .red)
                            .frame(width: 30, height: 30)
                            .background(.white)
                            .clipShape(Circle())
                    }
                }
                
                //  Path Route (grey)
                if routeManager.passedCoordinates.count >= 2 {
                    MapPolyline(coordinates: routeManager.passedCoordinates)
                        .stroke(.gray, lineWidth: 5)
                }
                
                // Remain Route (blue)
                if routeManager.remainingCoordinates.count >= 2 {
                    MapPolyline(coordinates: routeManager.remainingCoordinates)
                        .stroke(.blue, lineWidth: 5)
                }
            }
            .mapStyle(.standard)
            .ignoresSafeArea(.all)
            .onAppear {
                routeManager.fetchFullRoute(checkpoints: checkpoints)
            }
            .onChange(of: locationManager.userLocation) { newLocation in
                guard let userLoc = newLocation else { return }
                

                routeManager.updateUserLocation(userLoc)
                
                checkArrival(userLocation: userLoc)
            }
                        VStack {
                Spacer()
                
                // Demo Control Button
                HStack(spacing: 12) {
                    Button(action: {
                        isDemoMode = true
                        routeManager.startDemo()
                    }) {
                        Label("start", systemImage: "play.fill")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        routeManager.stopDemo()
                    }) {
                        Label("pause", systemImage: "pause.fill")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        isDemoMode = false
                        routeManager.resetDemo()
                    }) {
                        Label("reset", systemImage: "arrow.counterclockwise")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                
            
            }
            
        }
    }
    
    func checkArrival(userLocation: CLLocation) {
        for index in checkpoints.indices {
            if checkpoints[index].isVisited { continue }
            
            let targetLoc = CLLocation(
                latitude: checkpoints[index].coordinate.latitude,
                longitude: checkpoints[index].coordinate.longitude
            )
            
            let distance = userLocation.distance(from: targetLoc)
            
            if distance < 20.0 {
                checkpoints[index].isVisited = true
                print("🎉 \(checkpoints[index].name) arrived!")
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
    }
}
