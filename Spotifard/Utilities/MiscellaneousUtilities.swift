import Foundation
import SwiftUI
import SpotifyWebAPI

extension View {

    /// Type erases self to `AnyView`. Equivalent to `AnyView(self)`.
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }

}

extension ProcessInfo {

    /// Whether or not this process is running within the context of a SwiftUI
    /// preview.
    var isPreviewing: Bool {
        return self.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

}

extension RandomAccessCollection {
    /// Get the index of or an insertion index for a new element in
    /// a sorted collection in ascending order.
    /// - Parameter value: The element to insert into the array.
    /// - Returns: The index suitable for inserting the new element
    ///            into the array, or the first index of an existing element.
    @inlinable
    public func sortedInsertionIndex(
        of element: Element
    ) -> Index where Element: Comparable {
        sortedInsertionIndex(of: element, by: <)
    }

    /// Get the index of or an insertion index for a new element in
    /// a sorted collection that matches the rule defined by the predicate.
    /// - Parameters:
    ///   - value: The element to insert into the array.
    ///   - areInIncreasingOrder:
    ///       A closure that determines if the first element should
    ///       come before the second element. For instance: `<`.
    /// - Returns: The index suitable for inserting the new element
    ///            into the array, or the first index of an existing element.
    @inlinable
    public func sortedInsertionIndex(
         of element: Element,
         by areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows -> Index {
        try sortedInsertionIndex { try areInIncreasingOrder($0, element) }
    }

    /// Get the index of or an insertion index for a new element in
    /// a sorted collection that matches the rule defined by the predicate.
    ///
    /// This variation is useful when comparing an element that
    /// is of a different type than those already in the array.
    /// - Parameter isOrderedAfter:
    ///     Return `true` if the new element should come after the one
    ///     provided in the closure, or `false` otherwise. For instance
    ///     `{ $0 < newElement }` to sort elements in increasing order.
    /// - Returns: The index suitable for inserting the new element into
    ///            the array, or the first index of an existing element.
    @inlinable
    public func sortedInsertionIndex(
         where isOrderedAfter: (Element) throws -> Bool
    ) rethrows -> Index {
        var slice: SubSequence = self[...]

        while !slice.isEmpty {
            let middle = slice.index(slice.startIndex, offsetBy: slice.count/2)
            if try isOrderedAfter(slice[middle]) {
                slice = slice[index(after: middle)...]
            } else {
                slice = slice[..<middle]
            }
        }
        return slice.startIndex
    }
}

extension RandomAccessCollection {
    @inlinable
    public func sortedFirstIndex(
        of element: Element
    ) -> Index? where Element: Comparable {
        sortedFirstIndex(of: element, by: <)
    }

    @inlinable
    public func sortedFirstIndex(
         of element: Element,
         by areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows -> Index? where Element: Comparable {
        let insertionIndex = try sortedInsertionIndex(of: element, by: areInIncreasingOrder)
        guard insertionIndex < endIndex, self[insertionIndex] == element else { return nil }
        return insertionIndex
    }

    @inlinable
    public func sortedLastIndex(
        of element: Element
    ) -> Index? where Element: Comparable {
        sortedLastIndex(of: element, by: <)
    }

    @inlinable
    public func sortedLastIndex(
        of element: Element,
        by areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows -> Index? where Element: Comparable {
        let insertionIndex = try sortedInsertionIndex(of: element) { try areInIncreasingOrder($1, $0) }
        let finalIndex = index(insertionIndex, offsetBy: -1)
        guard finalIndex >= startIndex, self[finalIndex] == element else { return nil }
        return finalIndex
    }
}

extension Array {
    @inlinable
    public mutating func insertSorted(_ element: Element) where Element: Comparable {
        insertSorted(element, by: <)
    }

    @inlinable
    public mutating func insertSorted(_ element: Element,
                             by areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows {
        let insertionIndex = try sortedInsertionIndex(of: element, by: areInIncreasingOrder)
        self.insert(element, at: insertionIndex)
    }

    @inlinable
    public mutating func appendSorted<S>(contentsOf newElements: S) where Element: Comparable, Element == S.Element, S : Sequence {
        appendSorted(contentsOf: newElements, by: <)
    }

    @inlinable
    public mutating func appendSorted<S>(
        contentsOf newElements: S,
        by comparator: (Element, Element) throws -> Bool
    ) rethrows where Element == S.Element, S : Sequence {
        for element in newElements {
            try insertSorted(element, by: comparator)
        }
    }
}

extension AsyncSequence {
    func collect() async rethrows -> [Element] {
        try await reduce(into: [Element]()) { $0.append($1) }
    }
}
