//
//  LoadableView.swift
//
//
//  Created by Kevin van den Hoek on 27/10/2023.
//

import Foundation
import SwiftUI

public struct LoadableView<Content: View, Failure: View, Item>: View {
    
    public let loadable: Loadable<Item>
    public let content: (Item) -> Content
    public let failure: (Error) -> Failure
    
    public init(_ loadable: Loadable<Item>, @ViewBuilder failure: @escaping (Error) -> Failure, @ViewBuilder content: @escaping (Item) -> Content) {
        self.loadable = loadable
        self.failure = failure
        self.content = content
    }
    
    public var body: some View {
        if let error = loadable.error {
            failure(error)
        } else {
            content(loadable.valueOrPlaceholder)
                .shimmering(if: loadable.isLoading)
                .disabled(loadable.isLoading)
        }
    }
}

public extension LoadableView where Failure == EmptyView {
    
    static func emptyOnError(_ loadable: Loadable<Item>, @ViewBuilder content: @escaping (Item) -> Content) -> Self {
        self.init(
            loadable,
            failure: { _ in EmptyView() },
            content: content
        )
    }
}
