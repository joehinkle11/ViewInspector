import XCTest
import Combine
import SwiftUI

@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class CustomViewBuilderTests: XCTestCase {
    
    @MainActor
    func testSingleEnclosedView() throws {
        let sut = TestViewBuilderView { Text("Test") }
        let string = try sut.inspect().implicitAnyView().text(0).string()
        XCTAssertEqual(string, "Test")
    }
    
    @MainActor
    func testSingleEnclosedViewIndexOutOfBounds() throws {
        let sut = TestViewBuilderView { Text("Test") }
        XCTAssertThrows(
            try sut.inspect().text(1),
            "Enclosed view index '1' is out of bounds: '0 ..< 1'")
    }
    
    @MainActor
    func testMultipleEnclosedViews() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = TestViewBuilderView { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().implicitAnyView().text(0).content.view as? Text
        let view2 = try view.inspect().implicitAnyView().text(1).content.view as? Text
        let view3 = try view.inspect().implicitAnyView().text(2).content.view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }
    
    @MainActor
    func testMultipleEnclosedViewsIndexOutOfBounds() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let view = TestViewBuilderView { sampleView1; sampleView2 }
        XCTAssertThrows(
            try view.inspect().implicitAnyView().text(2),
            "Enclosed view index '2' is out of bounds: '0 ..< 2'")
    }
    
    @MainActor
    func testResetsModifiers() throws {
        let view1 = TestViewBuilderView { Text("Test") }.padding().offset()
        let sut1 = try view1.inspect().view(TestViewBuilderView<Text>.self).implicitAnyView().text(0)
        XCTAssertEqual(sut1.content.medium.viewModifiers.count, 1)
        let view2 = TestViewBuilderView { Text("Test"); EmptyView() }.padding().offset()
        let sut2 = try view2.inspect().view(TestViewBuilderView<Text>.self).implicitAnyView().text(0)
        XCTAssertEqual(sut2.content.medium.viewModifiers.count, 0)
    }
    
    @MainActor
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(TestViewBuilderView {
            Spacer()
            Text("Test")
        })
        XCTAssertNoThrow(try view.inspect().anyView()
            .view(TestViewBuilderView<EmptyView>.self).implicitAnyView().text(1))
    }
    
    @MainActor
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            TestViewBuilderView { Text("Test") }
            TestViewBuilderView { Text("Test") }
        }
        XCTAssertNoThrow(try view.inspect().hStack().view(TestViewBuilderView<Text>.self, 0))
        XCTAssertNoThrow(try view.inspect().hStack().view(TestViewBuilderView<Text>.self, 1))
    }
    
    @MainActor
    func testActualView() throws {
        let sut = TestViewBuilderView { Text("Test") }
        XCTAssertNoThrow(try sut.inspect().view(TestViewBuilderView<Text>.self).actualView().content)
    }
    
    @MainActor
    func testViewBody() {
        XCTAssertNoThrow(TestViewBuilderView { Text("Test") }.body)
    }
    
    @MainActor
    func testSearch() throws {
        let view = HStack {
            TestViewBuilderView { Text("Test"); EmptyView() }
        }
        let sut = try view.inspect()
        let path1 = try sut.find(text: "Test").pathToRoot
        #if compiler(<6) || compiler(>=6.1)
        let path2 = try sut.hStack().view(TestViewBuilderView<EmptyView>.self, 0).text(0).pathToRoot
        XCTAssertEqual(path1, "hStack().view(TestViewBuilderView<EmptyView>.self, 0).text(0)")
        XCTAssertEqual(path2, "hStack().view(TestViewBuilderView<EmptyView>.self, 0).text(0)")
        #else
        let path2 = try sut.hStack().view(TestViewBuilderView<EmptyView>.self, 0).implicitAnyView().text(0).pathToRoot
        XCTAssertEqual(path1, "hStack().view(TestViewBuilderView<EmptyView>.self, 0).anyView().text(0)")
        XCTAssertEqual(path2, "hStack().view(TestViewBuilderView<EmptyView>.self, 0).anyView().text(0)")
        #endif
    }
    
    @MainActor
    func testLocalViewBuilder() throws {
        struct ViewWrapper<V: View>: View {
            @ViewBuilder var view: () -> V
            init(@ViewBuilder view: @escaping () -> V) {
                self.view = view
            }
            var body: some View {
                view()
            }
        }
        let view = ViewWrapper { ViewWrapper { Text("test") } }
        let sut = try view.inspect()
        XCTAssertNoThrow(try sut.find(ViewWrapper<ViewWrapper<Text>>.self))
        XCTAssertNoThrow(try sut.find(ViewWrapper<Text>.self))
        #if compiler(<6) || compiler(>=6.1)
        XCTAssertEqual(try sut.find(ViewType.Text.self).pathToRoot,
                       "view(ViewWrapper<EmptyView>.self).view(ViewWrapper<EmptyView>.self).text()")
        #else
        XCTAssertEqual(try sut.find(ViewType.Text.self).pathToRoot,
            "view(ViewWrapper<EmptyView>.self).anyView().view(ViewWrapper<EmptyView>.self).anyView().text()")
        #endif
    }
}

// MARK: - Test Views

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestViewBuilderView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
    }
}
