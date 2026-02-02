//
//  PixelIcons.swift
//  Pocket Bro
//

import Foundation

struct PixelIcons {
    // Feed icon - apple/food (8x8)
    static let feed: [[Int]] = {
        var icon = [[Int]]()
        icon.append([0,0,0,1,1,0,0,0])
        icon.append([0,0,1,0,0,0,0,0])
        icon.append([0,1,1,1,1,1,1,0])
        icon.append([1,1,1,1,1,1,1,1])
        icon.append([1,1,1,1,1,1,1,1])
        icon.append([1,1,1,1,1,1,1,1])
        icon.append([0,1,1,1,1,1,1,0])
        icon.append([0,0,1,1,1,1,0,0])
        return icon
    }()

    // Work icon - laptop/briefcase (8x8)
    static let work: [[Int]] = {
        var icon = [[Int]]()
        icon.append([0,1,1,1,1,1,1,0])
        icon.append([1,1,1,1,1,1,1,1])
        icon.append([1,0,0,0,0,0,0,1])
        icon.append([1,0,1,1,1,1,0,1])
        icon.append([1,0,1,1,1,1,0,1])
        icon.append([1,0,0,0,0,0,0,1])
        icon.append([1,1,1,1,1,1,1,1])
        icon.append([0,0,1,1,1,1,0,0])
        return icon
    }()

    // Care icon - heart (8x8)
    static let care: [[Int]] = {
        var icon = [[Int]]()
        icon.append([0,1,1,0,0,1,1,0])
        icon.append([1,1,1,1,1,1,1,1])
        icon.append([1,1,1,1,1,1,1,1])
        icon.append([1,1,1,1,1,1,1,1])
        icon.append([0,1,1,1,1,1,1,0])
        icon.append([0,0,1,1,1,1,0,0])
        icon.append([0,0,0,1,1,0,0,0])
        icon.append([0,0,0,0,0,0,0,0])
        return icon
    }()

    // Social icon - person (8x8)
    static let social: [[Int]] = {
        var icon = [[Int]]()
        icon.append([0,0,1,1,1,1,0,0])
        icon.append([0,0,1,1,1,1,0,0])
        icon.append([0,0,0,1,1,0,0,0])
        icon.append([0,1,1,1,1,1,1,0])
        icon.append([1,1,1,1,1,1,1,1])
        icon.append([0,0,1,1,1,1,0,0])
        icon.append([0,0,1,0,0,1,0,0])
        icon.append([0,0,1,0,0,1,0,0])
        return icon
    }()
}
