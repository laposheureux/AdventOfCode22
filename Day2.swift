//
//  Day2.swift
//  AdventOfCode
//

import Foundation

let lookupTable: [String: Int] = [
    "A X": 4,
    "A Y": 8,
    "A Z": 3,
    "B X": 1,
    "B Y": 5,
    "B Z": 9,
    "C X": 7,
    "C Y": 2,
    "C Z": 6
]

let lookupTablePart2: [String: Int] = [
    "A X": 3,
    "A Y": 4,
    "A Z": 8,
    "B X": 1,
    "B Y": 5,
    "B Z": 9,
    "C X": 2,
    "C Y": 6,
    "C Z": 7
]

final class Day2: Day {
    func part1(_ input: String) -> CustomStringConvertible {
        return input
            .split(separator: "\n")
            .reduce(0) { partialResult, play in
                return partialResult + lookupTable[String(play), default: 0]
            }
    }

    func part2(_ input: String) -> CustomStringConvertible {
        return input
            .split(separator: "\n")
            .reduce(0) { partialResult, play in
                return partialResult + lookupTablePart2[String(play), default: 0]
            }
    }
}
