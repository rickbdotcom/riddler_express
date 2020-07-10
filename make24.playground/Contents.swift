// https://fivethirtyeight.com/features/can-you-make-24/

import Foundation

enum Op: CaseIterable {
	case add
	case subtract
	case multiply
	case divide
	case exponentiation

	static var all: [Op] = [.add, .subtract, .multiply, .divide, .exponentiation]

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

enum RPN {
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

	static func calculate(_ rpn: [RPN]) -> Double {
		var stack = [Double]()
		rpn.forEach { item in
			switch item {
			case let .op(op):
				let a = stack.removeLast()
				let b = stack.removeLast()
				stack.append(op.perform(a, b))
			case let .value(value):
				stack.append(value)
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


func find_matches(equal: Double, valueOps: [(Double, Op)] = [], with values: [Double], using ops: [Op]) {
	for (ai, a) in values.enumerated() {
		for (bi, b) in values.enumerated() where bi != ai {
			ops.forEach { abOp in
				for (ci, c) in values.enumerated() where ci != bi && ci != ai {
					for (di, d) in values.enumerated() where di != ci && di != bi && di != ai {
						ops.forEach { cdOp in
							ops.forEach { abcdOp in
								let rpn = RPN.rpn([a, b, abOp, c, d, cdOp, abcdOp])
								if RPN.calculate(rpn) == equal {
									print(RPN.description(rpn))
								}
							}
						}
					}
					ops.forEach { abcOp in
						for (di, d) in values.enumerated() where di != ci && di != bi && di != ai {
							ops.forEach { abcdOp in
								let rpn = RPN.rpn([a, b, abOp, c, abcOp, d, abcdOp])
								if RPN.calculate(rpn) == equal {
									print(RPN.description(rpn))
								}
							}
						}
					}
				}
			}
		}
	}
}

let values = [2.0, 3.0, 3.0, 4.0]
let answer = 24.0

find_matches(equal: answer, with: values, using: Op.allCases)



