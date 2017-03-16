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

struct SegmentedControlItemAttributes {
    var backgroundColor: UIColor = .clear
    var highlightedBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.15)
    var normalTitleColor: UIColor = .gray
    var selectedTitleColor: UIColor = .black
    var highlightedTitleColor: UIColor = .lightGray
    var titleFont: UIFont = .systemFont(ofSize: 12)
    var width: SegmentedControlItemWidth = .fitToContent
    var margins: CGFloat = 10
}

class SegmentedControlItem: UIControl {
    
    //MARK: - Properties
    
    private(set) var title: String
    private(set) var titleButton = UIButton()
    
    var attributes: SegmentedControlItemAttributes {
        didSet { invalidateIntrinsicContentSize() }
    }
    override var isSelected: Bool {
        didSet {
            titleButton.isSelected = isSelected
        }
    }
    override var isHighlighted: Bool {
        didSet {
            executeAnimated {
                self.backgroundColor = self.isHighlighted ? self.attributes.highlightedBackgroundColor : self.attributes.backgroundColor
            }
        }
    }
    
    //MARK: - Initialization
    
    init(title: String, attributes: SegmentedControlItemAttributes = SegmentedControlItemAttributes()) {
        self.title = title
        self.attributes = attributes
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleButton)
        setupTitleLabel()
    }
    
    private func setupTitleLabel() {
        titleButton.setTitleColor(attributes.normalTitleColor, for: .normal)
        titleButton.setTitleColor(attributes.highlightedTitleColor, for: .highlighted)
        titleButton.setTitleColor(attributes.selectedTitleColor, for: .selected)
        titleButton.titleLabel!.font = attributes.titleFont
        titleButton.setTitle(title, for: .normal)
        titleButton.translatesAutoresizingMaskIntoConstraints = false
        titleButton.bindEdgesToSuperview(orientation: .vertical)
        titleButton.bindEdgesToSuperview(padding: attributes.margins, orientation: .horizontal)
        titleButton.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
        titleButton.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        titleButton.isUserInteractionEnabled = false
    }
    
    override var intrinsicContentSize: CGSize {
        let titleButtonSize = titleButton.sizeThatFits(bounds.size)
        let width: CGFloat
        switch attributes.width {
        case .fixed(let fixedWidth): width = fixedWidth
        case .fitToContent: width = titleButtonSize.width + attributes.margins * 2
        }
        let height = titleButtonSize.height + attributes.margins * 2
        return CGSize(width: width, height: height)
    }
    
    //MARK: - Private
    
    private func executeAnimated(animations: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: [.beginFromCurrentState, .allowUserInteraction],
                       animations: animations,
                       completion: nil)
    }
}
