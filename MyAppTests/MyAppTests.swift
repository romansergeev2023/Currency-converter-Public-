@testable import MyApp
import XCTest

class MyAppTests: XCTestCase {
    // var sut: CurrencySelectionScreen!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // sut = CurrencySelectionScreen()
    }

    override func tearDownWithError() throws {
        // sut = nil
        try super.tearDownWithError()
    }

    func testKeyboard() throws {
        let keyboard = KeyboardController()
        let buttons = keyboard.view.subviews.compactMap {
            $0 as? KeyboardButton
        }
        XCTAssertEqual(buttons.count, keyboard.allButtons.count)
    }
}
