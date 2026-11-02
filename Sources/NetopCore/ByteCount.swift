import Foundation

/// A number of bytes, e.g. traffic sent or received by an app.
public struct ByteCount: Hashable, Comparable, Sendable {
    public var bytes: Int64

    public init(_ bytes: Int64) {
        self.bytes = bytes
    }

    public static let zero = ByteCount(0)

    public static func + (lhs: ByteCount, rhs: ByteCount) -> ByteCount {
        ByteCount(lhs.bytes + rhs.bytes)
    }

    public static func < (lhs: ByteCount, rhs: ByteCount) -> Bool {
        lhs.bytes < rhs.bytes
    }

    /// Human-readable size such as "1.5 MB" (decimal units, like Finder).
    /// The locale is a parameter so tests can pin it.
    public func formatted(locale: Locale = .current) -> String {
        bytes.formatted(.byteCount(style: .file).locale(locale))
    }
}
