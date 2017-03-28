//
//  SegmentedControl.swift
//  SegmentedControl
//
//  Created by Николай Кагала on 14/03/2017.
//  Copyright © 2017 Николай Кагала. All rights reserved.
//

import UIKit

protocol SegmentedControlDataSource: class {
    func numberOfItems(in segmentedControl: SegmentedControl) -> Int
    func segmentedControl(_ segmentedControl: SegmentedControl, titleAt index: Int) -> String
}

@objc protocol SegmentedControlDelegate: class {
    @objc optional func segmentedControl(_ segmentedControl: SegmentedControl, didSelectItemAt index: Int)
}

struct SegmentedControlAttributes {
    var interitemSpacing: CGFloat = 0.0
    var itemWidth: SegmentedControlItemWidth = .fitToContent
    var selectionIndicatorColor: UIColor = .red
    var selectionIndicatorHeight: CGFloat = 2
}

class SegmentedControlContentView: UIView { }

class SegmentedControlScrollView: UIScrollView {
    
    init() {
        super.init(frame: .zero)
        delaysContentTouches = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
}

class SegmentedControl: UIView {
    
    //MARK: - Private properties
    
    private var selectedSegment: SegmentedControlItem? {
        guard let index = _selectedSegmentIndex else { return nil }
        guard (0..<segments.count).contains(index) else { return nil }
        return segments[index]
    }
    private var _selectedSegmentIndex: Int? {
        willSet { selectedSegment?.isSelected = false }
        didSet { updateSelection() }
    }
    
    //MARK: - Public properties
    
    weak var delegate: SegmentedControlDelegate? {
        didSet { reloadData() }
    }
    weak var dataSource: SegmentedControlDataSource?{
        didSet { reloadData() }
    }
    
    private(set) var scrollView = SegmentedControlScrollView()
    private(set) var contentView = SegmentedControlContentView()
    private(set) var segments = [SegmentedControlItem]()
    private(set) var selectionIndicator = UIView()
    var selectedSegmentIndex: Int? {
        set {
            if newValue == nil {
                _selectedSegmentIndex = newValue
            } else if 0 <= newValue! && newValue! < segments.count {
                _selectedSegmentIndex = newValue
            }
        }
        get { return _selectedSegmentIndex }
    }
    var attributes = SegmentedControlAttributes()
    var itemAttributes = SegmentedControlItemAttributes()
    override var bounds: CGRect {
        didSet {
            guard oldValue.size != bounds.size else { return }
            updateOnSizeChange()
        }
    }
    override var frame: CGRect {
        didSet {
            guard oldValue.size != frame.size else { return }
            updateOnSizeChange()
        }
    }
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        setupScrollView()
        setupSelectionIndicator()
        reloadData()
    }
    
    //MARK: - Inital setup
    
    private func setupScrollView() {
        translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.bindEdgesToSuperview()
        scrollView.addSubview(contentView)
        contentView.bindEdgesToSuperview()
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0.0))
    }
    
    private func setupSelectionIndicator() {
        selectionIndicator.backgroundColor = attributes.selectionIndicatorColor
        contentView.addSubview(selectionIndicator)
    }
    
    //MARK: - Public
    
    func reloadData() {
        removeSegments()
        selectedSegmentIndex = nil
        createSegments()
    }
    
    //MARK: - Create segments
    
    private func removeSegments() {
        guard !segments.isEmpty else { return }
        segments.forEach { $0.removeFromSuperview() }
        segments.removeAll()
    }
    
    private func createSegments() {
        guard let datasource = dataSource else { return }
        for index in 0..<datasource.numberOfItems(in: self) {
            let title = datasource.segmentedControl(self, titleAt: index)
            itemAttributes.width = attributes.itemWidth
            let item = SegmentedControlItem(title: title, attributes: itemAttributes)
            item.translatesAutoresizingMaskIntoConstraints = false
            item.addTarget(self, action: #selector(segmentButtonTapped(sender:)), for: .touchUpInside)
            contentView.addSubview(item)
            segments.append(item)
        }
        UIView.bindViewsSuccessively(views: segments, inSuperview: contentView, padding: attributes.interitemSpacing)
        configureSegmentsLayout()
    }
    
    private func configureSegmentsLayout() {
        defer { layoutIfNeeded() }
        resetContentSizeToFit()
        let needToFillContentView = contentView.bounds.size.width < bounds.size.width
        let priority = needToFillContentView ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh
        let itemRelativeWidth: CGFloat = {
            let itemBestWidth = bounds.size.width / CGFloat(segments.count)
            let itemMaxWidth = segments.map { $0.bounds.size.width }.max() ?? 0
            return max(itemBestWidth, itemMaxWidth)
        }()
        segments.forEach { segment in
            segment.setContentHuggingPriority(priority, for: .horizontal)
            if needToFillContentView {
                segment.attributes.width = .fixed(itemRelativeWidth)
            }
        }
    }
    
    private func resetContentSizeToFit() {
        segments.forEach { segment in
            segment.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
            segment.attributes.width = .fitToContent
        }
        layoutIfNeeded()
    }
    
    //MARK: - Updating uppearance
    
    private func updateOnSizeChange() {
        configureSegmentsLayout()
        updateSelectionIndicatorPosition()
        updateFocusOnSelectedSegment()
    }
    
    private func updateSelection() {
        selectedSegment?.isSelected = true
        updateSelectionIndicatorPosition()
        updateFocusOnSelectedSegment()
    }
    
    private func updateFocusOnSelectedSegment() {
        guard let segment = selectedSegment else { return }
        var offsetX = segment.center.x - bounds.midX
        let maxXOffset = scrollView.contentSize.width - bounds.width
        offsetX = offsetX <= 0 ? 0 : min(maxXOffset, offsetX)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
    private func updateSelectionIndicatorPosition(animated: Bool = true) {
        guard let segment = selectedSegment else {
            selectionIndicator.frame = .zero
            return
        }
        var frame = segment.frame
        frame.size.height = attributes.selectionIndicatorHeight
        frame.origin.y = segment.frame.height - frame.height
        if selectionIndicator.frame.origin.y != frame.origin.y {
            selectionIndicator.frame = frame
        } else {
            executeAnimated { self.selectionIndicator.frame = frame }
        }
    }
    
    //MARK: - Actions
    
    func segmentButtonTapped(sender: SegmentedControlItem) {
        let index = segments.index(of: sender)
        guard index != selectedSegmentIndex else { return }
        selectedSegmentIndex = index
        delegate?.segmentedControl?(self, didSelectItemAt: index!)
    }
    
    //MARK: - Private
    
    private func executeAnimated(animations: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, delay: 0.0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.1,
                       options: [.beginFromCurrentState, .allowUserInteraction],
                       animations: animations, completion: nil)

    }
}

