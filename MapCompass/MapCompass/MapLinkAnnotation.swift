import Foundation
import MapKit

final class MapLinkAnnotation: NSObject, MKAnnotation, Identifiable {
    let id = UUID()
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let url: URL

    init(coordinate: CLLocationCoordinate2D, title: String?, url: URL) {
        self.coordinate = coordinate
        self.title = title
        self.url = url
        super.init()
    }

    var subtitle: String? {
        url.host
    }
}

extension MapLinkAnnotation: Hashable {
    static func == (lhs: MapLinkAnnotation, rhs: MapLinkAnnotation) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
