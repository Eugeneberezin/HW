import SwiftUI

#if !os(watchOS)

public extension ViewType {
    
    struct NavigationView: KnownViewType {
        public static var typePrefix: String = "NavigationView"
    }
}

// MARK: - Content Extraction

extension ViewType.NavigationView: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let content = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func navigationView() throws -> InspectableView<ViewType.NavigationView> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func navigationView(_ index: Int) throws -> InspectableView<ViewType.NavigationView> {
        return try .init(try child(at: index))
    }
}

#endif
