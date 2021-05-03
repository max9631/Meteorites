//
//  MeteoritesViewController.swift
//  YouTube
//
//  Created by Adam Salih on 17.04.2021.
//

import UIKit
import BottomSheet
import Combine
import DynamicContent

class MeteoriteListViewController: UIViewController {
    var meteorites: CurrentValueSubject<[Meteorite], Never> = CurrentValueSubject([])
    var contentState: CurrentValueSubject<DynamicContentDefaultState, Never> = CurrentValueSubject(.loading)
    
    @IBOutlet weak var dynamicTableViewContainer: UIView!
    var dynamicTableView: DynamicTableView!
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var didAppearAtLeastOnce: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        dynamicTableView = DynamicTableView(embedIn: dynamicTableViewContainer, initialState: .loading, configuration: { [weak self] tablewView in
            tablewView.delegate = self
            tablewView.dataSource = self
                let nib = UINib(nibName: "MeteoriteTableViewCell", bundle: nil)
            tablewView.register(nib, forCellReuseIdentifier: "MeteoriteTableViewCell")
        })
        guard let main = bottomSheetController as? MainViewController else {
            return
        }
        main.viewModel.meteorites
            .receive(on: DispatchQueue.main)
            .subscribe(meteorites)
            .store(in: &cancellables)
        meteorites
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in self?.dynamicTableView.content.reloadData() })
            .store(in: &cancellables)
        dynamicTableView.state = main.viewModel.meteoritesState.value
        main.viewModel.meteoritesState
            .receive(on: DispatchQueue.main)
            .subscribe(dynamicTableView.stateSubject)
            .store(in: &cancellables)
        main.registerScrollViewDelegate(scrollView: dynamicTableView.content)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        hook?.anchor(to: .med, animated:  true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        print("list did appear")
        hook?.anchor(to: .med, animated:  didAppearAtLeastOnce)
        didAppearAtLeastOnce = true
        
    }
    
    func show(meteorite: Meteorite) {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MeteoriteViewController") as? MeteoriteViewController else {
            return
        }
        viewController.setup(with: meteorite)
        if bottomSheetController?.visibleContextViewController is MeteoriteViewController {
            bottomSheetController?.repalceContext(with: viewController, at: MeteoriteAnchor.shown.offset, animated: true)
        } else {
            bottomSheetController?.pushContext(viewController: viewController, at: MeteoriteAnchor.shown.offset, animated: true)
        }
    }
}

extension MeteoriteListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let main = bottomSheetController as? MainViewController else {
            return
        }
        main.mapController?.select(meteorite: meteorites.value[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meteorites.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MeteoriteTableViewCell") as? MeteoriteTableViewCell else {
            return UITableViewCell()
        }
        cell.setup(with: meteorites.value[indexPath.row])
        return cell
    }
}

extension MeteoriteListViewController: BottomSheetDelegate {
    
}
