//
//  CoinImageVIew.swift
//  CryptoApp
//
//  Created by Thor on 21/08/2021.
//

import SwiftUI


struct CoinImageVIew: View {
    
    @StateObject var vm : CoinImageViewModel
    
    init(coin: CoinModel) {
        _vm = StateObject(wrappedValue: CoinImageViewModel(coin: coin))
    }
    
    var body: some View {
        
        ZStack{
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else if vm.isLoading{
                ProgressView()
            } else {
                Image(systemName: "questionmark")
                    .foregroundColor(Color.theme.secondaryText)
            }
        }
    }
}

struct CoinImageVIew_Previews: PreviewProvider {
    static var previews: some View {
        CoinImageVIew(coin: dev.coin)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
