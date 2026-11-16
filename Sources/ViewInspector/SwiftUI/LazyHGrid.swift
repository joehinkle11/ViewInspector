import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct LazyHGrid: KnownViewType {
        public static let typePrefix: String = "LazyHGrid"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func lazyHGrid() throws -> InspectableView<ViewType.LazyHGrid> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func lazyHGrid(_ index: Int) throws -> InspectableView<ViewType.LazyHGrid> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.LazyHGrid: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        return try ViewType.LazyHStack.children(content)
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension InspectableView where View == ViewType.LazyHGrid {
    
    func alignment() throws -> VerticalAlignment {
        return try Inspector.attribute(
            label: "alignment", value: lazyHGridLayout(), type: VerticalAlignment.self)
    }
    
    func spacing() throws -> CGFloat? {
        return try Inspector.attribute(
            label: "spacing", value: lazyHGridLayout(), type: CGFloat?.self)
    }
    
    func pinnedViews() throws -> PinnedScrollableViews {
        return try Inspector.attribute(
            label: "pinnedViews", value: lazyHGridLayout(), type: PinnedScrollableViews.self)
    }
    
    func rows() throws -> [GridItem] {
        return try Inspector.attribute(
            label: "rows", value: lazyHGridLayout(), type: [GridItem].self)
    }
    
    private func lazyHGridLayout() throws -> Any {
        if let layout = try? Inspector.attribute(path: "tree|content|root", value: content.view) {
            return layout
        }
        return try Inspector.attribute(path: "tree|root", value: content.view)
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension Array where Element == GridItem {
    public func isEqual(_ other: [GridItem]) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).allSatisfy { $0.isEqual($1) }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension GridItem {
    public func isEqual(_ rhs: GridItem) -> Bool {
        let lhs = self
        return lhs.size.isEqual(rhs.size)
            && lhs.spacing == rhs.spacing
            && lhs.alignment == rhs.alignment
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private extension GridItem.Size {
    func isEqual(_ rhs: GridItem.Size) -> Bool {
        let lhs = self
        switch (lhs, rhs) {
        case let (.fixed(lhsValue), .fixed(rhsValue)):
            return lhsValue == rhsValue
        case let (.flexible(lhsMin, lhsMax), .flexible(rhsMin, rhsMax)):
            return lhsMin == rhsMin && lhsMax == rhsMax
        case let (.adaptive(lhsMin, lhsMax), .adaptive(rhsMin, rhsMax)):
            return lhsMin == rhsMin && lhsMax == rhsMax
        default:
            return false
        }
    }
}
