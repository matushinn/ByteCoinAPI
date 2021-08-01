//
//  CoinModel.swift
//  ByteCoinAPI
//
//  Created by 大江祥太郎 on 2021/08/01.
//

import Foundation

struct CoinModel {
    let rate:Double
    let currencyName:String
    
    
    var rateString:String{
        return String(format: "%.2f", rate)
    }
    
    
}
