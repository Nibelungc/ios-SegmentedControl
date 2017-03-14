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
}

class SegmentedControl: UIScrollView {
    
    //MARK: - Private properties
    
    //MARK: - Public properties
    
    private(set) var contentView = UIView()
    private(set) var segments = [SegmentedControlItem]()
    
    var attributes = SegmentedControlAttributes()
    var itemAttributes = SegmentedControlItemAttributes()
    
    weak var segmentedControlDelegate: SegmentedControlDelegate?
    weak var segmentedControlDatasource: SegmentedControlDataSource?
    
    //MARK: - Initialization
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        clipsToBounds = true
        delaysContentTouches = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        contentView.bindEdgesToSuperview()
        reloadData()
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
            contentView.addSubview(item)
            segments.append(item)
        }
        UIView.bindViewsSuccessively(views: segments, inSuperview: contentView, padding: attributes.interitemSpacing)
    }
    
}

