import MyApp
import MyAppCommon
import XCTest

class MyAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    func testAlert() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons[AccessId.idSwipe.rawValue].tap()
        XCTAssert(app.alerts["Error"].waitForExistence(timeout: 1.0))
    }

    func testKeyboard() throws {
        let app = XCUIApplication()
        app.launch()
        let textField = app.textFields[AccessId.idTextFieldFrom.rawValue]
        let strNumbers = (0 ... 9).map(String.init).reversed() + ["."]

        for num in strNumbers {
            app.buttons[num].tap()
            XCTAssertEqual((textField.value as? String)?.last, num.last)
        }

        for _ in 0 ... 5 {
            if let cntCharacters = (textField.value as? String)?.count {
                app.buttons[AccessId.idDel.rawValue].tap()
                XCTAssertEqual((textField.value as? String)?.count, cntCharacters - 1)
            }
        }

        app.buttons[AccessId.idClear.rawValue].tap()
        if let text = textField.value as? String {
            XCTAssert(text.isEmpty)
        }
    }

    func testChoiceOFCurrencies() throws {
        let app = XCUIApplication()
        app.launch()
        functionTest(app: app, button: AccessId.idBtnFrom.rawValue, typeText: "EURO")
        functionTest(app: app, button: AccessId.idBtnTo.rawValue, typeText: "CZK")
    }

    private func functionTest(app: XCUIApplication, button: String, typeText: String) {
        let searchField = app.searchFields[AccessId.idSearch.rawValue]
        let tablesQuery = app.tables
        let button = app.buttons[button]

        button.waitForExistence(timeout: 5)
        button.tap()
        XCTAssertTrue(tablesQuery.cells.count > 0)
        searchField.waitForExistence(timeout: 5)
        searchField.tap()
        searchField.typeText(typeText)
        let firstCell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
        firstCell.tap()
    }
}
