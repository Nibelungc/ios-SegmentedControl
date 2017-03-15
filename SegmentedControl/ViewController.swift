//
//  ViewController.swift
//  SegmentedControl
//
//  Created by Николай Кагала on 14/03/2017.
//  Copyright © 2017 Николай Кагала. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SegmentedControlDelegate,  SegmentedControlDataSource {
    
//    var titles = ["Позиции", "Балансы", "Заявки", "Сделки"]
    var titles = ["Мой список", "Акции США", "Акции РФ", "Облигации", "Фьючерсы"]
    @IBOutlet weak var segmentedControl: SegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        segmentedControl.segmentedControlDatasource = self
        segmentedControl.segmentedControlDelegate = self
        segmentedControl.backgroundColor = .groupTableViewBackground
        segmentedControl.reloadData()
    }
    
    //MARK: - SegmentedControlDataSource
    
    func numberOfItems(in segmentedControl: SegmentedControl) -> Int {
        return titles.count
    }
    
    func segmentedControl(_ segmentedControl: SegmentedControl, titleAt index: Int) -> String {
        return titles[index]
    }
    
    //MARK: - SegmentedControlDelegate
    
    func segmentedControl(_ segmentedControl: SegmentedControl, didSelectItemAt index: Int) {
        
    }
}

