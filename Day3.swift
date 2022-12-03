//
//  Day3.swift
//  AdventOfCode
//

import Foundation

final class Day3: Day {
    func part1(_ input: String) -> CustomStringConvertible {
        return input
            .split(separator: "\n")
            .reduce(0) { partialResult, line in
                var set = Set<Character>()
                var foundValue: UInt8 = 0
                for i in (0...line.count) {
                    let substringIndex = line.index(line.startIndex, offsetBy: i)
                    let character = line[substringIndex]
                    
                    if (i < line.count / 2) {
                        set.insert(character)
                    } else {
                        if set.contains(character) {
                            foundValue = character.asciiValue! < 97 ? character.asciiValue! - 38 : character.asciiValue! - 96
                            break
                        }
                    }
                }
                return partialResult + Int(foundValue)
            }
    }

    func part2(_ input: String) -> CustomStringConvertible {
        let lines = input.split(separator: "\n")
        var foundValue: Int = 0
        var tempSet: Set<Character> = Set()
        for i in (0..<lines.count) {
            let characters = Array(String(lines[i]))
            if i % 3 == 2 {
                let badge = tempSet.intersection(characters).first!
                foundValue += badge.asciiValue! < 97 ?
                    Int(badge.asciiValue! - 38) :
                    Int(badge.asciiValue! - 96)
                tempSet = Set()
            } else if i % 3 == 1 {
                tempSet.formIntersection(characters)
            } else {
                tempSet.formUnion(characters)
            }
        }
        return Int(foundValue)
    }
}
