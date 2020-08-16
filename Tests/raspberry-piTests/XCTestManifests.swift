import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(raspberry_piTests.allTests),
    ]
}
#endif
