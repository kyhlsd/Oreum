//
//  GridMapper.swift
//  Data
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation

enum GridMapper {
    
    static func toGrid(longitude: Double, latitude: Double) -> (x: Int, y: Int) {
        let RE: Double = 6371.00877
        let GRID: Double = 5.0
        let SLAT1: Double = 30.0
        let SLAT2: Double = 60.0
        let OLON: Double = 126.0
        let OLAT: Double = 38.0
        let XO: Double = 43
        let YO: Double = 136
        let DEGRAD = Double.pi / 180.0
        
        let re = RE / GRID
        let slat1 = SLAT1 * DEGRAD
        let slat2 = SLAT2 * DEGRAD
        let olon = OLON * DEGRAD
        let olat = OLAT * DEGRAD
        
        var sn = tan(.pi * 0.25 + slat2 * 0.5) / tan(.pi * 0.25 + slat1 * 0.5)
        sn = log(cos(slat1) / cos(slat2)) / log(sn)
        var sf = tan(.pi * 0.25 + slat1 * 0.5)
        sf = pow(sf, sn) * cos(slat1) / sn
        var ro = tan(.pi * 0.25 + olat * 0.5)
        ro = re * sf / pow(ro, sn)
        
        var ra = tan(.pi * 0.25 + latitude * DEGRAD * 0.5)
        ra = re * sf / pow(ra, sn)
        var theta = longitude * DEGRAD - olon
        if theta > .pi { theta -= 2.0 * .pi }
        if theta < -.pi { theta += 2.0 * .pi }
        theta *= sn
        
        let x = Int(floor(ra * sin(theta) + XO + 0.5))
        let y = Int(floor(ro - ra * cos(theta) + YO + 0.5))
        return (x, y)
    }
    
}
