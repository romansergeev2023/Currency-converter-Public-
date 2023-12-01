import BrightFutures
import SnapKit
import UIKit

enum CurrencySelectionScreenMode {
    case from
    case to
}

protocol CurrencySelectionScreenPresenterInterface: Presenter {
    func getCurrencies() -> Future<Void, MyAppError>
    func redraw()
}

class CurrencySelectionScreenPresenter: CurrencySelectionScreenPresenterInterface {
    weak var viewController: UIViewController?
    weak var mainScreen: MainScreen?

    var dicOfCurrencies = [String: String]()
    var filtredDicOfCurrencies = [String: String]()

    required init(viewController: UIViewController) {
        self.viewController = viewController
    }

    static let currenciesURL = "https://api.apilayer.com/exchangerates_data/symbols"

    func getCurrencies() -> Future<Void, MyAppError> {
        .init { resolver in
            let url = Self.currenciesURL

            if let cache = ApiCache.shared.cacheApi[url] {
                dicOfCurrencies = cache.symbols
                filtredDicOfCurrencies = cache.symbols
            } else {
                var request = URLRequest(url: URL(string: url)!)
                request.httpMethod = "GET"
                request.addValue("aSf8ve8FfWZvC71G4vFM6510dZVh5wOL", forHTTPHeaderField: "apikey")
                let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
                    guard let data = data else {
                        resolver(.failure(.emptyResponseData))
                        return
                    }
                    guard let currencies = try? JSONDecoder().decode(Currencies.self, from: data) else {
                        resolver(.failure(.decodingFailed))
                        return
                    }
                    ApiCache.shared.cacheApi[url] = currencies
                    self?.dicOfCurrencies = currencies.symbols
                    self?.filtredDicOfCurrencies = currencies.symbols
                    resolver(.success(()))
                }
                task.resume()
            }
        }
    }

    func redraw() {
        (viewController as? CurrencySelectionScreen)?.onGetCurrencies()
    }
}

class CurrencySelectionScreen: BaseController<CurrencySelectionScreenPresenter> {
    weak var mainScreen: MainScreen?
    private let view3 = UIView()
    private let label = UILabel()
    private let search = UISearchBar()
    private let buttonBack = UIButton()
    var mode: CurrencySelectionScreenMode!
    private var selectRow = [String: String]()
    private var tableView = UITableView(frame: .zero, style: .grouped)

    override func viewDidLoad() {
        super.viewDidLoad()

        view3.backgroundColor = .lightGray
        switch mode! {
        case .from:
            label.text = L10n.keyFromCurrency
        case .to:
            label.text = L10n.keyToCurrency
        }
        label.font = label.font.withSize(25)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .lightGray

        search.placeholder = L10n.keyHelpForSearch
        search.delegate = self

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self

        buttonBack.backgroundColor = .white
        buttonBack.setTitle(L10n.keyCancel, for: .normal)
        buttonBack.setTitleColor(.darkText, for: .normal)
        buttonBack.layer.cornerRadius = 5
        buttonBack.layer.borderWidth = 2
        buttonBack.layer.borderColor = UIColor.lightGray.cgColor

        view.addSubview(view3)
        view3.addSubview(label)
        view3.addSubview(search)
        view3.addSubview(tableView)
        view3.addSubview(buttonBack)
        initConstraints()

        buttonBack.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .primaryActionTriggered)

        presenter.getCurrencies().onSuccess { [weak self] in
            self?.presenter.redraw()
        }.onFailure { [weak self] error in
            self?.mainScreen?.alert(title: error.title, message: error.message, style: .default)
        }
    }

    @objc func onTextChanged() {
        // data = Array(data.dropFirst(1))
        tableView.reloadData()
    }

    func initConstraints() {
        let buttonWidth = (view.frame.width / 2) - 10
        let buttonHeight = (view.frame.height / 10)

        view3.snp.makeConstraints { maker in
            maker.leading.trailing.top.bottom.equalToSuperview()
        }

        label.snp.makeConstraints { maker in
            maker.top.leading.trailing.equalToSuperview()
        }

        search.snp.makeConstraints { maker in
            maker.top.equalTo(label.snp.bottom).inset(-5)
            maker.leading.trailing.equalTo(view3).inset(5)
            maker.height.equalTo(50)
        }

        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(search.snp.bottom)
            maker.leading.trailing.equalTo(view3).inset(5)
            maker.bottom.equalTo(buttonBack.snp.top).inset(-5)
        }

        buttonBack.snp.makeConstraints { maker in
            maker.bottom.equalTo(view3).inset(5)
            maker.centerX.equalTo(view3)
            maker.height.equalTo(buttonHeight)
            maker.width.equalTo(buttonWidth)
        }
    }

    func onGetCurrencies() {
        tableView.reloadData()
    }
}

extension CurrencySelectionScreen: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        presenter.filtredDicOfCurrencies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let sortedDicOfCurrencies = presenter.filtredDicOfCurrencies.sorted { $0.value < $1.value }
        var sortedValue = [String]()
        var sortedKey = [String]()
        for (key, value) in sortedDicOfCurrencies {
            sortedKey.append(key)
            sortedValue.append(value)
        }
        cell.textLabel?.text = "\(sortedValue[indexPath.row]) (\(sortedKey[indexPath.row]))"
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sortedDicOfCurrencies = presenter.filtredDicOfCurrencies.sorted { $0.value < $1.value }
        var sortedValue = [String]()
        var sortedKey = [String]()
        for (key, value) in sortedDicOfCurrencies {
            sortedKey.append(key)
            sortedValue.append(value)
        }
        selectRow = [sortedKey[indexPath.row]: sortedValue[indexPath.row]]

        switch mode {
        case .none:
            break
        case .from:
            mainScreen?.update(titleFrom: sortedKey[indexPath.row])
        case .to:
            mainScreen?.update(titleTo: sortedKey[indexPath.row])
        }

        dismiss(animated: true)
    }

    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            presenter.filtredDicOfCurrencies = presenter.dicOfCurrencies.filter { $0.value.localizedCaseInsensitiveContains(searchText) || $0.key.localizedCaseInsensitiveContains(searchText) }
            tableView.reloadData()
        } else {
            presenter.filtredDicOfCurrencies = presenter.dicOfCurrencies
            tableView.reloadData()
        }
    }
}
