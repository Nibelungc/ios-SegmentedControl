//
//  SegmentedViewControllerContainer.swift
//  SegmentedControl
//
//  Created by Николай Кагала on 15/03/2017.
//  Copyright © 2017 Николай Кагала. All rights reserved.
//

import UIKit

@objc protocol SegmentedViewControllerContainerDataSource: class {
    func numberOfControllers(in container: SegmentedViewControllerContainer) -> Int
    func controller(in container: SegmentedViewControllerContainer, atIndex index: Int) -> UIViewController?
}

@objc protocol SegmentedViewControllerContainerDelegate: class {
    @objc optional func segmentedViewControllerContainer(_ segmentedViewControllerContainer: SegmentedViewControllerContainer, didSelectControllerAt index: Int)
    @objc optional func segmentedViewControllerContainer(_ segmentedViewControllerContainer: SegmentedViewControllerContainer, willSelectControllerAt index: Int)
    @objc optional func segmentedViewControllerContainer(_ segmentedViewControllerContainer: SegmentedViewControllerContainer, didUpdateNavigationItem: UINavigationItem)
}

class SegmentedViewControllerContainer: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, SegmentedControlDelegate,  SegmentedControlDataSource {
    
    // MARK: - Private properties
    
    private let replaceTitleViewForCompactHeightTraitCollection: Bool
    private var pageController: UIPageViewController!
    private var indicies = [UIViewController: Int]()
    private let segmentedControlHeight: CGFloat
    private var originaNavigationTitleView: UIView?
    
    // MARK: - Public properties
    
    private var _currentControllerIndex: Int = 0 {
        willSet {
            delegate?.segmentedViewControllerContainer?(self, willSelectControllerAt: newValue)
        }
        didSet {
            segmentedControl.selectedSegmentIndex = _currentControllerIndex
            delegate?.segmentedViewControllerContainer?(self, didSelectControllerAt: _currentControllerIndex)
        }
    }
    var currentControllerIndex: Int {
        get { return _currentControllerIndex }
        set {
            segmentedControl.selectedSegmentIndex = newValue
            segmentedControl(segmentedControl, didSelectItemAt: newValue)
        }
    }
    var segmentedControl = SegmentedControl()
    weak var delegate: SegmentedViewControllerContainerDelegate?
    weak var dataSource: SegmentedViewControllerContainerDataSource? {
        didSet { reloadData() }
    }
    
    // MARK: - Lifecycle
    
    init(segmentedControlHeight: CGFloat = 40,
         replaceTitleViewForCompactHeightTraitCollection: Bool = true) {
        self.replaceTitleViewForCompactHeightTraitCollection = replaceTitleViewForCompactHeightTraitCollection
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
    
    private func removeUIAndResetState() {
        segmentedControl.removeFromSuperview()
        indicies.removeAll()
        _currentControllerIndex = 0
        pageController.willMove(toParentViewController: nil)
        pageController.view.removeFromSuperview()
        pageController.removeFromParentViewController()
        pageController = nil
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let navigationItem = parent?.navigationItem else { return }
        
        if traitCollection.verticalSizeClass != .compact {
            navigationItem.titleView = originaNavigationTitleView
            addSegmentedControlAsSubview(frame: .zero)
        } else if replaceTitleViewForCompactHeightTraitCollection {
            originaNavigationTitleView = navigationItem.titleView
            navigationItem.titleView = segmentedControl
            segmentedControl.translatesAutoresizingMaskIntoConstraints = true
            segmentedControl.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            segmentedControl.frame = segmentedControl.superview!.bounds
        }
        delegate?.segmentedViewControllerContainer?(self, didUpdateNavigationItem: navigationItem)
    }
    
    // MARK: - Public
    
    func embedIn(parentViewController: UIViewController, frame: CGRect) {
        addChildViewController(self, toParent: parentViewController, with: frame)
    }

    func reloadData() {
        removeUIAndResetState()
        setupUI()
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return viewControlerCalculatingIndex(calculation: -)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return viewControlerCalculatingIndex(calculation: +)
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard let controller = pageViewController.viewControllers?.last else { return }
        guard completed else { return }
        if let index = indicies[controller] {
            _currentControllerIndex = index
        }
    }
    
    // MARK: - SegmentedControlDataSource
    
    func numberOfItems(in segmentedControl: SegmentedControl) -> Int {
        guard let dataSource = dataSource else { return 0 }
        return dataSource.numberOfControllers(in: self)
    }
    
    func segmentedControl(_ segmentedControl: SegmentedControl, titleAt index: Int) -> String {
        guard let dataSource = dataSource else { return String() }
        let controller = dataSource.controller(in: self, atIndex: index)
        return controller?.title ?? String(index)
    }
    
    // MARK: - SegmentedControlDelegate
    
    func segmentedControl(_ segmentedControl: SegmentedControl, didSelectItemAt index: Int) {
        guard let controller = controller(at: index) else { return }
        let direction: UIPageViewControllerNavigationDirection = index > _currentControllerIndex ? .forward : .reverse
        pageController.setViewControllers([controller], direction: direction, animated: true, completion: nil)
        _currentControllerIndex = index
    }
    
    // MARK: - Private
    
    private func controller(at index: Int) -> UIViewController? {
        guard let dataSource = dataSource else { return nil }
        guard let controller = dataSource.controller(in: self, atIndex: index) else { return nil }
        indicies[controller] = index
        return controller
    }
    
    private func addSegmentedControlAsSubview(frame: CGRect) {
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.bindEdgesToSuperview(orientation: .horizontal)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[segmentedControl(==height)]",
                                                           options: .directionLeadingToTrailing,
                                                           metrics: ["height": segmentedControlHeight],
                                                           views: ["segmentedControl": segmentedControl]))
        view.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: .bottom, relatedBy: .equal, toItem: pageController.view, attribute: .top, multiplier: 1.0, constant: 0.0))
        view.layoutIfNeeded()
    }
    
    private func setupSegmentedControl(frame: CGRect) {
        segmentedControl.frame = frame
        segmentedControl.dataSource = self
        segmentedControl.delegate = self
        segmentedControl.selectedSegmentIndex = _currentControllerIndex
    }
    private func setupPageController(frame: CGRect) {
        pageController = UIPageViewController(transitionStyle: .scroll,
                                              navigationOrientation: .horizontal)
        guard let initialVC = controller(at: 0) else { return }
        addChildViewController(pageController, toParent: self, with: frame)
        pageController.setViewControllers([initialVC], direction: .forward, animated: false)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        pageController.view.bindEdgesToSuperview(orientation: .horizontal)
        view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-0@750-[pageView]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["pageView": pageController.view])
        )
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
        let newIndex = calculation(_currentControllerIndex, 1)
        guard (0..<dataSource.numberOfControllers(in: self)).contains(newIndex) else { return nil }
        return controller(at: newIndex)
    }
}
