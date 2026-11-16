import XCTest
import SwiftUI
@testable import ViewInspector

@MainActor
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ContentUnavailableViewTests: XCTestCase {

    func testInspect() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        XCTAssertNoThrow(try ContentUnavailableView("title", systemImage: "swift", description: Text("desc")).inspect())
    }

    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let view = AnyView(ContentUnavailableView("title", systemImage: "swift", description: Text("desc")))
        XCTAssertNoThrow(try view.inspect().anyView().contentUnavailableView())
    }

    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let view = HStack {
            Text("")
            ContentUnavailableView("title", systemImage: "swift", description: Text("desc"))
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().contentUnavailableView(1))
    }

    func testSearch() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let view = HStack {
            ContentUnavailableView { Text("tx") } description: { Text("desc") } actions: { Text("act") }
        }
        XCTAssertEqual(try view.inspect().find(ViewType.ContentUnavailableView.self).pathToRoot,
                       "hStack().contentUnavailableView(0)")
        XCTAssertEqual(try view.inspect().find(text: "tx").pathToRoot,
                       "hStack().contentUnavailableView(0).labelView().text()")
        XCTAssertEqual(try view.inspect().find(text: "desc").pathToRoot,
                       "hStack().contentUnavailableView(0).description().text()")
        XCTAssertEqual(try view.inspect().find(text: "act").pathToRoot,
                       "hStack().contentUnavailableView(0).actions().text()")
    }

    func testLabelViewInspection() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let view = ContentUnavailableView {
            HStack { Text("abc") }
        }
        let sut = try view.inspect().contentUnavailableView().labelView().hStack(0).text(0).string()
        XCTAssertEqual(sut, "abc")
    }

    func testDescriptionInspection() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let view = ContentUnavailableView {
        } description: {
            VStack { Text("xyz") }
        }
        let sut = try view.inspect().contentUnavailableView().description().vStack(0).text(0).string()
        XCTAssertEqual(sut, "xyz")
    }

    func testActionsInspection() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let view = ContentUnavailableView {
        } description: {
        } actions: {
            Group { Text("lmnop") }
        }
        let sut = try view.inspect().contentUnavailableView().actions().group(0).text(0).string()
        XCTAssertEqual(sut, "lmnop")
    }
}
