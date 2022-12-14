//
//  Day4.swift
//  AdventOfCode
//

import Foundation

final class Day4: Day {
    func part1(_ input: String) -> CustomStringConvertible {
        return input
            .split(separator: "\n")
            .reduce(0) { partialResult, line in
                let pairs = line.split(separator: ",")
                let firstNums = setFromRange(String(pairs[0]))
                let secondNums = setFromRange(String(pairs[1]))
                if firstNums.isSubset(of: secondNums) || firstNums.isSuperset(of: secondNums) {
                    return partialResult + 1
                }
                return partialResult
            }
    }

    func part2(_ input: String) -> CustomStringConvertible {
        return input
            .split(separator: "\n")
            .reduce(0) { partialResult, line in
                let pairs = line.split(separator: ",")
                let firstNums = setFromRange(String(pairs[0]))
                let secondNums = setFromRange(String(pairs[1]))
                if !firstNums.isDisjoint(with: secondNums) {
                    return partialResult + 1
                }
                return partialResult
            }
    }
    
    private func setFromRange(_ input: String) -> Set<Int> {
        let startAndEnd = input
            .split(separator: "-")
            .compactMap { Int.init($0) }
        return Set<Int>(startAndEnd[0]...startAndEnd[1])
    }
}
