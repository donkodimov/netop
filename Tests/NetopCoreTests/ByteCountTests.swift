import Foundation
import Testing
@testable import NetopCore

@Suite struct ByteCountTests {
    let enUS = Locale(identifier: "en_US")

    @Test func addsBytes() {
        #expect(ByteCount(1_000) + ByteCount(500) == ByteCount(1_500))
    }

    @Test func ordersBySize() {
        #expect(ByteCount(1) < ByteCount(2))
        #expect([ByteCount(3), ByteCount(1)].max() == ByteCount(3))
    }

    @Test func formatsDecimalUnits() {
        #expect(ByteCount(1_500_000).formatted(locale: enUS) == "1.5 MB")
        #expect(ByteCount(2_000_000_000).formatted(locale: enUS) == "2 GB")
    }
}
