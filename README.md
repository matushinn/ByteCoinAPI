# ByteCoinAPI
SwiftでBytecoinAPIを使ってビットコインアプリを作ってみたいと思います。
初心者にもわかりやすく、AutoLayoutの設定、デザインパターン、コードの可読性もしっかり守っているので、APIの入門記事としてはぴったりかなと。
では始めていきます。ぜひ最後までご覧ください。

## UIの設計

このように配置していきます。

![haitiBytecoin.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/962a7524-7542-da7b-8dcf-fb3863f0b09a.png)

制約をつけていきます。


![スクリーンショット 2021-09-01 16.20.01.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/9cdd9ff1-e718-dcc5-90f1-8ad422cfb303.png)


WeatherViewControllerを作り、IBOutlet,IBAction接続します。


![スクリーンショット 2021-09-01 16.28.21.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/1ea6b5b4-78f3-39c7-d1ec-6f43c3d639d3.png)

```swift:ViewController.swift
class ViewController: UIViewController{

    @IBOutlet weak var bitcoinLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    
}
```

## 全体設計
UIができた後に、今回のアプリの設計を行なっていく。
![スクリーンショット 2021-09-01 16.36.05.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/87d8a288-5a9d-a5fd-2cb4-18066ced3d1e.png)


![スクリーンショット 2021-09-01 16.37.40.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/295b9843-5ee3-3682-2e88-a92badcdbfaf.png)

## APIの取得
まず、APIの取得からやっていきたいと思います。
[CoinAPI.io](https://www.coinapi.io/)を使います。
操作は以下。

![スクリーンショット 2021-09-01 16.53.38.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/0048d3fe-8cb1-c38b-0753-eaa4ebc36465.png)

![スクリーンショット 2021-09-01 16.55.10.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/6b87f771-aa93-00f9-8be6-ec59bf21a447.png)

メールに自分のAPIKeyが送られます。

![スクリーンショット 2021-09-01 17.01.42.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/33584a30-d071-5f84-cf4c-01e557468896.png)

そしてこのようにAPIを叩くと、JSONデータを変換してくれます。
![スクリーンショット 2021-09-01 17.06.42.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/1c8f60cb-487e-490b-7d1a-56166d593016.png)
これらのデータをうまく使い今回はアプリを作成していきます。


## CoinManager
今回のAPIにおいてのロジックを管理するCoinrManagerを書いていきます。

```swift:CoinManager.swift
import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoin(_ coinManager:CoinManager,coin:CoinModel)
    func didFailWithError(error:Error)
}
struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    //APIKeyを入れる
    let apiKey = "[APIKey]"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate:CoinManagerDelegate?
    
    func getCoinPrice(for currency:String){
        //API取得
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        // print(urlString)
        
        self.performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        //①URLを作る
        if let url = URL(string: urlString){
            //②URLSessionを作る
            let session = URLSession(configuration: .default)
            
            //③SessionTaskを与える
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    // print(error!)
                    self.delegate?.didFailWithError(error: error!)
                    return
                }              
                
                if let safeData = data {
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//途中でプリントで値を確認しながら進めると良い
                 //let dataString = String(data:safeData,encoding:.utf8)
                    // print(dataString)
                    if let coin = self.parseJSON(safeData){
                        self.delegate?.didUpdateCoin(self, coin: coin)                        
                    } 
                }
            }
            //④タスクを始める
            task.resume()
        }
        
    }
    func parseJSON(_ coinData:Data) -> CoinModel?{
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            
            let rate = decodedData.rate
            let currency = decodedData.asset_id_quote
            
            print(rate)
            
            let coin = CoinModel(rate: rate, currencyName:currency)
            
            return coin
            
        } catch  {
            delegate?.didFailWithError(error: error)
            
            return nil
        }
    }
}


```

## CoinModel
データをアプリが使いやすいような形に変換するためのCoinModelを作成していきます。

```swift:CoinModel.swift
import Foundation

struct CoinModel {
    let rate:Double
    let currencyName:String
    
    var rateString:String{
        return String(format: "%.2f", rate)
    }
}
```

## CoinData
レスポンスしたデータをデコードするためCoinDataを作ります。

```swift:CoinData.swift
import Foundation

struct CoinData:Codable {
    let rate:Double
    let asset_id_quote:String
}
```

## ViewController
最後に取得したデータをViewに反映させる、またPickerViewの操作のためにViewControllerを作っていきます。

```swift:ViewController
import UIKit

class ViewController: UIViewController{
    
    @IBOutlet weak var bitcoinLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    
    var coinManager = CoinManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        coinManager.delegate = self
    }
}

//MARK: - UIPickerViewDelegate,UIPickerViewDataSource
extension ViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return coinManager.currencyArray.count
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coinManager.currencyArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCurrency = coinManager.currencyArray[row]
        coinManager.getCoinPrice(for: selectedCurrency) 
    }
}

//MARK: - CoinManagerDelegate
extension ViewController:CoinManagerDelegate{
    func didUpdateCoin(_ coinManager: CoinManager, coin: CoinModel) {
        DispatchQueue.main.async {
            self.bitcoinLabel.text = coin.rateString
            self.currencyLabel.text = coin.currencyName
        }
    }
    func didFailWithError(error: Error) {
        print(error)
    }
}

```
UIPickerViewの処理は[UIPickerView](https://developer.apple.com/documentation/uikit/uipickerview)のドキュメントを確認しながら学んでください。

## 終わりに
以上でこのようなアプリが作成できました。
![Animated GIF-downsized.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/ac9b72b9-53e0-9441-2294-c4e2a313a08f.gif)

指摘点がありましたら、コメントでもよろしくお願いします。




