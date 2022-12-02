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
        var largestIndexValue: (Int, Int) = (-1, -1)
        _ = input
            .split(separator: "\n", omittingEmptySubsequences: false)
            .reduce(into: [0]) { partialResult, calories in
                guard !calories.isEmpty else {
                    let elfTotal = partialResult[partialResult.count - 1]
                    if elfTotal > largestIndexValue.1 {
                        largestIndexValue = (partialResult.count - 1, elfTotal)
                    }
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
​
        return largestIndexValue.1
    }
​
    func part2(_ input: String) -> CustomStringConvertible {
        let topThreeElfCalories = input
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
​
        return topThreeElfCalories
    }
}
