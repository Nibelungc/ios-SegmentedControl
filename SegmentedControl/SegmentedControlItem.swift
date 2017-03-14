//
//  SegmentedControlItem.swift
//  SegmentedControl
//
//  Created by Николай Кагала on 14/03/2017.
//  Copyright © 2017 Николай Кагала. All rights reserved.
//

import UIKit

enum SegmentedControlItemWidth {
    case fixed(CGFloat)
    case fitToContent
}

enum SegmentedControlItemHeight {
    case fixed(CGFloat)
}

struct SegmentedControlItemSize {
    var width: SegmentedControlItemWidth = .fitToContent
    var height: SegmentedControlItemHeight = .fixed(44)
}

struct SegmentedControlItemAttributes {
    var normalTitleColor: UIColor = .gray
    var selectedTitleColor: UIColor = .black
    var highlightedTitleColor: UIColor = .lightGray
    var titleFont: UIFont = .systemFont(ofSize: 12)
    var size = SegmentedControlItemSize()
    var margins: CGFloat = 10
}

class SegmentedControlItem: UIView {
    
    private(set) var title: String
    private(set) var titleLabel = UILabel()
    private var attributes: SegmentedControlItemAttributes
    
    init(title: String, attributes: SegmentedControlItemAttributes = SegmentedControlItemAttributes()) {
        self.title = title
        self.attributes = attributes
        self.titleLabel.text = title
        super.init(frame: .zero)
        setupUI()
    }
    
    func setupUI() {
        addSubview(titleLabel)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.bindEdgesToSuperview(padding: attributes.margins)
        titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        titleLabel.textAlignment = .center
        titleLabel.font = attributes.titleFont
        titleLabel.textColor = attributes.normalTitleColor
        titleLabel.highlightedTextColor = attributes.highlightedTitleColor
        titleLabel.font = attributes.titleFont
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let width: CGFloat
        let height: CGFloat
        switch attributes.size.width {
        case .fixed(let fixedWidth): width = fixedWidth
        case .fitToContent: width = titleLabel.sizeThatFits(bounds.size).width + attributes.margins * 2
        }
        switch attributes.size.height {
        case .fixed(let fixedHeight): height = fixedHeight
        }
        return CGSize(width: width, height: height)
    }
}
