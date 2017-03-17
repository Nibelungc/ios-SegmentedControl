//
//  SegmentedViewController.swift
//  SegmentedControl
//
//  Created by Николай Кагала on 16/03/2017.
//  Copyright © 2017 Николай Кагала. All rights reserved.
//

import UIKit

class SegmentedViewController: UIViewController, SegmentedViewControllerContainerDataSource, SegmentedViewControllerContainerDelegate {
    
    var data: Pack = .quotes
    var segmentedViewController: SegmentedViewControllerContainer!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        segmentedViewController = SegmentedViewControllerContainer()
        segmentedViewController.embedIn(parentViewController: self, frame: view.bounds)
        segmentedViewController.segmentedControl.itemAttributes.normalTitleColor = .red
        segmentedViewController.dataSource = self
        segmentedViewController.delegate = self
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
    
    //MARK: - SegmentedViewControllerContainerDelegate
    
    func segmentedViewControllerContainer(_ segmentedViewControllerContainer: SegmentedViewControllerContainer, didSelectControllerAt index: Int) {
        print("Did select controller at index: \(index)")
    }
    
    //MARK: - Private
    
    private func viewController(forItemWithTitle title: String) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        controller.view.layer.borderWidth = 1.0
        controller.view.layer.borderColor = UIColor.black.cgColor
        let label = UILabel()
        label.textAlignment = .center
        label.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth]
        label.text = title
        label.sizeToFit()
        label.center = controller.view.center
        controller.view.addSubview(label)
        controller.title = title
        return controller
    }

}
