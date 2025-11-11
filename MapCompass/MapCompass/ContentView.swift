import Combine
import MapKit
import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    // Adjust the zoom level by editing the latitudeDelta and longitudeDelta below.
    // Smaller delta values zoom in closer to the user's location.
    private let initialSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)

    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.5072, longitude: -0.1276),
        span: initialSpan
    )

    @State private var isFollowingUser = true
    @State private var showRecenterButton = false
    @State private var selectedAnnotation: MapLinkAnnotation?
    @State private var shouldResetTracking = false

    private let propertyAnnotations: [MapLinkAnnotation] = [
        MapLinkAnnotation(
            coordinate: CLLocationCoordinate2D(latitude: 51.904181983991165, longitude: -2.076733453302931),
            title: "Rightmove Listing",
            url: URL(string: "https://www.rightmove.co.uk/properties/163231814#/?channel=RES_BUY")!
        )
    ]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            CompassMapView(
                region: $mapRegion,
                followUser: $isFollowingUser,
                shouldResetTracking: $shouldResetTracking,
                showRecenter: $showRecenterButton,
                selectedAnnotation: $selectedAnnotation,
                annotations: propertyAnnotations
            )
            .ignoresSafeArea()
            .onReceive(locationManager.$lastLocation.compactMap { $0 }) { location in
                guard isFollowingUser else { return }
                updateRegion(with: location)
            }
            .onAppear {
                locationManager.requestPermission()
            }

            if showRecenterButton {
                Button {
                    recenterOnUser()
                } label: {
                    Text("Recenter")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.thinMaterial, in: Capsule())
                }
                .padding(.top, 12)
                .padding(.trailing, 16)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .sheet(item: $selectedAnnotation) { annotation in
            SafariSheet(url: annotation.url)
                .presentationDetents([.fraction(0.5), .large])
        }
    }

    private func updateRegion(with location: CLLocation) {
        mapRegion = MKCoordinateRegion(center: location.coordinate, span: initialSpan)
    }

    private func recenterOnUser() {
        guard let location = locationManager.lastLocation else {
            shouldResetTracking.toggle()
            return
        }
        withAnimation {
            isFollowingUser = true
            showRecenterButton = false
        }
        mapRegion = MKCoordinateRegion(center: location.coordinate, span: initialSpan)
        shouldResetTracking.toggle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
