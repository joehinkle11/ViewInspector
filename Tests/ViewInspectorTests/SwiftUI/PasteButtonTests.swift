import XCTest
import SwiftUI
import UniformTypeIdentifiers.UTType
@testable import ViewInspector

#if os(macOS)

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
final class PasteButtonTests: XCTestCase {
    
    @MainActor
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(PasteButton(supportedTypes: [], payloadAction: { _ in }))
        XCTAssertNoThrow(try view.inspect().anyView().pasteButton())
    }
    
    @MainActor
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            PasteButton(supportedTypes: [], payloadAction: { _ in })
            PasteButton(supportedTypes: [], payloadAction: { _ in })
        }
        XCTAssertNoThrow(try view.inspect().hStack().pasteButton(0))
        XCTAssertNoThrow(try view.inspect().hStack().pasteButton(1))
    }
    
    @MainActor
    func testSearch() throws {
        let view = AnyView(PasteButton(supportedTypes: [], payloadAction: { _ in }))
        XCTAssertEqual(try view.inspect().find(ViewType.PasteButton.self).pathToRoot,
                       "anyView().pasteButton()")
    }
    
    @available(macOS 11.0, *)
    @MainActor
    func testSupportedTypes() throws {
        let types = [UTType.gif, .pdf]
        let view = PasteButton(supportedContentTypes: types, payloadAction: { _ in })
        let sut = try view.inspect().pasteButton().supportedContentTypes()
        XCTAssertEqual(sut, types)
    }
}

#endif
