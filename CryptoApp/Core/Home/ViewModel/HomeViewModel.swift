//
//  HomeViewModel.swift
//  CryptoApp
//
//  Created by Thor on 20/08/2021.
//

import Foundation
import Combine


class HomeViewModel: ObservableObject{
    
    @Published var allCoins :[CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    @Published var searchText: String = ""
    
    private let dataService = CoinDataService()
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
            .combineLatest(dataService.$allCoins)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterCoins)
            .sink { [weak self] (returnedCoins) in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
    }
    
    private func filterCoins(text: String, coins: [CoinModel]) -> [CoinModel]{
        guard !text.isEmpty else{
            return coins
        }
        
        let lowercasedText = text.lowercased()
        
        return coins.filter { (coin) -> Bool in
            return coin.name.lowercased().contains(lowercasedText) ||       coin.symbol.lowercased().contains(lowercasedText) ||
                coin.id.lowercased().contains(lowercasedText)
        }
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
