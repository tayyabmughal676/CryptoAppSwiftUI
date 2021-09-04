//
//  CoinDataService.swift
//  CryptoApp
//
//  Created by Thor on 20/08/2021.
//

import Foundation
import Combine


class CoinDataService {
    
    @Published var allCoins : [CoinModel] = []
    
    var coinSubscription: Cancellable?
    
    init(){
        getCoins()
    }
    
    private func getCoins(){
        
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h")
        else {return}
        print("URL Hit: \(url)")
        
        coinSubscription = NetworkingManager.download(url: url)
            .decode(type: [CoinModel].self , decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedCoins) in
                self?.allCoins = returnedCoins
                self?.coinSubscription?.cancel()
            })
    }
    
}
