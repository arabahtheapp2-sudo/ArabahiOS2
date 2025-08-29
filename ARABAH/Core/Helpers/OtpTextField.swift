//
//  OtpTextField.swift
//  ARABAH
//
//  Created by cqlios on 18/10/24.
//
import UIKit

protocol BackspaceTextFieldDelegate: AnyObject {
    func textFieldDidDelete(_ textField: OtpTextField)
}

class OtpTextField: UITextField {

    weak var backspaceDelegate: BackspaceTextFieldDelegate?

       override func deleteBackward() {
           super.deleteBackward()
           backspaceDelegate?.textFieldDidDelete(self)
       }
}
