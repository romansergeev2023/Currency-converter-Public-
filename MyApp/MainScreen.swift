import BrightFutures
import MyAppCommon
import SnapKit
import UIKit

struct Currencies: Codable {
    let symbols: [String: String]
}

struct Convert: Codable {
    var result: Float
    var date: String
    var info: [String: Float]
}

struct ApiCache {
    static var shared = ApiCache()

    var cacheApi = [String: Currencies]()
    var cacheConvert = [String: Convert]()
}

enum MyAppError: Int, Error {
    case emptyResponseData = 100
    case decodingFailed = 101

    var title: String {
        switch self {
        case .emptyResponseData:
            return "Empty data"
        case .decodingFailed:
            return "Decoding"
        }
    }

    var message: String {
        switch self {
        case .emptyResponseData:
            return "Empty response data"
        case .decodingFailed:
            return "Some message"
        }
    }
}

struct MainScreenPresenter: Presenter {
    init(viewController _: UIViewController) {}
}

class MainScreen: BaseController<MainScreenPresenter>, UITextFieldDelegate {
    weak var currencySelectionScreen: CurrencySelectionScreen?
    weak var keyboardController: KeyboardController?

    private var view1: UIView!
    private var label1: UILabel!
    private var labelFrom: UILabel!
    private var labelTo: UILabel!
    private var labelRates: UILabel!
    private let buttonFrom = UIButton()
    private let buttonTo = UIButton()
    private var textFieldFrom: UITextField!
    private var textFieldTo: UITextField!
    var currencyData = [String: String]()

    var valueFrom: String?
    var valueTo: String?
    var valueTextField: String?

    // swiftlint:disable function_body_length
    override func viewDidLoad() {
        super.viewDidLoad()

        initViews()
        initConstraints()
    }

    func initViews() {
        let keyboardController = KeyboardController()
        keyboardController.mainScreen = self
        view1 = UIView()

        label1 = UILabel()
        labelFrom = createLabel(title: L10n.keyFromCurrency)
        labelTo = createLabel(title: L10n.keyToCurrency)
        labelRates = createLabel(title: "")
        textFieldFrom = createTextField()
        textFieldFrom.accessibilityIdentifier = AccessId.idTextFieldFrom.rawValue

        delField()
        textFieldTo = createTextField()
        textFieldTo.accessibilityIdentifier = AccessId.idTextFieldTo.rawValue
        setupButton(button: buttonFrom, title: valueFrom ?? L10n.keyFrom)
        buttonFrom.accessibilityIdentifier = AccessId.idBtnFrom.rawValue
        setupButton(button: buttonTo, title: valueTo ?? L10n.keyTo)
        buttonTo.accessibilityIdentifier = AccessId.idBtnTo.rawValue

        view1.backgroundColor = .white

        label1.text = String(L10n.keyNameOfApplication)
        label1.font = label1.font.withSize(25)
        label1.textColor = .white
        label1.textAlignment = .center
        label1.backgroundColor = .lightGray

        textFieldFrom.delegate = self
        textFieldTo.delegate = self
        textFieldFrom.setOnTextChangeListener { [unowned self] in
            convert()
        }

        addChild(keyboardController)
        self.keyboardController = keyboardController
        view.addSubview(keyboardController.view)
        keyboardController.didMove(toParent: self)

        view.addSubview(view1)
        view1.addSubview(label1)
        view1.addSubview(buttonFrom)
        view1.addSubview(buttonTo)
        view1.addSubview(labelFrom)
        view1.addSubview(labelTo)
        view1.addSubview(labelRates)
        view1.addSubview(textFieldFrom)
        view1.addSubview(textFieldTo)

        buttonTo.addAction(UIAction { [weak self] _ in
            self?.onToOrFromTap(mode: .to)
        }, for: .primaryActionTriggered)

        buttonFrom.addAction(UIAction { [weak self] _ in
            self?.onToOrFromTap(mode: .from)
        }, for: .primaryActionTriggered)
    }

    private func convert() {
        var textField = ""

        if let text = textFieldFrom.text {
            textField = text
        }
        if let valueFrom = valueFrom, let valueTo = valueTo, textField != "" {
            getConvert(from: valueFrom, to: valueTo).recoverWith { _ in
                self.getConvert(from: valueFrom, to: valueTo, apiKey: "aSf8ve8FfWZvC71G4vFM6510dZVh5wOL")
            }.onSuccess { [weak self] result in
                self?.textFieldTo.text = String(result.result * (Float(textField) ?? 0.0))
                self?.labelRates.text = "1\(valueFrom) = \(result.result) \(valueTo)"
            }.onFailure { [weak self] error in
                self?.alert(title: error.title, message: error.message, style: .default)
            }
        }
    }

    func initConstraints() {
        let buttonWidthFromTo = (view.frame.width / 2) - 10
        let buttonHeightFromTo = (view.frame.height / 10)

        view1.snp.makeConstraints { maker in
            maker.leading.trailing.top.equalToSuperview()
            maker.bottom.equalTo(keyboardController?.view.snp.top ?? view.snp.top)
            maker.height.equalTo(view.frame.height / 2)
        }

        keyboardController?.view.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
        }

        label1.snp.makeConstraints { maker in
            maker.top.leading.trailing.equalTo(view1)
        }

        labelFrom.snp.makeConstraints { maker in
            maker.leading.equalTo(view1.snp.leading).inset(5)
            maker.top.equalTo(label1.snp.bottom).inset(-5)
        }

        buttonFrom.snp.makeConstraints { maker in
            maker.leading.equalTo(view1.snp.leading).inset(5)
            maker.top.equalTo(labelFrom.snp.bottom).inset(0)
            maker.width.equalTo(buttonWidthFromTo)
            maker.height.equalTo(buttonHeightFromTo)
        }

        labelRates.snp.makeConstraints { maker in
            maker.trailing.equalTo(view1.snp.trailing).inset(5)
            maker.bottom.equalTo(view1.snp.bottom).inset(5)
        }

        textFieldFrom.snp.makeConstraints { maker in
            maker.trailing.equalTo(view1.snp.trailing).inset(5)
            maker.top.equalTo(label1.snp.bottom).inset(-23)
            maker.width.equalTo(buttonWidthFromTo)
            maker.height.equalTo(buttonHeightFromTo)
        }

        textFieldTo.snp.makeConstraints { maker in
            maker.trailing.equalTo(view1.snp.trailing).inset(5)
            maker.bottom.equalTo(view1.snp.bottom).inset(23)
            maker.width.equalTo(buttonWidthFromTo)
            maker.height.equalTo(buttonHeightFromTo)
        }

        buttonTo.snp.makeConstraints { maker in
            maker.leading.equalTo(view1.snp.leading).inset(5)
            maker.bottom.equalTo(view1.snp.bottom).inset(23)
            maker.width.equalTo(buttonWidthFromTo)
            maker.height.equalTo(buttonHeightFromTo)
        }

        labelTo.snp.makeConstraints { maker in
            maker.leading.equalTo(view1.snp.leading).inset(5)
            maker.bottom.equalTo(buttonTo.snp.top)
        }
    }

    private func onToOrFromTap(mode: CurrencySelectionScreenMode) {
        let currencySelectionScreen = CurrencySelectionScreen()
        currencySelectionScreen.mode = mode
        currencySelectionScreen.mainScreen = self
        present(currencySelectionScreen, animated: true)
    }

    func alert(title: String, message: String, style _: UIAlertViewStyle) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .default, handler: nil)

        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }

    func setupField(text: String) {
        let textField = textFieldFrom.text ?? ""

        if textField.isEmpty, text == "." || text == "0" {
            textFieldFrom.text = textField
        } else if textField.contains("."), text == "." {
            textFieldFrom.text = textField
        } else {
            textFieldFrom.text = textField + text
        }
        convert()
    }

    func swipe() {
        alert(title: "Error", message: "!!!", style: .default)
    }

    func delField() {
        let textField = textFieldFrom.text ?? ""
        textFieldFrom.text = String(textField.dropLast())
        convert()
    }

    func clearField() {
        textFieldFrom.text = ""
        textFieldTo.text = ""
    }

    func update(titleFrom: String) {
        valueFrom = titleFrom
        buttonFrom.setTitle(titleFrom, for: .normal)
    }

    func update(titleTo: String) {
        valueTo = titleTo
        buttonTo.setTitle(titleTo, for: .normal)
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn _: NSRange,
        replacementString string: String
    ) -> Bool {
        let textFieldText = textField.text ?? ""

        if textFieldText.isEmpty, string == "." || string == "0" {
            return false
        }
        if textFieldText.contains("."), string == "." {
            return false
        }

        let allowedChar = ".0123456789"
        let allowedCharSet = CharacterSet(charactersIn: allowedChar)
        let typedCharSet = CharacterSet(charactersIn: string)

        return allowedCharSet.isSuperset(of: typedCharSet)
    }

    func getConvert(from: String, to: String, apiKey: String = "aSf8ve8FfWZvC71G4vFM6510dZVh5wOL") -> Future<Convert, MyAppError> {
        .init { resolver in
            let url = "https://api.apilayer.com/exchangerates_data/convert?to=\(to)&from=\(from)&amount=\(1)"
            if let cache = ApiCache.shared.cacheConvert[url] {
                resolver(
                    .success(Convert(
                        result: cache.result,
                        date: cache.date,
                        info: cache.info
                    ))
                )
            } else {
                var request = URLRequest(url: URL(string: url)!)
                request.httpMethod = "GET"
                request.addValue(apiKey, forHTTPHeaderField: "apikey")

                let task = URLSession.shared.dataTask(with: request) { data, _, _ in
                    guard let data = data else {
                        resolver(.failure(.emptyResponseData))
                        return
                    }
                    guard let decodeData = try? JSONDecoder().decode(Convert.self, from: data) else {
                        resolver(.failure(.decodingFailed))
                        return
                    }
                    ApiCache.shared.cacheConvert[url] = decodeData
                    resolver(
                        .success(Convert(
                            result: decodeData.result,
                            date: decodeData.date,
                            info: decodeData.info
                        ))
                    )
                }
                task.resume()
            }
        }
    }
    // swiftlint:enable function_body_length
}

extension UITextField {
    func setOnTextChangeListener(onTextChanged: @escaping () -> Void) {
        addAction(UIAction { _ in
            onTextChanged()
        }, for: .editingChanged)
    }
}
