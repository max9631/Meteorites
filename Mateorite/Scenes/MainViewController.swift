//
//  MainViewController.swift
//  Mateorite
//
//  Created by Adam Salih on 17.04.2021.
//

import UIKit
import BottomSheet
import Combine
import DynamicContent

class MainViewModel {
    private let url: URL = "https://data.nasa.gov/resource/y77d-th95.json"
    private let token: String = "THhtPVVG3TovCfxbxXoYTYvAU"
    private var cancellables: Set<AnyCancellable> = Set()
    private let decoder: JSONDecoder = .init()
    
    var meteorites: CurrentValueSubject<[Meteorite], Never> = CurrentValueSubject([])
    var meteoritesState: CurrentValueSubject<DynamicContentDefaultState, Never> = CurrentValueSubject(.loading)
    
    init() {}
    
    func loadMeteorites() {
        meteoritesState.send(.loading)
        var request = URLRequest(url: URL(string: "https://data.nasa.gov/resource/y77d-th95.json")!)
        request.httpMethod = "GET"
        request.addValue(self.token, forHTTPHeaderField: "X-App-Token")
        request.cachePolicy = .reloadIgnoringCacheData
        let meteorites: AnyPublisher<[Meteorite], Never> = URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw AppError.generalCommunicationError
                }
                return data
            }
            .decode(type: [Meteorite]?.self, decoder: decoder)
            .map { $0?.filter { $0.geolocation != nil } }
            .catch { [weak self] error -> Just<[Meteorite]?> in
                self?.meteoritesState.send(.error(message: "An error occured, try again", action: { [weak self] in
                    self?.loadMeteorites()
                }))
                return Just(nil)
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()

        meteorites
            .filter { !$0.isEmpty }
            .sink(receiveValue: { [weak self] meteorites in
                self?.meteorites.value = meteorites
                self?.meteoritesState.send(.content)
            })
            .store(in: &cancellables)
    }
}

class MainViewController: BottomSheetController {
    var viewModel: MainViewModel = MainViewModel()
    var mapController: MapViewController? { getController(in: masterViewController) }
    var listController: MeteoriteListViewController? { contextViewControllers.compactMap(getController).first }
    var cancellables: Set<AnyCancellable> = Set()
        
    override func viewDidLoad() {
        position.shouldSetAdditionalMasterSafeAreaInset = true
        position.bottomSheetRegularSizeClassPrezentation = .bottom(side: .left)
        super.viewDidLoad()
        viewModel.loadMeteorites()
    }
    
    private func getController<T: UIViewController>(in controller: UIViewController?) -> T? {
        switch controller {
        case let tController as T:
            return tController
        case let navigationController as UINavigationController:
            return navigationController.visibleViewController.flatMap(getController)
        case let tabController as UITabBarController:
            return tabController.selectedViewController.flatMap(getController)
        default:
            return nil
        }
    }
    
    
}
