//
//  Day15.swift
//  AdventOfCode
//

import Foundation
import Metal

var minX = Int.max
var minY = Int.max
var maxX = Int.min
var maxY = Int.min

final class Day15: Day {
    func part1(_ input: String) -> CustomStringConvertible {
        let validSensorsForRow = sensorsFromInput(input)
            .filter { abs($0.sensorY - 2000000) <= $0.distance }
        
        return (0...(maxX - minX + 1))
            .compactMap { col in
                let colOffset = col + minX
                return validSensorsForRow.first { $0.excludesBeaconAt(x: colOffset, y: 2000000) }
            }
            .count
        
        // Almost double the time, too much time spent waiting for the semaphore and other locks aren't faster
        //        var result = 0
        //        let semaphore = DispatchSemaphore(value: 1)
        //        DispatchQueue.concurrentPerform(iterations: maxX - minX + 1) { col in
        //            let colOffset = col + minX
        //            if validSensorsForRow.first(where: { $0.excludesBeaconAt(x: colOffset, y: 2000000) }) != nil {
        //                semaphore.wait()
        //                result += 1
        //                semaphore.signal()
        //            }
        //        }
        //
        //        return result
    }
    
    // Chaos lies within
    func part2(_ input: String) -> CustomStringConvertible {
        let sensors = sensorsFromInput(input)
        let definedMinimum = 0
        let definedMaximum = 4_000_000
        
        var foundX = Int.min
        var foundY = Int.min
        
        let device = MTLCreateSystemDefaultDevice()
        let library = device?.makeDefaultLibrary()
        let gpufunc = library?.makeFunction(name: "distances")
        let pso = try? device?.makeComputePipelineState(function: gpufunc!)
        let commandQueue = device?.makeCommandQueue()
        let maxThreads = pso!.maxTotalThreadsPerThreadgroup
        
        var tenThousandDate = Date()
        
        // maxThreads isn't really relevant here because I iterate by column, but I tested 1, 100, 200, 500, 1000, and 10000
        // and 1000 was the fastest so I figured I'd use the pre-existing variable that's 1024 on my machine 😅
        for row in stride(from: definedMinimum, to: min(maxY, definedMaximum), by: maxThreads) {
            if foundX != Int.min {
                break
            }
            
            autoreleasepool {
                if (row % (maxThreads * 10) == 0) {
                    print("row \(row) start, last 10240 time = \(-tenThousandDate.timeIntervalSinceNow * 1000) ms")
                    tenThousandDate = Date()
                }
                
                let commandBuffer = commandQueue?.makeCommandBuffer()
                let computeEncoder = commandBuffer?.makeComputeCommandEncoder()
                computeEncoder?.setComputePipelineState(pso!)
                
                var validSensorsForRowGroup: Set<Sensor> = []
                (row...(row + maxThreads - 1)).forEach { individualRow in
                    sensors
                        .filter { abs($0.sensorY - individualRow) <= $0.distance }
                        .forEach { validSensorsForRowGroup.insert($0) }
                }
                var sensorXs: [Int] = []
                var sensorYs: [Int] = []
                var sensorDistances: [Int] = []
                validSensorsForRowGroup
                    .forEach { sensor in
                        sensorXs.append(sensor.sensorX)
                        sensorYs.append(sensor.sensorY)
                        sensorDistances.append(sensor.distance)
                    }

                let rowEnd = row + maxThreads - 1
                let arraySize = MemoryLayout<Int>.stride * validSensorsForRowGroup.count
                
                let numPointer = withUnsafePointer(to: validSensorsForRowGroup.count) { pointer in
                    return UnsafeRawPointer(pointer)
                }
                let rowPointer = withUnsafePointer(to: row) { pointer in
                    return UnsafeRawPointer(pointer)
                }
                let rowEndPointer = withUnsafePointer(to: rowEnd) { pointer in
                    return UnsafeRawPointer(pointer)
                }
                // Even though these two go in via a buffer, they are not updated at the end and the buffer needs to be queried for their data
                let resultXPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
                resultXPointer.pointee = Int.min
                let resultYPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
                resultYPointer.pointee = Int.min
                let resultXBuffer = device?.makeBuffer(bytes: UnsafeRawPointer(resultXPointer), length: MemoryLayout<Int>.stride, options: .storageModeShared)
                let resultYBuffer = device?.makeBuffer(bytes: UnsafeRawPointer(resultYPointer), length: MemoryLayout<Int>.stride, options: .storageModeShared)
                
                computeEncoder?.setBytes(sensorXs, length: arraySize, index: 0)
                computeEncoder?.setBytes(sensorYs, length: arraySize, index: 1)
                computeEncoder?.setBytes(sensorDistances, length: arraySize, index: 2)
                computeEncoder?.setBytes(numPointer, length: MemoryLayout<Int>.stride, index: 3)
                computeEncoder?.setBytes(rowPointer, length: MemoryLayout<Int>.stride, index: 4)
                computeEncoder?.setBytes(rowEndPointer, length: MemoryLayout<Int>.stride, index: 5)
                computeEncoder?.setBuffer(resultXBuffer, offset: 0, index: 6)
                computeEncoder?.setBuffer(resultYBuffer, offset: 0, index: 7)
                
                let size = MTLSize(width: definedMaximum, height: 1, depth: 1)
                let threadgroupSize = MTLSize(width: min(definedMaximum, maxThreads), height: 1, depth: 1)
                computeEncoder?.dispatchThreads(size, threadsPerThreadgroup: threadgroupSize)
                computeEncoder?.endEncoding()
                commandBuffer?.commit()
                commandBuffer?.waitUntilCompleted()
                
                let resultXAvailable = resultXBuffer!.contents().load(as: Int.self)
                let resultYAvailable = resultYBuffer!.contents().load(as: Int.self)
                if resultXAvailable != Int.min {
                    foundX = resultXAvailable
                    foundY = resultYAvailable
                }
            }
        }
        return foundX * 4000000 + foundY
    }
    
    func sensorsFromInput(_ input: String) -> [Sensor] {
        return input
            .split(separator: "\n")
            .map { line in
                Sensor(arrayPair: line
                    .split(separator: ":")
                    .map { segment in
                        segment
                            .split(separator: "=")
                            .compactMap { chunk in
                                var modifiedDecimalSet = CharacterSet.decimalDigits
                                modifiedDecimalSet.insert("-")
                                let trimmedChunk = chunk.trimmingCharacters(in: modifiedDecimalSet.inverted)
                                return trimmedChunk.isEmpty ? nil : Int(trimmedChunk)
                            }
                    }
               )
            }
    }
}

class Sensor: Hashable, CustomStringConvertible {
    let sensorX: Int
    let sensorY: Int
    let beaconX: Int
    let beaconY: Int
    
    lazy var distance: Int = {
        distanceBetween(x1: sensorX, y1: sensorY, x2: beaconX, y2: beaconY)
    }()
    
    init(arrayPair: [[Int]]) {
        self.sensorX = arrayPair[0][0]
        self.sensorY = arrayPair[0][1]
        self.beaconX = arrayPair[1][0]
        self.beaconY = arrayPair[1][1]
        
        // Contribute to computation of the global maximum addressible grid size, as exposed by the sensor's computed distances
        minX = min(minX, self.sensorX, self.beaconX, self.sensorX - self.distance)
        minY = min(minY, self.sensorY, self.beaconY, self.sensorY - self.distance)
        maxX = max(maxX, self.sensorX, self.beaconX, self.sensorX + self.distance)
        maxY = max(maxY, self.sensorY, self.beaconY, self.sensorY + self.distance)
    }
    
    func distanceBetween(x1: Int, y1: Int, x2: Int, y2: Int) -> Int {
        abs(x1 - x2) + abs(y1 - y2)
    }
    
    func excludesBeaconAt(x: Int, y: Int) -> Bool {
        return distanceBetween(x1: sensorX, y1: sensorY, x2: x, y2: y) <= distance && (x, y) != (beaconX, beaconY)
    }
    
    // MARK: Hashable
    
    static func == (lhs: Sensor, rhs: Sensor) -> Bool {
        return lhs.sensorX == rhs.sensorX &&
            lhs.sensorY == rhs.sensorY &&
            lhs.beaconX == rhs.beaconX &&
            lhs.beaconY == rhs.beaconY
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(sensorX)
        hasher.combine(sensorY)
        hasher.combine(beaconX)
        hasher.combine(beaconY)
    }
    
    // MARK: CustomStringConvertible
    
    var description: String {
        return "SENSOR - x: \(sensorX), y: \(sensorY), CLOSEST BEACON - x: \(beaconX), y: \(beaconY), DISTANCE - \(distance)"
    }
}
