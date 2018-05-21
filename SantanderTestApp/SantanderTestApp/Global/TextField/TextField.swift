//
//  TextField.swift
//  SantanderTestApp
//
//  Created by Frederico Franco on 19/05/18.
//  Copyright © 2018 Frederico Franco. All rights reserved.
//

import Foundation
import UIKit

struct TextFieldAppearance {
    
    var titleTextColor: UIColor
    var titleTextBigFont: UIFont
    var titleTextSmallFont: UIFont
    
    var providedTextColor: UIColor
    var textFieldCarrierColor: UIColor
    
    var normalLineColor: UIColor
    var errorLineColor: UIColor
    var validLineColor: UIColor
}

// MARK: - Input

protocol TextFieldInput {
    
    var title: String { get }
    var typedText: String { get set }
    var isValid: Bool? { get set }
    var isTextFieldActive: Bool { get set }
}

struct MockTextFieldInput: TextFieldInput {
    
    var title: String
    var typedText: String
    var isValid: Bool?
    var isTextFieldActive: Bool = false
}

// MARK: - Validator

protocol TextFieldValidator {
    
    var maxTextLength: Int? { get }
    func isValidText(_ text: String) -> Bool
}

extension TextFieldValidator {
    
    func hasValidLength(_ text: String) -> Bool {
        if let max = maxTextLength {
            return text.count <= max
        } else {
            return true
        }
    }
}

// MARK: - TextField

@IBDesignable class TextField: UIView {
    
    // MARK: Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var lineView: UIView!
    
    /// user can interact with this view to clear the provided text
    @IBOutlet weak var clearTypedTextView: UIView!
    
    // MARK: Properties
    
    var input: TextFieldInput! {
        didSet {
            render(input)
        }
    }
    
    var validator: TextFieldValidator?
    
    var appearance = TextFieldAppearance(titleTextColor: ._grey,
                                         titleTextBigFont: R.font.dinProRegular(size: 16)!,
                                         titleTextSmallFont: R.font.dinProRegular(size: 11)!,
                                         providedTextColor: ._black,
                                         textFieldCarrierColor: ._blue,
                                         normalLineColor: ._lightGrey,
                                         errorLineColor: ._vividRed,
                                         validLineColor: ._green) {
        didSet {
            updateAppearance()
        }
    }
    
    // MARK: Init
    
    init() {
        super.init(frame: .zero)
        
        commonInit()
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        let v = R.nib.textField.firstView(owner: self)!
        self.addSubview(v)
        v.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        input = MockTextFieldInput(title: "Testando", typedText: "Testando", isValid: nil, isTextFieldActive: false)
        
        updateAppearance()
        
        textField.delegate = self
    }
    
    // MARK: Core
    
    private func render(_ input: TextFieldInput) {
        titleLabel.text = input.title
        textField.text = input.typedText
        
        let hasSomeTypedText = !input.typedText.isEmpty
        if hasSomeTypedText {
            titleLabel.font = appearance.titleTextSmallFont
            textField.isHidden = false
            clearTypedTextView.isHidden = false
        } else {
            if input.isTextFieldActive {
                titleLabel.font = appearance.titleTextSmallFont
                textField.isHidden = false
            } else {
                titleLabel.font = appearance.titleTextBigFont
                textField.isHidden = true
            }
            clearTypedTextView.isHidden = true
        }
        
        if let isValid = input.isValid {
            lineView.backgroundColor = isValid ? appearance.validLineColor : appearance.errorLineColor
        } else {
            lineView.backgroundColor = appearance.normalLineColor
        }
    }
    
    func updateAppearance() {
        let a = appearance
        titleLabel.textColor = a.titleTextColor
        textField.textColor = a.providedTextColor
        textField.tintColor = a.textFieldCarrierColor
    }
    
    // MARK: IBActions
    
    @IBAction func activateTextField(_ sender: UITapGestureRecognizer) {
        textField.becomeFirstResponder()
    }
    
    @IBAction func didTapToClearText(_ sender: UITapGestureRecognizer) {
        clearTypedText()
    }
    
    func clearTypedText() {
        input.typedText = ""
    }
}

extension TextField: UITextFieldDelegate {
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        input.isTextFieldActive = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text = textField.text ?? ""
        if let r = Range.init(range, in: text) {
            text.replaceSubrange(r, with: string)
        }
        
        let hasValidLength = validator?.hasValidLength(text) ?? true
        if hasValidLength {
            input.typedText = text
        }
        
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        input.typedText = text
        input.isTextFieldActive = false
        
        input.isValid = validator?.isValidText(text)
    }
}
