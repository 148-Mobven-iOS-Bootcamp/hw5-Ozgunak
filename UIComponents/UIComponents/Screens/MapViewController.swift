//
//  MapViewController.swift
//  UIComponents
//
//  Created by Semih Emre ÜNLÜ on 9.01.2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    private var routeIndex = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkLocationPermission()
        addLongGestureRecognizer()
    
        
    }

    

    private var currentCoordinate: CLLocationCoordinate2D?
    private var destinationCoordinate: CLLocationCoordinate2D?

    func addLongGestureRecognizer() {
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(handleLongPressGesture(_ :)))
        self.view.addGestureRecognizer(longPressGesture)
    }

    @objc func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        destinationCoordinate = coordinate

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Pinned"
        mapView.addAnnotation(annotation)
    }

    func checkLocationPermission() {
        switch self.locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            locationManager.requestLocation()
        case .denied, .restricted:
            //popup gosterecegiz. go to settings butonuna basildiginda
            //kullaniciyi uygulamamizin settings sayfasina gonder
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            fatalError()
        }
    }


    //MARK: - Homework 1 Toolbar eklendi,

    @IBAction func drawRoutePressed(_ sender: UIBarButtonItem) {
        // if route parameter is 3 then it shows all routes
        drawMap(route: 3)
        routeIndex = 3
    }
    
    @IBAction func rightRoutePressed(_ sender: UIBarButtonItem) {
        switch routeIndex {
        case 3:
            routeIndex = 0
        case 2:
            routeIndex = 0
        case 1:
            routeIndex = 2
        case 0:
            routeIndex = 1
        default:
            routeIndex = 3
        }
        drawMap(route: routeIndex)
    }
    @IBAction func leftRoutePressed(_ sender: UIBarButtonItem) {
        switch routeIndex {
        case 3:
            routeIndex = 0
        case 2:
            routeIndex = 1
        case 1:
            routeIndex = 0
        case 0:
            routeIndex = 2
        default:
            routeIndex = 3
        }
        drawMap(route: routeIndex)
    }
    
    @IBAction func showCurrentLocationPressed(_ sender: UIBarButtonItem) {
        locationManager.requestLocation()

    }
    
    func drawMap(route: Int){
        // When calculation new routes removes map overlays first
        mapView.removeOverlays(mapView.overlays)
        
        guard let currentCoordinate = currentCoordinate,
              let destinationCoordinate = destinationCoordinate else {
                  // log
                  // alert
            return
        }
        self.navigationItem.title = "Calculating route"
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let source = MKMapItem(placemark: sourcePlacemark)

        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        let destination = MKMapItem(placemark: destinationPlacemark)

        let directionRequest = MKDirections.Request()
        directionRequest.source = source
        directionRequest.destination = destination
        directionRequest.transportType = .automobile
        directionRequest.requestsAlternateRoutes = true

        let direction = MKDirections(request: directionRequest)

        direction.calculate { response, error in
            guard error == nil else {
                //log error
                //show error
                print(error?.localizedDescription)
                return
            }

            //MARK: - At first call shows all routes then shows individual routes.

            if route != 3 {
            guard let routeList = response?.routes else { return }
                let polyline: MKPolyline = routeList[route].polyline
                self.mapView.addOverlay(polyline, level: .aboveLabels)

                let rect = polyline.boundingMapRect
                let region = MKCoordinateRegion(rect)
                self.mapView.setRegion(region, animated: true)
            }else {
                guard let routeList = response?.routes else { return }
                routeList.forEach { way in
                    let polyline: MKPolyline = way.polyline
                    self.mapView.addOverlay(polyline, level: .aboveLabels)

                    let rect = polyline.boundingMapRect
                    let region = MKCoordinateRegion(rect)
                    self.mapView.setRegion(region, animated: true)
                }

            }
            //Odev 1 navigate buttonlari ile diger route'lar gosterilmelidir.
        }
    }
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    func getColor() -> UIColor {
        // while showing all routes stroke color is red, otherwise blue
        if routeIndex == 3 {
            return .red
        }else {
            return .blue
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        currentCoordinate = coordinate
        print("latitude: \(coordinate.latitude)")
        print("longitude: \(coordinate.longitude)")

        mapView.setCenter(coordinate, animated: true)
        //MARK: - Navigation item title chances when location button pressed.

        self.navigationItem.title = "Showing center"
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { _ in
            self.navigationItem.title = ""
        })
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermission()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        self.navigationItem.title = (routeIndex == 3) ? "Showing All Roues" : "Showing Route \(routeIndex + 1)"
        renderer.strokeColor = getColor()
        renderer.fillColor = .yellow
        renderer.lineWidth = 8
        return renderer
    }
    
}
