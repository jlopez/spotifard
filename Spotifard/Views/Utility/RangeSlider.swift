//
//  RangeSlider.swift
//  Spotifard
//
//  Created by Jesus Lopez on 11/30/23.
//

import SwiftUI
import Combine

// https://stackoverflow.com/questions/62587261/swiftui-2-handle-range-slider
struct RangeSlider<Label, ValueLabel> : View where Label : View, ValueLabel : View {
    @Binding var value: ClosedRange<Double>
    var bounds: ClosedRange<Double>
    var step: Double.Stride
    var label: Label
    var minimumValueLabel: ValueLabel?
    var maximumValueLabel: ValueLabel?
    var onEditingChanged: (Bool) -> Void
    @State var dragging: Bool = false

    init(
        value: Binding<ClosedRange<Double>>,
        in bounds: ClosedRange<Double> = 0...1,
        step: Double.Stride = 1,
        @ViewBuilder label: () -> Label,
        @ViewBuilder minimumValueLabel: () -> ValueLabel,
        @ViewBuilder maximumValueLabel: () -> ValueLabel,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self._value = value
        self.bounds = bounds
        self.step = step
        self.label = label()
        self.minimumValueLabel = minimumValueLabel()
        self.maximumValueLabel = maximumValueLabel()
        self.onEditingChanged = onEditingChanged
    }

    var body: some View {
        HStack() {
            if let label = minimumValueLabel { label }

            GeometryReader { geometry in
                ZStack {
                    let fraction = bounds.toFraction(value.lowerBound)...bounds.toFraction(value.upperBound)
                    let diameter = 28.0
                    let radius = diameter / 2
                    let w = geometry.size.width - diameter
                    let offset = (fraction.lowerBound - 0.5) * w
                    let offset2 = (fraction.upperBound - 0.5) * w
                    let w1 = (fraction.upperBound - fraction.lowerBound) * w

                    // Slider track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.sliderGray)
                        .frame(height: 4)

                    // Highlighted track between both sliders
                    Rectangle()
                        .fill(.tint)
                        .frame(width: w1, height: 4)
                        .position(x: w1 / 2 + fraction.lowerBound * w + radius, y: geometry.size.height / 2)

                    // Left slider
                    Path { path in
                        path.move(to: CGPoint(x: radius, y: 0))
                        path.addLine(to: CGPoint(x: radius, y: 0))
                        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                    }
                    .frame(width: diameter, height: diameter)
                    .foregroundColor(.white)
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.2), radius: 4, y: 2)
                    .offset(x: offset, y: 0)
                    .highPriorityGesture(DragGesture()
                        .onChanged { value in
                            dragging = true
                            let lowerBound = max(0, min((value.location.x - radius) / w + 0.5, 1))
                            let upperBound = max(lowerBound, fraction.upperBound)
                            self.value = bounds.fromFraction(lowerBound)...bounds.fromFraction(upperBound)
                        }
                        .onEnded { _ in
                            dragging = false
                        })

                    // Right slider
                    Path { path in
                        path.move(to: CGPoint(x: radius, y: 0))
                        path.addLine(to: CGPoint(x: radius, y: 0))
                        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: true)
                    }
                    .frame(width: diameter, height: diameter)
                    .foregroundColor(.white)
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.2), radius: 4, x: 2, y: 2)
                    .offset(x: offset2, y: 0)
                    .highPriorityGesture(DragGesture()
                        .onChanged { value in
                            dragging = true
                            let upperBound = max(0, min((value.location.x - radius) / w + 0.5, 1))
                            let lowerBound = min(fraction.lowerBound, upperBound)
                            self.value = bounds.fromFraction(lowerBound)...bounds.fromFraction(upperBound)
                        }
                        .onEnded { _ in
                            dragging = false
                        })
                }
            }
            .onChange(of: dragging) {
                onEditingChanged(dragging)
            }

            if let label = maximumValueLabel { label }
        }
    }

    func log(_ geometry: GeometryProxy) -> Bool {
        return false
    }
}

extension RangeSlider where ValueLabel == EmptyView {
    init(
        value: Binding<ClosedRange<Double>>,
        in bounds: ClosedRange<Double> = 0...1,
        step: Double.Stride = 1,
        @ViewBuilder label: () -> Label,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self._value = value
        self.bounds = bounds
        self.step = step
        self.label = label()
        self.onEditingChanged = onEditingChanged
    }
}

struct MutableRange<Value> where Value : Comparable {
    var lowerBound: Value
    var upperBound: Value
}

extension ClosedRange where Bound : FloatingPoint {
    func toFraction(_ value: Bound) -> Bound {
        return (value - lowerBound) / (upperBound - lowerBound)
    }

    func fromFraction(_ fraction: Bound) -> Bound {
        return lowerBound + fraction * (upperBound - lowerBound)
    }
}

extension FloatingPoint {
    func clampedTo(_ bounds: ClosedRange<Self>) -> Self {
        return min(max(bounds.lowerBound, self), bounds.upperBound)
    }
}

#Preview {
    struct Content: View {
        @State var value = 77.0...83.0
        @State var toggle: Bool = false
        @State var dummy = 0.0

        var body: some View {
            List {
                Section("Value \(value.lowerBound, specifier: "%.0f") - \(value.upperBound, specifier: "%.0f")") {
                    RangeSlider(value: $value, in: 0...100, step: 5) { Text("Popularity") } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("100")
                    } onEditingChanged: { editing in
                        print("Editing \(editing)")
                    }
                }
            }
        }
    }

    return Content()
}
