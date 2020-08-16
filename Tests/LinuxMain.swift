import XCTest

import raspberry_piTests

var tests = [XCTestCaseEntry]()
tests += raspberry_piTests.allTests()
XCTMain(tests)
