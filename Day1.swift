//
//  Day1.swift
//  AdventOfCode
//
​
import Algorithms
import Foundation
​
final class Day1: Day {
    func part1(_ input: String) -> CustomStringConvertible {
        return input
            .split(separator: "\n", omittingEmptySubsequences: false)
            .reduce(into: [0]) { partialResult, calories in
                guard !calories.isEmpty else {
                    partialResult.append(0)
                    return
                }
​
                guard let intCalories = Int(calories) else {
                    return
                }
​
                partialResult[partialResult.count - 1] += intCalories
            }
            .max() ?? 0
    }
​
    func part2(_ input: String) -> CustomStringConvertible {
        return input
            .split(separator: "\n", omittingEmptySubsequences: false)
            .reduce(into: [0]) { partialResult, calories in
                guard !calories.isEmpty else {
                    partialResult.append(0)
                    return
                }
​
                guard let intCalories = Int(calories) else {
                    return
                }
​
                partialResult[partialResult.count - 1] += intCalories
            }
            .max(count: 3)
            .reduce(0, +)
    }
}
