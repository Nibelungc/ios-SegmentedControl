//
//  SegmentedViewControllerContainer.swift
//  SegmentedControl
//
//  Created by Николай Кагала on 15/03/2017.
//  Copyright © 2017 Николай Кагала. All rights reserved.
//

import UIKit


protocol SegmentedViewControllerContainerDataSource: class {
    func numberOfControllers(in container: SegmentedViewControllerContainer) -> Int
    func initialController(in container: SegmentedViewControllerContainer) -> UIViewController
    func controller(in container: SegmentedViewControllerContainer, atIndex index: Int) -> UIViewController?
}

@objc protocol SegmentedViewControllerContainerDelegate: class {

}

class SegmentedViewControllerContainer: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, SegmentedControlDelegate,  SegmentedControlDataSource {
    
    //MARK: - Private properties
    
    private var pageController: UIPageViewController!
    private var segmentedControl: SegmentedControl!
    private var indicies = [UIViewController: Int]()
    private var currentControllerIndex: Int = 0
    private let segmentedControlHeight: CGFloat
    
    //MARK: - Public properties
    
    weak var dataSource: SegmentedViewControllerContainerDataSource? {
        didSet { reloadData() }
    }
    
    //MARK: - Lifecycle
    
    init(segmentedControlHeight: CGFloat = 40) {
        self.segmentedControlHeight = segmentedControlHeight
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupUI() {
        let rects = view.bounds.divided(atDistance: segmentedControlHeight, from: .minYEdge)
        setupSegmentedControl(frame: rects.slice)
        setupPageController(frame: rects.remainder)
    }
    
    private func resetUI() {
        //TODO: Clean up
    }
    
    //MARK: - Public
    
    func embedIn(parentViewController: UIViewController, frame: CGRect) {
        addChildViewController(self, toParent: parentViewController, with: frame)
    }

    func reloadData() {
        resetUI()
        setupUI()
    }
    
    //MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return viewControlerCalculatingIndex(calculation: -)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return viewControlerCalculatingIndex(calculation: +)
    }
    
    //MARK: - UIPageViewControllerDelegate
    
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard let controller = pageViewController.viewControllers?.last else { return }
        if let index = indicies[controller] {
            currentControllerIndex = index
        }
    }
    
    //MARK: - SegmentedControlDataSource
    
    func numberOfItems(in segmentedControl: SegmentedControl) -> Int {
        guard let dataSource = dataSource else { return 0 }
        return dataSource.numberOfControllers(in: self)
    }
    
    func segmentedControl(_ segmentedControl: SegmentedControl, titleAt index: Int) -> String {
        guard let dataSource = dataSource else { return String() }
        let controller = dataSource.controller(in: self, atIndex: index)
        return controller?.title ?? String(index)
    }
    
    //MARK: - SegmentedControlDelegate
    
    func segmentedControl(_ segmentedControl: SegmentedControl, didSelectItemAt index: Int) {
        
    }
    
    //MARK: - Private
    
    private func setupSegmentedControl(frame: CGRect) {
        segmentedControl = SegmentedControl(frame: frame)
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.bindEdgesToSuperview(orientation: .horizontal)
        view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[segmentedControl(==height)]",
                                           options: .directionLeadingToTrailing,
                                           metrics: ["height": segmentedControlHeight],
                                           views: ["segmentedControl": segmentedControl])
        )
        segmentedControl.dataSource = self
        segmentedControl.delegate = self
    }
    private func setupPageController(frame: CGRect) {
        pageController = UIPageViewController(transitionStyle: .scroll,
                                              navigationOrientation: .horizontal)
        guard let initialVC = dataSource?.initialController(in: self) else { return }
        pageController.view.frame = view.frame
        pageController.setViewControllers([initialVC], direction: .forward, animated: false)
        addChildViewController(pageController, toParent: self, with: frame)
        pageController.dataSource = self
        pageController.delegate = self
    }
    
    private func addChildViewController(_ childController: UIViewController,
                                        toParent parent: UIViewController,
                                        with frame: CGRect) {
        parent.addChildViewController(childController)
        childController.view.frame = frame
        childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        parent.view.addSubview(childController.view)
        childController.didMove(toParentViewController: parent)
    }
    
    private func viewControlerCalculatingIndex(calculation: (Int, Int) -> Int) -> UIViewController? {
        guard let dataSource = dataSource else { return nil }
        let newIndex = calculation(currentControllerIndex, 1)
        guard (0..<dataSource.numberOfControllers(in: self)).contains(newIndex) else { return nil }
        let controller = dataSource.controller(in: self, atIndex: newIndex)
        if controller != nil { indicies[controller!] = newIndex }
        return controller
    }
}
