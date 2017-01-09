//
//  CwlRandom.swift
//  CwlUtils
//
//  Created by Matt Gallagher on 2016/05/17.
//  Copyright © 2016 Matt Gallagher ( http://cocoawithlove.com ). All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import Foundation

public protocol RandomGenerator {
    init()

    /// Initializes the provided buffer with randomness
    mutating func randomize(buffer: UnsafeMutableRawPointer, size: Int)

    // Generates 64 bits of randomness
    mutating func random64() -> UInt64

    // Generates 32 bits of randomness
    mutating func random32() -> UInt32

    // Generates a uniform distribution with a maximum value no more than `max`
    mutating func random64(max: UInt64) -> UInt64

    // Generates a uniform distribution with a maximum value no more than `max`
    mutating func random32(max: UInt32) -> UInt32

    /// Generates a double with a random 52 bit significand on the half open range [0, 1)
    mutating func randomHalfOpen() -> Double

    /// Generates a double with a random 52 bit significand on the closed range [0, 1]
    mutating func randomClosed() -> Double

    /// Generates a double with a random 51 bit significand on the open range (0, 1)
    mutating func randomOpen() -> Double
}

public extension RandomGenerator {
    mutating func random64() -> UInt64 {
        var bits: UInt64 = 0
        randomize(buffer: &bits, size: MemoryLayout<UInt64>.size)
        return bits
    }

    mutating func random32() -> UInt32 {
        var bits: UInt32 = 0
        randomize(buffer: &bits, size: MemoryLayout<UInt32>.size)
        return bits
    }

    mutating func random64(max: UInt64) -> UInt64 {
        switch max {
        case UInt64.max: return random64()
        case 0: return 0
        default:
            var result: UInt64
            repeat {
                result = random64()
            } while result < UInt64.max % (max + 1)
            return result % (max + 1)
        }
    }

    mutating func random32(max: UInt32) -> UInt32 {
        switch max {
        case UInt32.max: return random32()
        case 0: return 0
        default:
            var result: UInt32
            repeat {
                result = random32()
            } while result < UInt32.max % (max + 1)
            return result % (max + 1)
        }
    }

    mutating func randomHalfOpen() -> Double {
        return halfOpenDoubleFrom64(bits: random64())
    }

    mutating func randomClosed() -> Double {
        return closedDoubleFrom64(bits: random64())
    }

    mutating func randomOpen() -> Double {
        return openDoubleFrom64(bits: random64())
    }
}

public func halfOpenDoubleFrom64(bits: UInt64) -> Double {
    return Double(bits & 0x001f_ffff_ffff_ffff) * (1.0 / 9007199254740992.0)
}

public func closedDoubleFrom64(bits: UInt64) -> Double {
    return Double(bits & 0x001f_ffff_ffff_ffff) * (1.0 / 9007199254740991.0)
}

public func openDoubleFrom64(bits: UInt64) -> Double {
    return (Double(bits & 0x000f_ffff_ffff_ffff) + 0.5) * (1.0 / 9007199254740991.0)
}

public protocol RandomWordGenerator: RandomGenerator {
    associatedtype WordType
    mutating func randomWord() -> WordType
}

extension RandomWordGenerator {
    public mutating func randomize(buffer: UnsafeMutableRawPointer, size: Int) {
        let b = buffer.assumingMemoryBound(to: WordType.self)
        for i in 0..<(size / MemoryLayout<WordType>.size) {
            b[i] = randomWord()
        }
        let remainder = size % MemoryLayout<WordType>.size
        if remainder > 0 {
            var final = randomWord()
            let b2 = buffer.assumingMemoryBound(to: UInt8.self)
            withUnsafePointer(to: &final) { (fin: UnsafePointer<WordType>) in
                fin.withMemoryRebound(to: UInt8.self, capacity: remainder) { f in
                    for i in 0..<remainder {
                        b2[size - i - 1] = f[i]
                    }
                }
            }
        }
    }
}

public struct DevRandom: RandomGenerator {
    class FileDescriptor {
        let value: CInt
        init() {
            value = open("/dev/urandom", O_RDONLY)
            precondition(value >= 0)
        }
        deinit {
            close(value)
        }
    }

    let fd: FileDescriptor
    public init() {
        fd = FileDescriptor()
    }

    public mutating func randomize(buffer: UnsafeMutableRawPointer, size: Int) {
        let result = read(fd.value, buffer, size)
        precondition(result == size)
    }

    public static func random64() -> UInt64 {
        var r = DevRandom()
        return r.random64()
    }

    public static func randomize(buffer: UnsafeMutableRawPointer, size: Int) {
        var r = DevRandom()
        r.randomize(buffer: buffer, size: size)
    }
}

public struct Arc4Random: RandomGenerator {
    public init() {
    }

    public mutating func randomize(buffer: UnsafeMutableRawPointer, size: Int) {
        arc4random_buf(buffer, size)
    }

    public mutating func random64() -> UInt64 {
        // Generating 2x32-bit appears to be faster than using arc4random_buf on a 64-bit value
        var value: UInt64 = 0
        arc4random_buf(&value, MemoryLayout<UInt64>.size)
        return value
    }

    public mutating func random32() -> UInt32 {
        return arc4random()
    }
}

public struct Lfsr258: RandomWordGenerator {
    public typealias WordType = UInt64
    public typealias StateType = (UInt64, UInt64, UInt64, UInt64, UInt64)

    static let k: (UInt64, UInt64, UInt64, UInt64, UInt64) = (1, 9, 12, 17, 23)
    static let q: (UInt64, UInt64, UInt64, UInt64, UInt64) = (1, 24, 3, 5, 3)
    static let s: (UInt64, UInt64, UInt64, UInt64, UInt64) = (10, 5, 29, 23, 8)

    var state: StateType = (0, 0, 0, 0, 0)

    public init() {
        var r = DevRandom()
        repeat {
            r.randomize(buffer: &state.0, size: MemoryLayout<UInt64>.size)
        } while state.0 < Lfsr258.k.0
        repeat {
            r.randomize(buffer: &state.1, size: MemoryLayout<UInt64>.size)
        } while state.1 < Lfsr258.k.1
        repeat {
            r.randomize(buffer: &state.2, size: MemoryLayout<UInt64>.size)
        } while state.2 < Lfsr258.k.2
        repeat {
            r.randomize(buffer: &state.3, size: MemoryLayout<UInt64>.size)
        } while state.3 < Lfsr258.k.3
        repeat {
            r.randomize(buffer: &state.4, size: MemoryLayout<UInt64>.size)
        } while state.4 < Lfsr258.k.4
    }

    public init(seed: StateType) {
        self.state = seed
    }

    public mutating func randomWord() -> UInt64 {
        return random64()
    }

    public mutating func random64() -> UInt64 {
        // Constants from "Tables of Maximally-Equidistributed Combined LFSR Generators" by Pierre L'Ecuyer:
        // http://www.iro.umontreal.ca/~lecuyer/myftp/papers/tausme2.ps
        let l: UInt64 = 64
        let x0 = (((state.0 << Lfsr258.q.0) ^ state.0) >> (l - Lfsr258.k.0 - Lfsr258.s.0))
        state.0 = ((state.0 & (UInt64.max << Lfsr258.k.0)) << Lfsr258.s.0) | x0
        let x1 = (((state.1 << Lfsr258.q.1) ^ state.1) >> (l - Lfsr258.k.1 - Lfsr258.s.1))
        state.1 = ((state.1 & (UInt64.max << Lfsr258.k.1)) << Lfsr258.s.1) | x1
        let x2 = (((state.2 << Lfsr258.q.2) ^ state.2) >> (l - Lfsr258.k.2 - Lfsr258.s.2))
        state.2 = ((state.2 & (UInt64.max << Lfsr258.k.2)) << Lfsr258.s.2) | x2
        let x3 = (((state.3 << Lfsr258.q.3) ^ state.3) >> (l - Lfsr258.k.3 - Lfsr258.s.3))
        state.3 = ((state.3 & (UInt64.max << Lfsr258.k.3)) << Lfsr258.s.3) | x3
        let x4 = (((state.4 << Lfsr258.q.4) ^ state.4) >> (l - Lfsr258.k.4 - Lfsr258.s.4))
        state.4 = ((state.4 & (UInt64.max << Lfsr258.k.4)) << Lfsr258.s.4) | x4
        return (state.0 ^ state.1 ^ state.2 ^ state.3 ^ state.4)
    }
}

public struct Lfsr176: RandomWordGenerator {
    public typealias WordType = UInt64
    public typealias StateType = (UInt64, UInt64, UInt64)

    static let k: (UInt64, UInt64, UInt64) = (1, 6, 9)
    static let q: (UInt64, UInt64, UInt64) = (5, 19, 24)
    static let s: (UInt64, UInt64, UInt64) = (24, 13, 17)

    var state: StateType = (0, 0, 0)

    public init() {
        var r = DevRandom()
        repeat {
            r.randomize(buffer: &state.0, size: MemoryLayout<UInt64>.size)
        } while state.0 < Lfsr176.k.0
        repeat {
            r.randomize(buffer: &state.1, size: MemoryLayout<UInt64>.size)
        } while state.1 < Lfsr176.k.1
        repeat {
            r.randomize(buffer: &state.2, size: MemoryLayout<UInt64>.size)
        } while state.2 < Lfsr176.k.2
    }

    public init(seed: StateType) {
        self.state = seed
    }

    public mutating func random64() -> UInt64 {
        return randomWord()
    }

    public mutating func randomWord() -> UInt64 {
        // Constants from "Tables of Maximally-Equidistributed Combined LFSR Generators" by Pierre L'Ecuyer:
        // http://www.iro.umontreal.ca/~lecuyer/myftp/papers/tausme2.ps
        let l: UInt64 = 64
        let x0 = (((state.0 << Lfsr176.q.0) ^ state.0) >> (l - Lfsr176.k.0 - Lfsr176.s.0))
        state.0 = ((state.0 & (UInt64.max << Lfsr176.k.0)) << Lfsr176.s.0) | x0
        let x1 = (((state.1 << Lfsr176.q.1) ^ state.1) >> (l - Lfsr176.k.1 - Lfsr176.s.1))
        state.1 = ((state.1 & (UInt64.max << Lfsr176.k.1)) << Lfsr176.s.1) | x1
        let x2 = (((state.2 << Lfsr176.q.2) ^ state.2) >> (l - Lfsr176.k.2 - Lfsr176.s.2))
        state.2 = ((state.2 & (UInt64.max << Lfsr176.k.2)) << Lfsr176.s.2) | x2
        return (state.0 ^ state.1 ^ state.2)
    }
}

public struct Xoroshiro: RandomWordGenerator {
    public typealias WordType = UInt64
    public typealias StateType = (UInt64, UInt64)

    var state: StateType = (0, 0)

    public init() {
        DevRandom.randomize(buffer: &state, size: MemoryLayout<StateType>.size)
    }

    public init(seed: StateType) {
        self.state = seed
    }

    public mutating func random64() -> UInt64 {
        return randomWord()
    }

    public mutating func randomWord() -> UInt64 {
        // Directly inspired by public domain implementation here:
        // http://xoroshiro.di.unimi.it
        // by David Blackman and Sebastiano Vigna
        let (l, k0, k1, k2): (UInt64, UInt64, UInt64, UInt64) = (64, 55, 14, 36)

        let result = state.0 &+ state.1
        let x = state.0 ^ state.1
        state.0 = ((state.0 << k0) | (state.0 >> (l - k0))) ^ x ^ (x << k1)
        state.1 = (x << k2) | (x >> (l - k2))
        return result
    }
}

public struct ConstantNonRandom: RandomWordGenerator {
    public typealias WordType = UInt64
    var state: UInt64 = DevRandom.random64()

    public init() {
    }

    public init(seed: UInt64) {
        self.state = seed
    }

    public mutating func random64() -> UInt64 {
        return randomWord()
    }

    public mutating func randomWord() -> UInt64 {
        return state
    }
}

public struct MersenneTwister: RandomWordGenerator {
    public typealias WordType = UInt64

    // 312 is 13 x 6 x 4
    private var state_internal: (
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,

        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,

        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,

        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64
        ) = (
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    )
    private var index: Int
    private static let stateCount: Int = 312

    public init() {
        self.init(seed: DevRandom.random64())
    }

    public init(seed: UInt64) {
        index = MersenneTwister.stateCount
        withUnsafeMutablePointer(to: &state_internal) { $0.withMemoryRebound(to: UInt64.self, capacity: MersenneTwister.stateCount) { state in
            state[0] = seed
            for i in 1..<MersenneTwister.stateCount {
                state[i] = 6364136223846793005 &* (state[i &- 1] ^ (state[i &- 1] >> 62)) &+ UInt64(i)
            }
            } }
    }
    
    public mutating func randomWord() -> UInt64 {
        return random64()
    }
    
    private mutating func twist() {
    }
    
    public mutating func random64() -> UInt64 {
        if index == MersenneTwister.stateCount {
            // Really dirty leaking of unsafe pointer outside its closure to ensure inlining in Swift 3 preview 1
            let state = withUnsafeMutablePointer(to: &state_internal) { $0.withMemoryRebound(to: UInt64.self, capacity: MersenneTwister.stateCount) { $0 } }
            
            let n = MersenneTwister.stateCount
            let m = n / 2
            let a: UInt64 = 0xB5026F5AA96619E9
            let lowerMask: UInt64 = (1 << 31) - 1
            let upperMask: UInt64 = ~lowerMask
            var (i, j, stateM) = (0, m, state[m])
            repeat {
                let x1 = (state[i] & upperMask) | (state[i &+ 1] & lowerMask)
                state[i] = state[i &+ m] ^ (x1 >> 1) ^ ((state[i &+ 1] & 1) &* a)
                let x2 = (state[j] & upperMask) | (state[j &+ 1] & lowerMask)
                state[j] = state[j &- m] ^ (x2 >> 1) ^ ((state[j &+ 1] & 1) &* a)
                (i, j) = (i &+ 1, j &+ 1)
            } while i != m &- 1
            
            let x3 = (state[m &- 1] & upperMask) | (stateM & lowerMask)
            state[m &- 1] = state[n &- 1] ^ (x3 >> 1) ^ ((stateM & 1) &* a)
            let x4 = (state[n &- 1] & upperMask) | (state[0] & lowerMask)
            state[n &- 1] = state[m &- 1] ^ (x4 >> 1) ^ ((state[0] & 1) &* a)
            
            index = 0
        }
        
        var result = withUnsafePointer(to: &state_internal) { $0.withMemoryRebound(to: UInt64.self, capacity: MersenneTwister.stateCount) { ptr in
            return ptr[index]
            } }
        index = index &+ 1
        
        result ^= (result >> 29) & 0x5555555555555555
        result ^= (result << 17) & 0x71D67FFFEDA60000
        result ^= (result << 37) & 0xFFF7EEE000000000
        result ^= result >> 43
        
        return result
    }
}
