//
//  MapViewController.swift
//  Mateorite
//
//  Created by Adam Salih on 17.04.2021.
//

import UIKit
import MapKit
import Combine

class MeteoriteAnnotation: NSObject, MKAnnotation {
    var meteorite: Meteorite
    var coordinate: CLLocationCoordinate2D
    
    init?(meteorite: Meteorite) {
        guard let coordinates = meteorite.geolocation?.coordinates, coordinates.count >= 2 else {
            return nil
        }
        self.coordinate = CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
        self.meteorite = meteorite
    }
}

class MapViewController: UIViewController {
    @IBOutlet private weak var mapView: MKMapView!
    
    var meteorites: CurrentValueSubject<[Meteorite:MeteoriteAnnotation], Never> = CurrentValueSubject([:])
    var selectedMeteorite: CurrentValueSubject<Meteorite?, Never> = CurrentValueSubject(nil)
    private var cancellables: Set<AnyCancellable> = Set()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mapView = self.mapView, let main = bottomSheetController as? MainViewController else {
            return
        }
        mapView.delegate = self
        func getAnnotations(for meteorites: [Meteorite]) -> [Meteorite: MeteoriteAnnotation] {
            meteorites
                .compactMap(MeteoriteAnnotation.init)
                .reduce([Meteorite:MeteoriteAnnotation]()) { (result, annotation) in
                    var result = result
                    result[annotation.meteorite] = annotation
                    return result
                }
        }
        meteorites
            .receive(on: DispatchQueue.main)
            .map(\.values)
            .map(Array.init)
            .sink { meteorites in
                mapView.removeAnnotations(mapView.annotations)
                mapView.addAnnotations(meteorites)
            }
            .store(in: &cancellables)
        meteorites.value = getAnnotations(for: main.viewModel.meteorites.value)
        main.viewModel.meteorites
            .map(getAnnotations)
            .subscribe(meteorites)
            .store(in: &cancellables)
    }
    
    func select(meteorite: Meteorite){
        guard let annotation = meteorites.value[meteorite] else {
            return
        }
        mapView.selectAnnotation(annotation, animated: true)
        mapView.setCenter(annotation.coordinate, animated: true)
    }
    
    var ignoreDeselectSignal: Bool = false
    func deselect(meteorite: Meteorite) {
        guard let annotation = meteorites.value[meteorite] else {
            return
        }
        ignoreDeselectSignal = true
        mapView.deselectAnnotation(annotation, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let mateoriteAnnotation =  view.annotation as? MeteoriteAnnotation,
              let main = bottomSheetController as? MainViewController else {
            return
        }
        main.listController?.show(meteorite: mateoriteAnnotation.meteorite)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard !ignoreDeselectSignal, let meteorite = bottomSheetController?.visibleContextViewController as? MeteoriteViewController else {
            ignoreDeselectSignal = false
            return
        }
        meteorite.pop()
    }
}
