//
//  MarketDataService.swift
//  CryptoApp
//
//  Created by Thor on 05/10/2021.
//

import Foundation
import Combine

class MarketDataService {
    
    @Published var marketData : MarketDataModel? = nil
 
    var marketDataSubscription: AnyCancellable?
    
    init(){
        getData()
    }
    
    private func getData(){
        
        guard let url = URL(string: "https://api.coingecko.com/api/v3/global")
        else {return}
        print("URL Hit: \(url)")
        
        marketDataSubscription = NetworkingManager.download(url: url)
            .decode(type: GlobalData.self , decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedGlobalData) in
                self?.marketData = returnedGlobalData.data
                self?.marketDataSubscription?.cancel()
            })
    }
    
}
