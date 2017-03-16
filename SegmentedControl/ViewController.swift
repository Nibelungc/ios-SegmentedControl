//
//  ViewController.swift
//  SegmentedControl
//
//  Created by Николай Кагала on 14/03/2017.
//  Copyright © 2017 Николай Кагала. All rights reserved.
//

import UIKit

enum Pack {
    case quotes
    case briefcase
    var items: [String] {
        switch self {
        case .quotes: return ["Мой список", "Акции США", "Акции РФ", "Облигации", "Фьючерсы"]
        case .briefcase: return ["Позиции", "Балансы", "Заявки", "Сделки"]
        }
    }
}

class ViewController: UIViewController, SegmentedControlDelegate,  SegmentedControlDataSource {
    
    var data: Pack = .quotes
    @IBOutlet weak var segmentedControl: SegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        segmentedControl.dataSource = self
        segmentedControl.delegate = self
        segmentedControl.backgroundColor = .groupTableViewBackground
    }
    
    //MARK: - SegmentedControlDataSource
    
    func numberOfItems(in segmentedControl: SegmentedControl) -> Int {
        return data.items.count
    }
    
    func segmentedControl(_ segmentedControl: SegmentedControl, titleAt index: Int) -> String {
        return data.items[index]
    }
    
    //MARK: - SegmentedControlDelegate
    
    func segmentedControl(_ segmentedControl: SegmentedControl, didSelectItemAt index: Int) {
        
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        data = data == .quotes ? .briefcase : .quotes
        segmentedControl.reloadData()
        segmentedControl.selectedSegmentIndex = 0
    }
}

