import XCTest
import SwiftUI
@testable import ViewInspector

#if os(iOS) || os(macOS)
@MainActor
@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
final class TextEditorTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: "")
        let view = AnyView(TextEditor(text: binding))
        XCTAssertNoThrow(try view.inspect().anyView().textEditor())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: "")
        let view = HStack {
            Text("Test")
            TextEditor(text: binding)
        }
        XCTAssertNoThrow(try view.inspect().hStack().textEditor(1))
    }
    
    func testSearch() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: "")
        let view = AnyView(TextEditor(text: binding))
        XCTAssertEqual(try view.inspect().find(ViewType.TextEditor.self).pathToRoot,
                       "anyView().textEditor()")
    }
    
    func testInput() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: "123")
        let view = TextEditor(text: binding)
        let sut = try view.inspect().textEditor()
        XCTAssertEqual(try sut.input(), "123")
        try sut.setInput("abc")
        XCTAssertEqual(try sut.input(), "abc")
    }
    
    func testSetInputWhenDisabled() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: "123")
        let view = TextEditor(text: binding).disabled(true)
        let sut = try view.inspect().textEditor()
        XCTAssertThrows(try sut.setInput("abc"),
            "TextEditor is unresponsive: it is disabled")
        XCTAssertEqual(try sut.input(), "123")
    }

    #if compiler(>=6.2)
    func testAttributedInput() throws {
        guard #available(iOS 26, macOS 26, visionOS 26, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: AttributedString("123"))
        let view = TextEditor(text: binding)
        let sut = try view.inspect().textEditor()
        XCTAssertEqual(try sut.attributedInput(), AttributedString("123"))
        try sut.setInput(AttributedString("abc"))
        XCTAssertEqual(try sut.attributedInput(), AttributedString("abc"))
    }

    func testSetAttributedInputWhenDisabled() throws {
        guard #available(iOS 26, macOS 26, visionOS 26, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: AttributedString("123"))
        let view = TextEditor(text: binding).disabled(true)
        let sut = try view.inspect().textEditor()
        XCTAssertThrows(try sut.setInput(AttributedString("abc")),
            "TextEditor is unresponsive: it is disabled")
        XCTAssertEqual(try sut.attributedInput(), AttributedString("123"))
    }

    func testSelection() throws {
        guard #available(iOS 26, macOS 26, visionOS 26, *)
        else { throw XCTSkip() }
        let text = "123"
        let binding = Binding(wrappedValue: text)
        let selection = Binding(wrappedValue: Optional(TextSelection(insertionPoint: text.endIndex)))
        let view = TextEditor(text: binding, selection: selection)
        let sut = try view.inspect().textEditor()
        XCTAssertEqual(try sut.selection(), TextSelection(insertionPoint: text.endIndex))
        try sut.setSelection(TextSelection(insertionPoint: text.startIndex))
        XCTAssertEqual(try sut.selection(), TextSelection(insertionPoint: text.startIndex))
    }

    func testSetSelectionWhenDisabled() throws {
        guard #available(iOS 26, macOS 26, visionOS 26, *)
        else { throw XCTSkip() }
        let text = "123"
        let binding = Binding(wrappedValue: text)
        let selection = Binding(wrappedValue: Optional(TextSelection(insertionPoint: text.endIndex)))
        let view = TextEditor(text: binding, selection: selection).disabled(true)
        let sut = try view.inspect().textEditor()
        XCTAssertThrows(try sut.setSelection(nil),
            "TextEditor is unresponsive: it is disabled")
        XCTAssertEqual(try sut.selection(), TextSelection(insertionPoint: text.endIndex))
    }

    func testAttributedSelection() throws {
        guard #available(iOS 26, macOS 26, visionOS 26, *)
        else { throw XCTSkip() }
        let text = AttributedString("123")
        let binding = Binding(wrappedValue: text)
        let selection = Binding(wrappedValue: AttributedTextSelection(insertionPoint: text.endIndex))
        let view = TextEditor(text: binding, selection: selection)
        let sut = try view.inspect().textEditor()
        XCTAssertEqual(try sut.attributedSelection(), AttributedTextSelection(insertionPoint: text.endIndex))
        try sut.setSelection(AttributedTextSelection(insertionPoint: text.startIndex))
        XCTAssertEqual(try sut.attributedSelection(), AttributedTextSelection(insertionPoint: text.startIndex))
    }

    func testSetAttributedSelectionWhenDisabled() throws {
        guard #available(iOS 26, macOS 26, visionOS 26, *)
        else { throw XCTSkip() }
        let text = AttributedString("123")
        let binding = Binding(wrappedValue: text)
        let selection = Binding(wrappedValue: AttributedTextSelection(insertionPoint: text.endIndex))
        let view = TextEditor(text: binding, selection: selection).disabled(true)
        let sut = try view.inspect().textEditor()
        XCTAssertThrows(try sut.setSelection(AttributedTextSelection()),
            "TextEditor is unresponsive: it is disabled")
        XCTAssertEqual(try sut.attributedSelection(), AttributedTextSelection(insertionPoint: text.endIndex))
    }
    #endif
}
#endif
