// https://fivethirtyeight.com/features/can-you-make-24/

import Foundation

enum Op {
	case add
	case subtract
	case multiply
	case divide
	case exponentiation
	case nop

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
		case .nop:
			fatalError()
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
		case .nop:
			fatalError()
		}
	}
}

indirect
enum Calc {
	case op(Calc, Op, Calc)
	case x(Double)

	var value: Double {
		switch self {
		case let .op(a, op, b):
			return op.perform(a.value, b.value)
		case let .x(x):
			return x
		}
	}

	var description: String {
		switch self {
		case let .op(a, op, b):
			return "(\(a.description) \(op.description) \(b.description))"
		case let .x(x):
			return "\(x)"
		}
	}

	func output() {
		print("\(description) = \(value)")
	}

	static func calculation(from ops: [(Double, Op)]) -> Calc {
		if ops.count == 1 {
			return .x(ops[0].0)
		} else {
			let value = ops[0].0
			let op = ops[0].1
			return .op(.x(value), op, calculation(from: Array(ops.dropFirst())))
		}
	}
}


func find_matches(equal: Double, valueOps: [(Double, Op)] = [], with values: [Double], using ops: [Op], maxDepth: Int) {
	if valueOps.count == maxDepth {
		values.forEach { value in
			let calc = Calc.calculation(from: valueOps + [(value, .nop)])
			if calc.value == equal {
				calc.output()
			}
		}
	} else {
		for(i, value) in values.enumerated() {
			var array = values
			array.remove(at: i)
			ops.forEach { op in
				find_matches(equal: equal, valueOps: valueOps + [(value, op)], with: array, using: ops, maxDepth: maxDepth)
			}
		}
	}
}

// I couldn't think of a general algorithm to handle this case offhand (a op b) op (b op c) and can't spend any more time on this so I just special case it with this sloppy inelegant code
func find_grouped_matches(equal: Double, with values: [Double], using ops: [Op], maxDepth: Int) {
	for (ai, a) in values.enumerated() {
		for (bi, b) in values.enumerated() {
			if ai == bi { continue }
			ops.forEach { abOp in
				ops.forEach { abcdOp in
					for (ci, c) in values.enumerated() {
						if ci == ai || ci == bi { continue }
						for (di, d) in values.enumerated() {
							if di == ai || di == bi || di == ci { continue }
							ops.forEach { cdOp in
								let calc: Calc = .op(
									.op(.x(a), abOp, .x(b)),
									abcdOp,
									.op(.x(c), cdOp, .x(d))
								)
								if calc.value == equal {
									calc.output()
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
let value = 24.0

find_matches(equal: 24, with: values, using: Op.all, maxDepth: 3)
find_grouped_matches(equal: 24, with: values, using: Op.all, maxDepth: 3)



