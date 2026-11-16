import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct TextEditor: KnownViewType {
        public static let typePrefix: String = "TextEditor"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func textEditor() throws -> InspectableView<ViewType.TextEditor> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func textEditor(_ index: Int) throws -> InspectableView<ViewType.TextEditor> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.TextEditor {
    
    func input() throws -> String {
        return try inputBinding().wrappedValue
    }
    
    func setInput(_ value: String) throws {
        try guardIsResponsive()
        try inputBinding().wrappedValue = value
    }
    
    private func inputBinding() throws -> Binding<String> {
        #if compiler(>=6.2)
        if #available(iOS 26, macOS 26, visionOS 26, watchOS 26, *),
           let binding = try? stringSelectionBindings().0 {
            return binding
        }
        #endif
        if let binding = try? Inspector.attribute(
            label: "text", value: content.view, type: Binding<String>.self) {
            return binding
        }
        return try Inspector.attribute(
            label: "_text", value: content.view, type: Binding<String>.self)
    }
}

#if compiler(>=6.2)
@available(iOS 26, macOS 26, visionOS 26, watchOS 26, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.TextEditor {

    func attributedInput() throws -> AttributedString {
        return try attributedInputBinding().wrappedValue
    }

    func setInput(_ value: AttributedString) throws {
        try guardIsResponsive()
        try attributedInputBinding().wrappedValue = value
    }

    func selection() throws -> TextSelection? {
        return try stringSelectionBindings().1?.wrappedValue
    }

    func setSelection(_ value: TextSelection?) throws {
        try guardIsResponsive()
        try stringSelectionBindings().1?.wrappedValue = value
    }

    func attributedSelection() throws -> AttributedTextSelection? {
        return try attributedSelectionBinding()?.wrappedValue
    }

    func setSelection(_ value: AttributedTextSelection) throws {
        try guardIsResponsive()
        try attributedSelectionBinding()?.wrappedValue = value
    }

    private func stringSelectionBindings() throws -> (Binding<String>, Binding<TextSelection?>?) {
        return try Inspector.attribute(
            path: "storage|string", value: content.view, type: (Binding<String>, Binding<TextSelection?>?).self)
    }

    private func attributedInputBinding() throws -> Binding<AttributedString> {
        return try Inspector.attribute(
            path: "storage|attributedString|text", value: content.view, type: Binding<AttributedString>.self)
    }

    private func attributedSelectionBinding() throws -> Binding<AttributedTextSelection>? {
        return try Inspector.attribute(
            path: "storage|attributedString|selection", value: content.view,
            type: Binding<AttributedTextSelection>?.self)
    }
}
#endif
