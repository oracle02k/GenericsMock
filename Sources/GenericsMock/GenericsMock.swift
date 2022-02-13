import Foundation

public typealias MethodArg = Equatable & CustomDebugStringConvertible
public protocol MethodArgs: Equatable, CustomDebugStringConvertible {}

public struct MethodArg0: MethodArgs {
    public var debugDescription: String {
        "none args"
    }
}

public struct MethodArg1<A1: MethodArg>: MethodArgs {
    let arg1: A1

    public init(_ arg1: A1) {
        self.arg1 = arg1
    }

    public var debugDescription: String {
        String(reflecting: arg1)
    }
}

public struct MethodArg2<A1: MethodArg, A2: MethodArg>: MethodArgs {
    let arg1: A1
    let arg2: A2

    public init(_ arg1: A1, _ arg2: A2) {
        self.arg1 = arg1
        self.arg2 = arg2
    }

    public var debugDescription: String {
        "\(String(reflecting: arg1)), \(String(reflecting: arg2))"
    }
}

public struct MethodReturn<T> {
    let value: T
}

public class ExpectMethod<A: MethodArgs, R> {
    public typealias Args = A
    public typealias Return = MethodReturn<R>

    public var args: Args?
    public var ret: Return?

    public func args(_ args: Args) -> Self {
        self.args = args
        return self
    }

    public func andReturn(_ ret: R) -> Self {
        self.ret = Return(value: ret)
        return self
    }
}

public class ExpectMethodCalls<A: MethodArgs, R> {
    public typealias ExpectMethodCall = ExpectMethod<A, R>
    var expectCalls = [ExpectMethodCall]()

    public func append(_ args: A) -> ExpectMethodCall {
        let call = ExpectMethodCall().args(args)
        expectCalls.append(call)
        return call
    }
}

struct MethodMock<A: MethodArgs, R> {
    var expectMethodCalls: ExpectMethodCalls<A, R>

    public func call(methodName: String, actualArgs: A) throws -> R {
        let match = expectMethodCalls.expectCalls.first(where: {
            guard let args = $0.args else { return false }
            return (args == actualArgs)
        })

        guard let m = match else {
            fatalError("\(methodName) において \(String(reflecting:actualArgs)) にマッチする引数が見つからない")
        }

        guard let r = m.ret else {
            fatalError("戻り値が設定されていない")
        }

        return r.value
    }
}

public struct MethodBuilder<A: MethodArgs, R> {
    public typealias ExpectCalls = ExpectMethodCalls<A, R>

    let calls = ExpectCalls()
    public func args(_ args: A) -> ExpectCalls.ExpectMethodCall {
        return calls.append(args)
    }

    public func mock() -> MethodMock<A, R> {
        return MethodMock<A, R>(expectMethodCalls: calls)
    }
}

public struct Method<A: MethodArgs, R> {
    public typealias Mock = MethodMock<A, R>
    public typealias ExpectCalls = ExpectMethodCalls<A, R>
    public typealias Args = A
    public typealias Builder = MethodBuilder<A, R>
}
