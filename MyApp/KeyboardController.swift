import MyAppCommon
import SnapKit
import UIKit

class KeyboardButton: UIButton {
    let name: NamesBtns

    init(name: NamesBtns) {
        self.name = name
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum NamesBtns {
    case del
    case clear
    case swipe
    case dot
    case number(Int)
    static var numbers: [NamesBtns] {
        (0 ... 9).map { .number($0) }
    }

    static var allCases: [NamesBtns] {
        numbers + [.del, .clear, .swipe, .dot]
    }

    var name: String {
        switch self {
        case .del:
            return "Del"
        case .clear:
            return "C"
        case .swipe:
            return "Swipe"
        case .dot:
            return "."
        case let .number(value):
            return "\(value)"
        }
    }
}

struct KeyboardControllerPresenter: Presenter {
    init(viewController _: UIViewController) {}
}

class KeyboardController: BaseController<KeyboardControllerPresenter> {
    weak var mainScreen: MainScreen?
    private let btn0 = KeyboardButton(name: .number(0))
    private let btn1 = KeyboardButton(name: .number(1))
    private let btn2 = KeyboardButton(name: .number(2))
    private let btn3 = KeyboardButton(name: .number(3))
    private let btn4 = KeyboardButton(name: .number(4))
    private let btn5 = KeyboardButton(name: .number(5))
    private let btn6 = KeyboardButton(name: .number(6))
    private let btn7 = KeyboardButton(name: .number(7))
    private let btn8 = KeyboardButton(name: .number(8))
    private let btn9 = KeyboardButton(name: .number(9))
    private let btnDel = KeyboardButton(name: .del)
    private let btnSwipe = KeyboardButton(name: .swipe)
    private let btnC = KeyboardButton(name: .clear)
    private let btnDot = KeyboardButton(name: .dot)

    private var allNumericButtons: Set<KeyboardButton> {
        [btn0, btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9]
    }

    private var allAdditionalButtons: Set<KeyboardButton> {
        [btnDel, btnC, btnSwipe, btnDot]
    }

    var allButtons: Set<KeyboardButton> {
        allNumericButtons.union(allAdditionalButtons)
    }

    @objc func btnPressed(btn: UIButton) {
        guard let text = btn.titleLabel?.text else { return }
        var num = 0
        if let number = Int(text) {
            num = number
        }

        switch text {
        case NamesBtns.del.name:
            mainScreen?.delField()

        case NamesBtns.swipe.name:
            mainScreen?.swipe()

        case NamesBtns.clear.name:
            mainScreen?.clearField()

        case NamesBtns.dot.name:
            mainScreen?.setupField(text: "\(text)")

        case NamesBtns.number(num).name:
            mainScreen?.setupField(text: "\(text)")

        default:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initViews()
        initConstraints()

        let idButtons = AccessIdKeyboard.allCases
        for indx in 0 ..< allButtons.count {
            allButtons[indx].accessibilityIdentifier = idButtons[indx].rawValue
        }
    }

    func initViews() {
        for button in allButtons {
            let titleBtn = button.name.name
            setupButton(button: button, title: titleBtn)
            button.addTarget(self, action: #selector(btnPressed), for: .touchUpInside)
            view.addSubview(button)
        }

        view.backgroundColor = .white
    }

    // swiftlint:disable function_body_length

    func initConstraints() {
        let buttonWidth = (view.frame.width / 4) - 6
        let buttonHeight = (view.frame.height / 8) - 6

        btn7.snp.makeConstraints { maker in
            maker.top.leading.equalTo(view).inset(5)
            maker.width.equalTo(buttonWidth)
            maker.height.equalTo(buttonHeight)
        }

        btn8.snp.makeConstraints { maker in
            maker.leading.equalTo(btn7.snp.trailing).inset(-5)
            maker.top.equalTo(view.snp.top).inset(5)
            maker.width.equalTo(buttonWidth)
            maker.height.equalTo(buttonHeight)
        }

        btn9.snp.makeConstraints { maker in
            maker.leading.equalTo(btn8.snp.trailing).inset(-5)
            maker.top.equalTo(view.snp.top).inset(5)
            maker.width.equalTo(buttonWidth)
            maker.height.equalTo(buttonHeight)
        }

        btnDel.snp.makeConstraints { maker in
            maker.leading.equalTo(btn9.snp.trailing).inset(-5)
            maker.top.equalTo(view.snp.top).inset(5)
            maker.width.equalTo(buttonWidth)
            maker.height.equalTo(buttonHeight)
        }

        btn4.snp.makeConstraints { maker in
            maker.leading.equalTo(view).inset(5)
            maker.top.equalTo(btn7.snp.bottom).inset(-5)
            maker.width.equalTo(buttonWidth)
            maker.height.equalTo(buttonHeight)
        }

        btn5.snp.makeConstraints { maker in
            maker.leading.equalTo(btn4.snp.trailing).inset(-5)
            maker.top.equalTo(btn8.snp.bottom).inset(-5)
            maker.width.equalTo(buttonWidth)
            maker.height.equalTo(buttonHeight)
        }

        btn6.snp.makeConstraints { maker in
            maker.leading.equalTo(btn5.snp.trailing).inset(-5)
            maker.top.equalTo(btn9.snp.bottom).inset(-5)
            maker.width.equalTo(buttonWidth)
            maker.height.equalTo(buttonHeight)
        }

        btnSwipe.snp.makeConstraints { maker in
            maker.leading.equalTo(btn6.snp.trailing).inset(-5)
            maker.top.equalTo(btnDel.snp.bottom).inset(-5)
            maker.width.equalTo(buttonWidth)
            maker.height.equalTo(buttonHeight)
        }

        btn1.snp.makeConstraints { maker in
            maker.leading.equalTo(view).inset(5)
            maker.top.equalTo(btn4.snp.bottom).inset(-5)
            maker.width.equalTo(buttonWidth)
            maker.height.equalTo(buttonHeight)
        }

        btn2.snp.makeConstraints { maker in
            maker.leading.equalTo(btn1.snp.trailing).inset(-5)
            maker.top.equalTo(btn5.snp.bottom).inset(-5)
            maker.width.equalTo(buttonWidth)
            maker.height.equalTo(buttonHeight)
        }

        btn3.snp.makeConstraints { maker in
            maker.leading.equalTo(btn2.snp.trailing).inset(-5)
            maker.top.equalTo(btn6.snp.bottom).inset(-5)
            maker.width.equalTo(buttonWidth)
            maker.height.equalTo(buttonHeight)
        }

        btnC.snp.makeConstraints { maker in
            maker.leading.equalTo(btn3.snp.trailing).inset(-5)
            maker.top.equalTo(btnSwipe.snp.bottom).inset(-5)
            maker.width.equalTo(buttonWidth)
            maker.height.equalTo(buttonHeight)
        }

        btn0.snp.makeConstraints { maker in
            maker.leading.equalTo(view).inset(5)
            maker.top.equalTo(btn1.snp.bottom).inset(-5)
            maker.width.equalTo(3 * buttonWidth + 9.5)
            maker.height.equalTo(buttonHeight)
        }

        btnDot.snp.makeConstraints { maker in
            maker.leading.equalTo(btn0.snp.trailing).inset(-5)
            maker.top.equalTo(btnC.snp.bottom).inset(-5)
            maker.width.equalTo(buttonWidth)
            maker.height.equalTo(buttonHeight)
        }
    }
    // swiftlint:enable function_body_length
}
