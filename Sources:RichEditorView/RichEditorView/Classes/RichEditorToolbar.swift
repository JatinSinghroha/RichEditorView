//
//  RichEditorToolbar.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit

/// RichEditorToolbarDelegate is a protocol for the RichEditorToolbar.
/// Used to receive actions that need extra work to perform (eg. display some UI)
@objc public protocol RichEditorToolbarDelegate: class {

    /// Called when the Text Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar)

    /// Called when the Background Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar)

    /// Called when the Insert Image toolbar item is pressed.
    @objc optional func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar)

    /// Called when the Insert Link toolbar item is pressed.
    @objc optional func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar)
}

/// RichBarButtonItem is a subclass of UIBarButtonItem that takes a callback as opposed to the target-action pattern
@objcMembers open class RichBarButtonItem: UIBarButtonItem {
    open var actionHandler: (() -> Void)?
    
    public convenience init(image: UIImage? = nil, handler: (() -> Void)? = nil) {
        let button = UIButton(type: .system)
        self.init(customView: button)
        target = self
        action = #selector(RichBarButtonItem.buttonWasTapped)
        actionHandler = handler
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(RichBarButtonItem.buttonWasTapped), for: .touchUpInside)
    }
    
    public convenience init(title: String = "", handler: (() -> Void)? = nil) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        self.init(customView: button)
        target = self
        action = #selector(RichBarButtonItem.buttonWasTapped)
        actionHandler = handler
        button.addTarget(self, action: #selector(RichBarButtonItem.buttonWasTapped), for: .touchUpInside)
    }

    public convenience init(button: UIButton, handler: (() -> Void)? = nil) {
        self.init(customView: button)
        target = self
        action = #selector(RichBarButtonItem.buttonWasTapped)
        actionHandler = handler
        button.addTarget(self, action: #selector(RichBarButtonItem.buttonWasTapped), for: .touchUpInside)
    }
    
    @objc func buttonWasTapped() {
        actionHandler?()
    }
}

/// RichEditorToolbar is UIView that contains the toolbar for actions that can be performed on a RichEditorView
@objcMembers open class RichEditorToolbar: UIView {

    /// The delegate to receive events that cannot be automatically completed
    open weak var delegate: RichEditorToolbarDelegate?

    /// A reference to the RichEditorView that it should be performing actions on
    open weak var editor: RichEditorView?

    /// The list of options to be displayed on the toolbar
    open var options: [RichEditorOption] = [] {
        didSet {
            updateToolbar()
        }
    }

    /// The tint color to apply to the toolbar background.
    open var barTintColor: UIColor? {
        get { return backgroundToolbar.barTintColor }
        set { backgroundToolbar.barTintColor = newValue }
    }

    open var moveItemsToRight: Bool = false

    private var toolbarScroll: UIScrollView
    private var toolbar: UIToolbar
    private var backgroundToolbar: UIToolbar
    
    public override init(frame: CGRect) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        autoresizingMask = .flexibleWidth
        backgroundColor = .clear

        backgroundToolbar.frame = bounds
        backgroundToolbar.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        toolbar.autoresizingMask = .flexibleWidth
        toolbar.backgroundColor = .clear
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)

        toolbarScroll.frame = bounds
        toolbarScroll.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        toolbarScroll.showsHorizontalScrollIndicator = false
        toolbarScroll.showsVerticalScrollIndicator = false
        toolbarScroll.backgroundColor = .clear

        toolbarScroll.addSubview(toolbar)

        addSubview(backgroundToolbar)
        addSubview(toolbarScroll)
        updateToolbar()
    }
    
    private func updateToolbar() {
        var buttons = [UIBarButtonItem]()
        for option in options {
            let handler = { [weak self] in
                if let strongSelf = self {
                    option.action(strongSelf)
                }
            }

            if let button = option.button {
                let richBarButtonItem = RichBarButtonItem(button: button, handler: handler)
                richBarButtonItem.tag = option.tag
                buttons.append(richBarButtonItem)
            }
            else if let image = option.image {
                let button = RichBarButtonItem(image: image, handler: handler)
                button.tag = option.tag
                buttons.append(button)
            } else {
                let title = option.title
                let button = RichBarButtonItem(title: title, handler: handler)
                button.tag = option.tag
                buttons.append(button)
            }
            buttons.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        if !buttons.isEmpty {
            buttons.removeLast()
        }
        if moveItemsToRight {
            buttons.insert(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), at: 0)
        }
        toolbar.items = buttons

        let defaultIconWidth: CGFloat = 28
        let barButtonItemMargin: CGFloat = 0
        let width: CGFloat = buttons.reduce(0) {sofar, barButtonItem in
            if let button = barButtonItem.customView as? UIButton, let image = button.imageView?.image {
                return sofar + (image.size.width + barButtonItemMargin)
            } else if let button = barButtonItem.customView as? UIButton, let titleLabel = button.titleLabel {
                titleLabel.sizeToFit()
                return sofar + (titleLabel.frame.width + barButtonItemMargin)
            } else {
                return sofar + (defaultIconWidth + barButtonItemMargin)
            }
        }
        
        if width < frame.size.width {
            toolbar.frame.size.width = frame.size.width
        } else {
            toolbar.frame.size.width = width
        }
        toolbar.frame.size.height = 44
        toolbarScroll.contentSize.width = width
    }
    
    public func setTintColor(color: UIColor, toTag tag: Int) {
        guard let items = toolbar.items else {
            return
        }
        
        for item in items where item.tag == tag {
            guard let customButton = item.customView as? UIButton else { continue }
            customButton.tintColor = color
            return
        }
    }

    public func setImage(image: UIImage, toTag tag: Int) {
        guard let items = toolbar.items else {
            return
        }

        for item in items where item.tag == tag {
            guard let customButton = item.customView as? UIButton else { continue }
            customButton.setImage(image, for: .normal)
            return
        }
    }

    public func setEnabled(enabled: Bool, toTag tag: Int) {
        guard let items = toolbar.items else {
            return
        }

        for item in items where item.tag == tag {
            guard let customButton = item.customView as? UIButton else { continue }
            customButton.isEnabled = enabled
            return
        }
    }
}
