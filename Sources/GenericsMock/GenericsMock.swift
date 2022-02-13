import Foundation

typealias MethodArg = Equatable & CustomDebugStringConvertible
protocol MethodArgs: Equatable, CustomDebugStringConvertible {}

struct MethodArg0: MethodArgs {
    var debugDescription: String {
        "none args"
    }
}

struct MethodArg1<A1: MethodArg>: MethodArgs {
    let arg1: A1

    init(_ arg1: A1) {
        self.arg1 = arg1
    }

    var debugDescription: String {
        String(reflecting: arg1)
    }
}

struct MethodArg2<A1: MethodArg, A2: MethodArg>: MethodArgs {
    let arg1: A1
    let arg2: A2

    init(_ arg1: A1, _ arg2: A2) {
        self.arg1 = arg1
        self.arg2 = arg2
    }

    var debugDescription: String {
        "\(String(reflecting: arg1)), \(String(reflecting: arg2))"
    }
}

struct MethodReturn<T> {
    let value: T
}

class ExpectMethod<A: MethodArgs, R> {
    typealias Args = A
    typealias Return = MethodReturn<R>

    var args: Args?
    var ret: Return?

    func args(_ args: Args) -> Self {
        self.args = args
        return self
    }

    func andReturn(_ ret: R) -> Self {
        self.ret = Return(value: ret)
        return self
    }
}

class ExpectMethodCalls<A: MethodArgs, R> {
    typealias ExpectMethodCall = ExpectMethod<A, R>
    var expectCalls = [ExpectMethodCall]()

    func append(_ args: A) -> ExpectMethodCall {
        let call = ExpectMethodCall().args(args)
        expectCalls.append(call)
        return call
    }
}

struct MethodMock<A: MethodArgs, R> {
    var expectMethodCalls: ExpectMethodCalls<A, R>

    func call(methodName: String, actualArgs: A) throws -> R {
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

struct MethodBuilder<A: MethodArgs, R> {
    typealias ExpectCalls = ExpectMethodCalls<A, R>

    let calls = ExpectCalls()
    func args(_ args: A) -> ExpectCalls.ExpectMethodCall {
        return calls.append(args)
    }

    func mock() -> MethodMock<A, R> {
        return MethodMock<A, R>(expectMethodCalls: calls)
    }
}

struct Method<A: MethodArgs, R> {
    typealias Mock = MethodMock<A, R>
    typealias ExpectCalls = ExpectMethodCalls<A, R>
    typealias Args = A
    typealias Builder = MethodBuilder<A, R>
}
