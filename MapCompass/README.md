# MapCompass

An iOS app that opens directly to a MapKit view centered on the user's current location, locks to their heading, and allows exploring the map with a recenter control. Tapping featured map dots opens an in-app Safari sheet with additional details.

## Features

- Requests foreground location permission and follows the user's position with heading-based rotation for a compass-like experience.
- Customizable default zoom (see comments in `ContentView.swift`).
- Automatically shows a **Recenter** button whenever the user pans or zooms away from their live position.
- Supports pinch/zoom exploration while still displaying the user's location indicator.
- Adds interactive map dots that open web content inside a half-height Safari sheet.

## Example annotation

The starter project includes a property marker at `51.904181983991165, -2.076733453302931` that opens [this Rightmove listing](https://www.rightmove.co.uk/properties/163231814#/?channel=RES_BUY).

## Getting started

1. Open `MapCompass/MapCompass.xcodeproj` in Xcode 15 or newer.
2. Update the signing team under **Signing & Capabilities**.
3. Build and run on a real device to take advantage of live location and compass heading.

## Customization tips

- **Zoom level**: Adjust the `initialSpan` constant in `ContentView.swift`. Smaller deltas zoom in closer to the user.
- **Annotations**: Add more `MapLinkAnnotation` items to the `propertyAnnotations` array in `ContentView.swift`.
- **Appearance**: Update colors, assets, or the map's point-of-interest filter within `CompassMapView.swift`.
