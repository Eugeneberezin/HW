import SwiftUI

public extension ViewType {
    
    struct Group: KnownViewType {
        public static let typePrefix: String = "Group"
    }
}

// MARK: - Content Extraction

extension ViewType.Group: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let content = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func group() throws -> InspectableView<ViewType.Group> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func group(_ index: Int) throws -> InspectableView<ViewType.Group> {
        return try .init(try child(at: index))
    }
}
