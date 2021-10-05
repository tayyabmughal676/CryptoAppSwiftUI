//
//  HomeViewModel.swift
//  CryptoApp
//
//  Created by Thor on 20/08/2021.
//

import Foundation
import Combine


class HomeViewModel: ObservableObject{
    
    @Published var statistics: [StatisticModel] = []
    
    @Published var allCoins :[CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    @Published var searchText: String = ""
    
    //    @Published var statistics: [StatisticModel] = [
    //        StatisticModel(title: "Title 1", value: "Value 1", percentageChange: 1),
    //        StatisticModel(title: "Title 2", value: "Value 2"),
    //        StatisticModel(title: "Title 3", value: "Value 3"),
    //        StatisticModel(title: "Title 4", value: "Value 4", percentageChange: -7.0)
    //    ]
    
    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers(){
        //        Without Search
        //        dataService.$allCoins
        //            .sink { [weak self] (returnedCoins) in
        //                self?.allCoins = returnedCoins
        //            }
        //            .store(in: &cancellables)
        
        //        With Search
        $searchText
            .combineLatest(coinDataService.$allCoins)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterCoins)
            .sink { [weak self] (returnedCoins) in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
        print("Coin Data: \(coinDataService.$allCoins)")
        
//        Updates market Data
        marketDataService.$marketData
            .map(mapGlobalMarketData)
            .sink { [weak self] (returnedStats) in
                self?.statistics = returnedStats
            }
            .store(in: &cancellables)
    }
    
    private func filterCoins(text: String, coins: [CoinModel]) -> [CoinModel]{
        guard !text.isEmpty else{
            return coins
        }
        
        let lowercasedText = text.lowercased()
        
        return coins.filter { (coin) -> Bool in
            return coin.name.lowercased().contains(lowercasedText) ||
            coin.symbol.lowercased().contains(lowercasedText) ||
            coin.id.lowercased().contains(lowercasedText)
        }
    }
    
    private func mapGlobalMarketData(marketDataModel: MarketDataModel?) -> [StatisticModel]{
        
        var stats: [StatisticModel] = []
        guard let data = marketDataModel else{
            return stats
        }
        
        let marketCap = StatisticModel(
            title: "Market Cap",
            value: data.marketCap,
            percentageChange: data.marketCapChangePercentage24HUsd)
        
        let volume = StatisticModel(
            title: "24h Volume",
            value: data.volume)
        
        let btcDominace = StatisticModel(
            title: "BTC Dominance",
            value: data.btcDominance)
        
        let portfolio = StatisticModel(
            title: "Portfolio Value",
            value: "$0.00",
            percentageChange: 0)
        
        stats.append(contentsOf: [
            marketCap,
            volume,
            btcDominace,
            portfolio
        ])
        
        return stats
        
    }
    
    
    //    .map { (text, startingCoins) -> [CoinModel] in
    //
    //        guard !text.isEmpty else{
    //            return startingCoins
    //        }
    //
    //        let lowercasedText = text.lowercased()
    //
    //        return startingCoins.filter { (coin) -> Bool in
    //            return coin.name.lowercased().contains(lowercasedText) ||       coin.symbol.lowercased().contains(lowercasedText) ||
    //                coin.id.lowercased().contains(lowercasedText)
    //        }
    //
    //    }
}
