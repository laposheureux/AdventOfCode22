//
//  distances.metal
//  AdventOfCode
//
//  Created by Aaron L'Heureux on 12/15/22.
//

#include <metal_stdlib>
using namespace metal;

kernel void distances(device const int64_t* inSensorX,
                      device const int64_t* inSensorY,
                      device const int64_t* inSensorDistance,
                      device const int64_t& inNumSensors,
                      device const int64_t& inRowY,
                      device const int64_t& inRowYEnd,
                      device int64_t& resultX,
                      device int64_t& resultY,
                      uint index [[thread_position_in_grid]])
{
    for (int64_t row = inRowY; row <= inRowYEnd; row++) {
        bool found = true;
        int64_t candidate;
        for (int64_t sensor = 0; sensor < inNumSensors; sensor++) {
            int xDist = inSensorX[sensor] - index;
            int yDist = inSensorY[sensor] - row;
            int distance = ((xDist >= 0) ? xDist : -xDist) + ((yDist >= 0) ? yDist : -yDist);
            if (distance > inSensorDistance[sensor]) {
                candidate = (int64_t)index;
            } else {
                found = false;
                break;
            }
        }
        if (found) {
            resultX = candidate;
            resultY = row;
            break;
        }
    }
}
