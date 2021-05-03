//
//  MeteoriteViewController.swift
//  Mateorite
//
//  Created by Adam Salih on 17.04.2021.
//

import UIKit
import BottomSheet

enum MeteoriteAnchor: BottomSheetAnchor {
    case shown, min
    
    var offset: BottomSheetOffset {
        switch self {
        case .shown: return .specific(offset: 450)
        case .min: return .specific(offset: 100)
        }
    }
    
}

class MeteoriteViewController: UIViewController, BottomSheetAnchorDelegate {
    typealias AnchorType = MeteoriteAnchor
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var massLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    
    private var meteorite: Meteorite?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = meteorite?.name
        yearLabel.text = meteorite?.year
            .flatMap { $0.prefix(4) }
            .flatMap(String.init)
        massLabel.text = meteorite?.mass.flatMap { "\($0) g" }
        classLabel.text = meteorite?.recclass
        latLabel.text = meteorite?.reclat
        lonLabel.text = meteorite?.reclong
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hook?.anchor(to: .shown)
    }
    
    func setup(with meteorite: Meteorite) {
        self.meteorite = meteorite
    }
    
    @IBAction
    func pop() {
        if let meteorite = meteorite,
           let main = bottomSheetController as? MainViewController{
            main.mapController?.deselect(meteorite: meteorite)
        }
        bottomSheetController?.popContext()
    }
}


