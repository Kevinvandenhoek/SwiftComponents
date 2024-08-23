//
//  View+Extension.swift
//
//
//  Created by Kevin van den Hoek on 27/10/2023.
//

import Foundation
import SwiftUI

public extension View {
    
    /// Adds a redacted effect only if a condition is met (i.e. isLoading)
    @ViewBuilder
    func redacted(reason: RedactionReasons = .placeholder, if condition: Bool) -> some View {
        if condition {
            self.redacted(reason: reason)
        } else {
            self
        }
    }
    
    /// Add's an opacity animation to the redacted effect. 'if condition' must be true for the view to become redacted.
    @ViewBuilder
    func shimmering(if condition: Bool) -> some View {
        if condition {
            self.redacted(if: condition)
                .modifier(OpacityAnimationModifier())
        } else {
            self
        }
    }
    
    /// Updates an external binding with the view's size
    func withSizeBinding(_ size: Binding<CGSize>) -> some View {
        self.modifier(WithSizeBinding(size: size))
    }
    
    func withElasticOffsetBinding(_ offset: Binding<CGFloat>, padding: CGFloat = 0) -> some View {
        self.modifier(WithElasticOffsetBinding(offset: offset, padding: padding))
    }
}

private struct OpacityAnimationModifier: ViewModifier {
    
    @State private var opacity: Double = 0.5
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                let animation = Animation.easeInOut(duration: 0.3).repeatForever(autoreverses: true)
                withAnimation(animation) {
                    opacity = 1
                }
            }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    
    static var defaultValue: Value = .zero
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

private struct WithSizeBinding: ViewModifier {
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .overlay(GeometryReader { geometry in
                Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
            })
            .onPreferenceChange(SizePreferenceKey.self) { newSize in
                self.size = newSize
            }
    }
}

private struct ElasticOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    
    static var defaultValue: Value = .zero
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

private struct WithElasticOffsetBinding: ViewModifier {
    @Binding var offset: CGFloat
    let padding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    let offset = max(0, geometry.frame(in: .named("TopOffsetBoundingBoxView")).minY - padding)
                    Color.clear.preference(key: ElasticOffsetPreferenceKey.self, value: offset)
                }
            }
            .onPreferenceChange(ElasticOffsetPreferenceKey.self) { offset in
                self.offset = offset
            }
    }
}

public extension View {
    
    @ViewBuilder
    func enableEntryAnimation(animation: Animation = .spring(duration: 0.5, bounce: 0.1)) -> some View {
        EntryAnimationView(animation: animation) {
            self
        }
    }
    
    func withEntryAnimation() -> some View {
        self.modifier(EntryAnimation())
    }
    
    @ViewBuilder
    func entryAnimationTransform(if condition: Bool) -> some View {
        self.scaleEffect(condition ? CGFloat.random(in: 1.3...1.6) : 1)
            .rotationEffect(.degrees(condition ? CGFloat.random(in: -10...10) : 0))
            .offset(
                x: condition ? CGFloat.random(in: -50...50) : 0,
                y: condition ? CGFloat.random(in: -50...50) : 0
            )
            .opacity(condition ? 0 : 1)
    }
}

private struct DidEntryAnimationKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

public extension EnvironmentValues {
    var didEntryAnimation: Bool {
        get { self[DidEntryAnimationKey.self] }
        set { self[DidEntryAnimationKey.self] = newValue }
    }
}

public struct EntryAnimationView<Content: View>: View {
    let content: Content
    let animation: Animation
    
    @State private var didEntryAnimation: Bool = UIAccessibility.isReduceMotionEnabled
    
    public init(animation: Animation, @ViewBuilder content: () -> Content) {
        self.animation = animation
        self.content = content()
    }
    
    public var body: some View {
        content
            .environment(\.didEntryAnimation, didEntryAnimation)
            .onAppear {
                guard !UIAccessibility.isReduceMotionEnabled else { return }
                withAnimation(animation) {
                    didEntryAnimation = true
                }
            }
    }
}

private struct EntryAnimation: ViewModifier {
    
    @SwiftUI.Environment(\.didEntryAnimation)
    var didEntryAnimation

    func body(content: Content) -> some View {
        content
            .entryAnimationTransform(if: !didEntryAnimation)
    }
}
