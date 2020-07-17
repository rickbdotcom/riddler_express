// https://fivethirtyeight.com/features/can-you-make-24/

import Foundation

enum Op: CaseIterable {
	case add
	case subtract
	case multiply
	case divide
	case exponentiation

	func perform(_ a: Double, _ b: Double) -> Double {
		switch self {
		case .add:
			return a + b
		case .subtract:
			return a - b
		case .multiply:
			return a * b
		case .divide:
			return a / b
		case .exponentiation:
			return pow(a, b)
		}
	}

	var description: String {
		switch self {
		case .add:
			return "+"
		case .subtract:
			return "-"
		case .multiply:
			return "*"
		case .divide:
			return "/"
		case .exponentiation:
			return "^"
		}
	}
}

enum RPN: Hashable {
	case op(Op)
	case value(Double)

	static func rpn(_ rpn: [Any]) -> [RPN] {
		rpn.compactMap { value in
			if let op = value as? Op {
				return .op(op)
			} else if let value = value as? Double {
				return .value(value)
			} else {
				return nil
			}
		}
	}

	static func calculate(_ rpn: [RPN]) throws -> Double {
		var stack = [Double]()
		try rpn.forEach { item in
			switch item {
			case let .op(op):
				if stack.count < 2 {
					throw RPNError.error
				}
				let a = stack.removeLast()
				let b = stack.removeLast()
				stack.append(op.perform(a, b))
			case let .value(value):
				stack.append(value)
			}
		}
		return stack[0]
	}

	static func infixDescription(_ rpn: [RPN]) -> String {
		var stack = [String]()
		try rpn.forEach { item in
			switch item {
			case let .op(op):
				let a = stack.removeLast()
				let b = stack.removeLast()
				stack.append("(\(a) \(op.description) \(b))")
			case let .value(value):
				stack.append(String(value))
			}
		}
		return stack[0]

	}

	static func description(_ rpn: [RPN]) -> String {
		rpn.map { op in
			op.description
		}.joined(separator: " ")
	}

	var description: String {
		switch self {
		case let .op(op):
			return op.description
		case let .value(value):
			return String(value)
		}
	}
}

enum RPNError: Error {
	case error
}

func find_matches(equal: Double, with values: [Double], using ops: [Op]) -> Set<[RPN]> {
	var answers = Set<[RPN]>()
	for (ai, a) in values.enumerated() {
		for (bi, b) in values.enumerated() where bi != ai {
			ops.forEach { Z in
				for (ci, c) in values.enumerated() where ci != bi && ci != ai {
					for (di, d) in values.enumerated() where di != ci && di != bi && di != ai {
						ops.forEach { X in
							ops.forEach { Y in
								let head = [a, b]
								let tail = [Z]
								permutations([c, d, X, Y]).forEach { ops in
									let rpn = RPN.rpn(head + ops + tail)
									do {
										if try RPN.calculate(rpn) == equal {
											answers.insert(rpn)
										}
									} catch { }
								}
							}
						}
					}
				}
			}
		}
	}
	return answers
}

extension Array {
    func decompose() -> (Iterator.Element, [Iterator.Element])? {
        guard let x = first else { return nil }
        return (x, Array(self[1..<count]))
    }
}

func between<T>(x: T, _ ys: [T]) -> [[T]] {
    guard let (head, tail) = ys.decompose() else { return [[x]] }
    return [[x] + ys] + between(x: x, tail).map { [head] + $0 }
}

func permutations<T>(_ xs: [T]) -> [[T]] {
    guard let (head, tail) = xs.decompose() else { return [[]] }
    return permutations(tail).flatMap { between(x: head, $0) }
}

let values = [2.0, 3.0, 3.0, 4.0]
let answer = 24.0

find_matches(equal: answer, with: values, using: Op.allCases).forEach { rpn in
	print(RPN.infixDescription(rpn))
}
