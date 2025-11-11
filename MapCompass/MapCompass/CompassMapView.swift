import MapKit
import SwiftUI
import UIKit

struct CompassMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var followUser: Bool
    @Binding var shouldResetTracking: Bool
    @Binding var showRecenter: Bool
    @Binding var selectedAnnotation: MapLinkAnnotation?

    let annotations: [MapLinkAnnotation]

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsCompass = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = false
        mapView.pointOfInterestFilter = .includingAll
        mapView.setRegion(region, animated: false)
        mapView.addAnnotations(annotations)
        context.coordinator.mapView = mapView
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.ensureAnnotations(on: mapView)

        if followUser {
            showRecenter = false
        }

        if context.coordinator.resetToken != shouldResetTracking {
            context.coordinator.resetToken = shouldResetTracking
            context.coordinator.isProgrammaticChange = true
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
        }

        if followUser {
            if mapView.userTrackingMode != .followWithHeading {
                context.coordinator.isProgrammaticChange = true
                mapView.setUserTrackingMode(.followWithHeading, animated: true)
            }
            if !mapView.region.isApproximatelyEqual(to: region) {
                context.coordinator.isProgrammaticChange = true
                mapView.setRegion(region, animated: true)
            }
        } else {
            if mapView.userTrackingMode != .none {
                context.coordinator.isProgrammaticChange = true
                mapView.setUserTrackingMode(.none, animated: true)
            }
        }
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CompassMapView
        weak var mapView: MKMapView?
        var isProgrammaticChange = false
        var resetToken = false

        init(parent: CompassMapView) {
            self.parent = parent
        }

        func ensureAnnotations(on mapView: MKMapView) {
            let existing = Set(mapView.annotations.compactMap { $0 as? MapLinkAnnotation })
            let desired = Set(parent.annotations)
            if existing != desired {
                mapView.removeAnnotations(Array(existing.subtracting(desired)))
                mapView.addAnnotations(Array(desired.subtracting(existing)))
            }
        }

        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            guard mapView.isUserInteractionEnabled else { return }
            guard !isProgrammaticChange else { return }
            if mapView.gestureRecognizers?.contains(where: { $0.state == .began || $0.state == .changed || $0.state == .ended }) == true {
                parent.followUser.wrappedValue = false
            }
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            if isProgrammaticChange {
                isProgrammaticChange = false
                parent.region.wrappedValue = mapView.region
                return
            }
            parent.region.wrappedValue = mapView.region
            if !parent.followUser.wrappedValue {
                parent.showRecenter.wrappedValue = true
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            if let linkAnnotation = annotation as? MapLinkAnnotation {
                let identifier = "MapLinkAnnotationView"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.annotation = annotation
                view.canShowCallout = true
                view.markerTintColor = UIColor.systemGreen
                view.glyphImage = UIImage(systemName: "mappin")
                return view
            }
            return nil
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MapLinkAnnotation else { return }
            parent.selectedAnnotation.wrappedValue = annotation
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
}

private extension MKCoordinateRegion {
    func isApproximatelyEqual(to other: MKCoordinateRegion) -> Bool {
        let deltaLatitude = abs(center.latitude - other.center.latitude)
        let deltaLongitude = abs(center.longitude - other.center.longitude)
        let deltaLatSpan = abs(span.latitudeDelta - other.span.latitudeDelta)
        let deltaLonSpan = abs(span.longitudeDelta - other.span.longitudeDelta)
        return deltaLatitude < 0.0001 && deltaLongitude < 0.0001 && deltaLatSpan < 0.0001 && deltaLonSpan < 0.0001
    }
}
