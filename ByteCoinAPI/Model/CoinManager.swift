//
//  CoinManager.swift
//  ByteCoinAPI
//
//  Created by 大江祥太郎 on 2021/08/01.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoin(_ coinManager:CoinManager,coin:CoinModel)
    func didFailWithError(error:Error)
}
struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "1DB00698-ED83-4582-800E-37514B7BFBA9"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate:CoinManagerDelegate?
    
    func getCoinPrice(for currency:String){
        //api通信
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        // print(urlString)
        
        
        self.performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        //①Create a URL
        if let url = URL(string: urlString){
            //②Create a URL Session
            let session = URLSession(configuration: .default)
            
            //③Give the sessin Task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    // print(error!)
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                
                if let safeData = data {
                 let dataString = String(data:safeData,encoding:.utf8)
                    print(dataString)
                    if let coin = self.parseJSON(safeData){
                        self.delegate?.didUpdateCoin(self, coin: coin)
//                        let weatherVC = WeatherViewController()
//                        weatherVC.didUpdateWeather(weather: weather)
//
                    }
                    
                }
            }
            
            //④Start the task
            task.resume()
        }
        
    }
    func parseJSON(_ coinData:Data) -> CoinModel?{
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            
            let rate = decodedData.rate
            
            print(rate)
            
            let coin = CoinModel(rate: rate)
            
            return coin
            //print(weather.conditinName)
            
            
            
        } catch  {
            delegate?.didFailWithError(error: error)
            
            return nil
        }
       
        
    }
}
