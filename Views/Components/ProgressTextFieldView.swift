import Cocoa


@IBDesignable
class ProgressTextFieldView: NSView {
    @IBInspectable let textField = NSTextField()
    private let progressBarContainerView = NSView()
    private let progressBarView = NSView()
    private var progressBarWidthConstraint: NSLayoutConstraint?
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        wantsLayer = true
        layer?.cornerRadius = 6
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.darkGray.cgColor
        
        textField.cell = VerticallyCenteredTextFieldCell()
        textField.usesSingleLineMode = true
        textField.isEditable = true
        textField.isBordered = false
        textField.backgroundColor = .clear
        textField.alignment = .center
        textField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        textField.lineBreakMode = .byTruncatingTail
        textField.delegate = self
        
        progressBarContainerView.wantsLayer = true
        progressBarContainerView.layer?.backgroundColor = NSColor.clear.cgColor
        
        progressBarView.wantsLayer = true
        progressBarView.alphaValue = 0.0
        progressBarView.layer?.backgroundColor = NSColor.controlAccentColor.cgColor
        progressBarView.frame = CGRect(x: 0, y: 0, width: 0, height: 2)
        
        addSubview(textField)
        addSubview(progressBarContainerView)
        progressBarContainerView.addSubview(progressBarView)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        progressBarContainerView.translatesAutoresizingMaskIntoConstraints = false
        progressBarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor, constant: -1),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1),
            textField.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            textField.widthAnchor.constraint(lessThanOrEqualToConstant: 600),
            textField.heightAnchor.constraint(equalToConstant: 35),
            
            progressBarContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressBarContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressBarContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressBarContainerView.heightAnchor.constraint(equalToConstant: 3),
            
            progressBarView.leadingAnchor.constraint(equalTo: progressBarContainerView.leadingAnchor),
            progressBarView.topAnchor.constraint(equalTo: progressBarContainerView.topAnchor),
            progressBarView.heightAnchor.constraint(equalTo: progressBarContainerView.heightAnchor)
        ])
        
        progressBarWidthConstraint = progressBarView.widthAnchor.constraint(equalToConstant: 0)
        progressBarWidthConstraint?.isActive = true
    }
    
    func updateProgress(_ progress: CGFloat) {
        let shouldBeVisible = progress > 0
        let newAlpha = shouldBeVisible ? 1.0 : 0.0
        let newWidth = progressBarContainerView.bounds.width * progress
        
        if newWidth == (progressBarWidthConstraint?.constant ?? 0) {
            return
        }
        
        if (progressBarWidthConstraint?.constant ?? 0) > newWidth {
            progressBarWidthConstraint?.constant = 0
            progressBarView.alphaValue = newAlpha
            progressBarView.superview?.layoutSubtreeIfNeeded()
        }
        
        progressBarWidthConstraint?.animator().constant = newWidth
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            progressBarView.animator().alphaValue = newAlpha
            progressBarView.superview?.layoutSubtreeIfNeeded()
        }
        
        if progress > 0.99 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.2
                    self?.progressBarView.animator().alphaValue = 0.0
                }
            }
        }
    }
}

extension ProgressTextFieldView: NSTextFieldDelegate {
}
