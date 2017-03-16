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

class SegmentedViewControllerContainer: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    private var pageController: UIPageViewController!
    private var indicies = [UIViewController: Int]()
    
    weak var dataSource: SegmentedViewControllerContainerDataSource? {
        didSet { reloadData() }
    }
    var currentControllerIndex: Int = 0
    
    //MARK: - Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupUI() {
        pageController = UIPageViewController(transitionStyle: .scroll,
                                              navigationOrientation: .horizontal)
        guard let initialVC = dataSource?.initialController(in: self) else { return }
        setupPageController(pageController, initialViewController: initialVC)
        addChildViewController(pageController, toParent: self, with: view.bounds)
    }
    
    private func resetUI() {
        
    }
    
    //MARK: - Public
    
    func embedIn(parentViewController: UIViewController, frame: CGRect) {
        addChildViewController(self, toParent: parentViewController, with: frame)
    }

    func reloadData() {
        resetUI()
        setupUI()
    }
    
    //MARK: - Private
    
    private func setupPageController(_ controller: UIPageViewController, initialViewController initial: UIViewController) {
        controller.dataSource = self
        controller.delegate = self
        controller.view.frame = view.frame
        controller.setViewControllers([initial], direction: .forward, animated: false)
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
    
    //MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return viewControlerCalculatingIndex(calculation: { $0 - $1 })
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return viewControlerCalculatingIndex(calculation: { $0 + $1 })
    }
    
    private func viewControlerCalculatingIndex(calculation: (Int, Int) -> Int) -> UIViewController? {
        guard let dataSource = dataSource else { return nil }
        let newIndex = calculation(currentControllerIndex, 1)
        guard (0..<dataSource.numberOfControllers(in: self)).contains(newIndex) else { return nil }
        let controller = dataSource.controller(in: self, atIndex: newIndex)
        if controller != nil { indicies[controller!] = newIndex }
        return controller
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
}
