import SwiftUI

#if os(iOS)

public extension ViewType {
    
    struct EditButton: KnownViewType {
        public static var typePrefix: String = "EditButton"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func editButton() throws -> InspectableView<ViewType.EditButton> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func editButton(_ index: Int) throws -> InspectableView<ViewType.EditButton> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.EditButton {
    
    func editMode() throws -> Binding<EditMode>? {
        let editMode = try Inspector.attribute(label: "editMode", value: content.view)
        typealias Env = Environment<Binding<EditMode>?>
        return (editMode as? Env)?.wrappedValue
    }
}

#endif
