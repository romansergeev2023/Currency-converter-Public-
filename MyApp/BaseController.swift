import SnapKit
import UIKit

protocol Presenter {
    init(viewController: UIViewController)
}

class BaseController<T: Presenter>: UIViewController {
    lazy var presenter = T(viewController: self)

    func setupButton(button: UIButton, title: String) {
        button.backgroundColor = .white
        button.setTitle(title, for: .normal)
        button.setTitleColor(.darkText, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.lightGray.cgColor
    }

    func createLabel(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = label.font.withSize(15)
        label.textColor = .black
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }

    func createTextField() -> UITextField {
        let textField = UITextField()
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.font = UIFont.systemFont(ofSize: 20)
        return textField
    }
}
