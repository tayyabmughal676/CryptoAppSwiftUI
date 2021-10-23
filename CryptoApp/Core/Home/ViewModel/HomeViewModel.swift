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
    @Published var isLoading: Bool = false
    @Published var sortOption: sortOption = .holdings
    
    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataService()
    private let portfolioDataService = PortfolioDataService()
    private var cancellables = Set<AnyCancellable>()
    
    enum sortOption{
        case rank, rankReversed, holdings, holdingsReversed, price, priceReversed
    }
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers(){
        
        //        With Search
        $searchText
            .combineLatest(coinDataService.$allCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSortCoins)
            .sink { [weak self] (returnedCoins) in
                self?.allCoins = returnedCoins
                
            }
            .store(in: &cancellables)
        print("Coin Data: \(coinDataService.$allCoins)")
        
        //        Updates Portfolio Coins
        $allCoins
            .combineLatest(portfolioDataService.$savedEntities)
            .map(mapAllCoinsToPortfolioCoins)
            .sink { [weak self] (returnedCoins) in
                guard let self = self else{return}
//                self.portfolioCoins = self.sortPortfolioCoinsIfNeeded(coins: returnedCoins)
                self.portfolioCoins = returnedCoins
                
            }
            .store(in: &cancellables)
        
        //        Updates market Data
        marketDataService.$marketData
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .sink { [weak self] (returnedStats) in
                self?.statistics = returnedStats
                self?.isLoading = false
            }
            .store(in: &cancellables)
        
    }
    
    
    func updatePorfolio(coin: CoinModel, amount: Double){
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    func reloadData(){
        isLoading = true
        coinDataService.getCoins()
        marketDataService.getData()
        HapticManager.notification(type: .success
                                   
        )
    }
    
    private func filterAndSortCoins(text: String, coins: [CoinModel], sort: sortOption) -> [CoinModel]{
        var updatedCoins = filterCoins(text: text, coins: coins)
        sortCoins(sort: sort, coins: &updatedCoins)
        return updatedCoins
    }
    
    private func sortCoins(sort: sortOption, coins: inout [CoinModel]){
       
        switch sort {
        case .rank, .holdings:
            coins.sort(by: {$0.rank < $1.rank})
        case .rankReversed, .holdingsReversed:
            coins.sort(by: {$0.rank > $1.rank})
        case .price:
            coins.sort(by: {$0.currentPrice > $1.currentPrice})
        case .priceReversed:
            coins.sort(by: {$0.currentPrice < $1.currentPrice})
        }
    }
    
//    private func sortPortfolioCoinsIfNeeded(coins: [CoinModel]) -> [CoinModel]{
//        //        will only sort by holdings or reversedholdings if needed
//        switch sortOption {
//        case .holdings:
//            return coins.sorted(by: {$0.currentHoldingValue > $1.currentHoldingValue})
//        case .holdingsReversed:
//            return coins.sorted(by: {$0.currentHoldingValue < $1.currentHoldingValue})
//        default:
//            return coins
//        }
//    }
    
    
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
    
    private func mapAllCoinsToPortfolioCoins(allCoins: [CoinModel], portfolioEntities: [PortfolioEntity]) -> [CoinModel]{
        
        allCoins
            .compactMap { (coin) -> CoinModel? in
                guard let entity = portfolioEntities.first(where: { $0.coinID == coin.id }) else{
                    return nil
                }
                return coin.updateHoldings(amount: entity.amount)
            }
        
    }
    
    private func mapGlobalMarketData(marketDataModel: MarketDataModel?, portfolioCoins: [CoinModel]) -> [StatisticModel]{
        
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
        
        let portfolioValue =
        portfolioCoins
            .map({$0.currentHoldingValue})
            .reduce(0, +)
        
        let previousValue =
        portfolioCoins
            .map{(coin) -> Double in
                let currentValue = coin.currentHoldingValue
                let percentChange = coin.priceChangePercentage24H ?? 0/100
                let previousValue = currentValue / (1 + percentChange)
                return previousValue
            }
            .reduce(0, +)
        
        let percentageChange = ((portfolioValue - previousValue) / previousValue) * 100
        
        let portfolio = StatisticModel(
            title: "Portfolio Value",
            value: portfolioValue.asCurrencyWith2Decimals(),
            percentageChange: percentageChange)
        
        stats.append(contentsOf: [
            marketCap,
            volume,
            btcDominace,
            portfolio
        ])
        return stats
    }
}
