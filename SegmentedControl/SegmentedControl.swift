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

class SegmentedControl: UIScrollView {
    
    //MARK: - Private properties
    
    private var selectedSegment: SegmentedControlItem? {
        guard let index = selectedSegmentIndex else { return nil }
        guard (0..<segments.count).contains(index) else { return nil }
        return segments[index]
    }
    private var widthConstraints = [NSLayoutConstraint]()
    
    //MARK: - Public properties
    
    private(set) var contentView = SegmentedControlContentView()
    private(set) var segments = [SegmentedControlItem]()
    private(set) var selectionIndicator = UIView()
    private(set) var selectedSegmentIndex: Int? {
        didSet { updateSelectionIndicatorPosition() }
    }
    var attributes = SegmentedControlAttributes()
    var itemAttributes = SegmentedControlItemAttributes()
    weak var segmentedControlDelegate: SegmentedControlDelegate?
    weak var segmentedControlDatasource: SegmentedControlDataSource?
    override var bounds: CGRect {
        didSet {
            guard oldValue.size.width != bounds.size.width else { return }
            updateItemConstraints()
            updateSelectionIndicatorPosition()
        }
    }
    
    //MARK: - Initialization
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSelectionIndicatorPosition(animated: false)
    }
    
    private func setupUI() {
        setupScrollView()
        setupSelectionIndicator()
        reloadData()
    }
    
    private func setupScrollView() {
        clipsToBounds = true
        delaysContentTouches = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        contentView.bindEdgesToSuperview()
    }
    
    //MARK: - Selection Indicator
    
    private func setupSelectionIndicator() {
        selectionIndicator.backgroundColor = attributes.selectionIndicatorColor
        contentView.addSubview(selectionIndicator)
    }
    
    private func updateSelectionIndicatorPosition(animated: Bool = true) {
        guard let segment = selectedSegment else { return }
        var frame = segment.frame
        frame.size.height = attributes.selectionIndicatorHeight
        frame.origin.y = segment.frame.height - frame.height
        if selectionIndicator.frame.isEmpty {
            selectionIndicator.frame = frame
        } else {
            executeAnimated { self.selectionIndicator.frame = frame }
        }
    }
    
    //MARK: - Public
    
    func reloadData() {
        guard let datasource = segmentedControlDatasource else { return }
        //TODO: Clear before next reload data
        
        for index in 0..<datasource.numberOfItems(in: self) {
            let title = datasource.segmentedControl(self, titleAt: index)
            var itemAttributes = SegmentedControlItemAttributes()
            itemAttributes.size = SegmentedControlItemSize(width: attributes.itemWidth,
                                                           height: .fixed(bounds.size.height))
            let item = SegmentedControlItem(title: title, attributes: itemAttributes)
            item.translatesAutoresizingMaskIntoConstraints = false
            item.addTarget(self, action: #selector(segmentButtonTapped(sender:)), for: .touchUpInside)
            contentView.addSubview(item)
            segments.append(item)
        }
        
        UIView.bindViewsSuccessively(views: segments, inSuperview: contentView, padding: attributes.interitemSpacing)
        updateItemConstraints()
        
    }
    
    var widthRelation: CGFloat {
        let itemBestWidth = bounds.size.width / CGFloat(segments.count)
        let itemMaxWidth = segments.map { $0.bounds.size.width }.max() ?? 0
        let itemResultWidth = max(itemBestWidth, itemMaxWidth)
        return itemResultWidth/bounds.size.width
    }
    
    func updateItemConstraints() {
        let needToFillContentView = contentView.bounds.size.width < bounds.size.width
        print("content: \(contentView.bounds.size) bounds: \(bounds.size)")
        let priority = needToFillContentView ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh
        widthConstraints.forEach { $0.isActive = false }
        widthConstraints.removeAll()
        segments.forEach { segment in
            segment.setContentHuggingPriority(priority, for: .horizontal)
            if needToFillContentView {
                widthConstraints.append(segment.bindWidthToView(self, relation: widthRelation))
            }
        }
        layoutIfNeeded()
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
    
    //MARK: - Actions
    
    func segmentButtonTapped(sender: SegmentedControlItem) {
        let index = segments.index(of: sender)
        selectedSegment?.isSelected = false
        sender.isSelected = true
        selectedSegmentIndex = index
        segmentedControlDelegate?.segmentedControl?(self, didSelectItemAt: index!)
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

