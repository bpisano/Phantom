import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(PhantomTypeMacros)
    import PhantomTypeMacros

    let testMacros: [String: Macro.Type] = [
        "Phantom": PhantomMacro.self,
        "PhantomProperty": PhantomPropertyMacro.self,
    ]
#endif

final class PhantomTypeTests: XCTestCase {
    func testMacro() throws {
        #if canImport(PhantomTypeMacros)
            assertMacroExpansion(
                """
                @Phantom
                struct Person {
                    @PhantomProperty
                    var id: String
                }
                """,
                expandedSource: """
                    struct Person {
                        @PhantomWrapped<String, Person>
                        var id: String

                        typealias Id = PhantomType<String, Person>
                    }
                    """,
                macros: testMacros
            )
        #endif
    }

    func testMacroWithPhantomProperty() throws {
        #if canImport(PhantomTypeMacros)
            assertMacroExpansion(
                """
                @Phantom
                struct Person {
                    @PhantomProperty
                    var identifier: String
                }
                """,
                expandedSource: """
                    struct Person {
                        @PhantomWrapped<String, Person>
                        var identifier: String

                        typealias Identifier = PhantomType<String, Person>
                    }
                    """,
                macros: testMacros
            )
        #endif
    }

    func testMacroWithCustomTypealiasName() throws {
        #if canImport(PhantomTypeMacros)
            assertMacroExpansion(
                """
                @Phantom
                struct Person {
                    @PhantomProperty("PersonID")
                    var id: String
                }
                """,
                expandedSource: """
                    struct Person {
                        @PhantomWrapped<String, Person>
                        var id: String

                        typealias PersonID = PhantomType<String, Person>
                    }
                    """,
                macros: testMacros
            )
        #endif
    }

    func testMacroWithPublicStruct() throws {
        #if canImport(PhantomTypeMacros)
            assertMacroExpansion(
                """
                @Phantom
                public struct Person {
                    @PhantomProperty
                    var id: String
                }
                """,
                expandedSource: """
                    public struct Person {
                        @PhantomWrapped<String, Person>
                        var id: String

                        public typealias Id = PhantomType<String, Person>
                    }
                    """,
                macros: testMacros
            )
        #endif
    }

}
