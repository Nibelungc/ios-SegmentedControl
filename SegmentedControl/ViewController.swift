//
//  ViewController.swift
//  SegmentedControl
//
//  Created by Николай Кагала on 14/03/2017.
//  Copyright © 2017 Николай Кагала. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SegmentedControlDelegate,  SegmentedControlDataSource, SegmentedViewControllerContainerDataSource {
    
    var data: Pack = .quotes
    var segmentedViewController: SegmentedViewControllerContainer!
    
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
    
    @IBOutlet weak var segmentedControl: SegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frame = view.bounds
        frame.origin.y = segmentedControl.frame.maxY
        frame.size.height -= segmentedControl.frame.maxY - view.frame.minY
        segmentedViewController = SegmentedViewControllerContainer(parentViewController: self, frame: frame)
        segmentedViewController.dataSource = self
        segmentedViewController.view.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        
        automaticallyAdjustsScrollViewInsets = false
        segmentedControl.dataSource = self
        segmentedControl.delegate = self
        segmentedControl.backgroundColor = .groupTableViewBackground
        segmentedControl.reloadData()
        
        
    }
    
    //MARK: - SegmentedViewControllerContainerDataSource
    
    func numberOfControllers(in container: SegmentedViewControllerContainer) -> Int {
        return data.items.count
    }
    
    func initialController(in container: SegmentedViewControllerContainer) -> UIViewController {
        return viewController(forItemWithTitle: data.items.first!)
    }
    
    func controller(in container: SegmentedViewControllerContainer, atIndex index: Int) -> UIViewController? {
        return viewController(forItemWithTitle: data.items[index])
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
    
    //MARK: - Private
    
    private func viewController(forItemWithTitle title: String) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let label = UILabel()
        label.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth, .flexibleHeight]
        label.text = title
        label.sizeToFit()
        label.center = controller.view.center
        controller.view.addSubview(label)
        return controller
    }
}

