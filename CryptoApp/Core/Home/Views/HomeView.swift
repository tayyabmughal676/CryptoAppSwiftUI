//
//  HomeView.swift
//  CryptoApp
//
//  Created by Thor on 04/08/2021.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var vm : HomeViewModel
    
    @State private var showPortfolio: Bool = false // Animate Right
    @State private var showPortfolioView: Bool = false // New Sheet
 
    var body: some View {
        ZStack{
            //            Background Layer
            Color.theme.background
                .ignoresSafeArea()
                .sheet(isPresented: $showPortfolioView, content: {
                    PortfolioView()
                        .environmentObject(vm)
                
                })
            //            Content Layer
            VStack{
                //                Home Header
                homeHeader
                
                HomeStatsView(showPortfolio: $showPortfolio)
                
                SearchBarView(searchText: $vm.searchText)
                
                //                Column Title
                columnTitles
                //            !portfolio
                if !showPortfolio {
                    allCoinsList
                        .transition(.move(edge: .leading))
                }
                //                Portfolio
                if showPortfolio{
                    portfolioCoinsList
                        .transition(.move(edge: .trailing))
                }
                
                Spacer(minLength: 0 )
            }
            
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            HomeView().navigationBarHidden(true)
        }
        .environmentObject(dev.homeVM)
    }
}

extension HomeView{
    private var homeHeader: some View{
        HStack{
            CircleButtonView(iconName: showPortfolio ? "plus": "info")
                .animation(.none)
                .onTapGesture {
                    if showPortfolio{
                        showPortfolioView.toggle()
                    }
                }
                .background(
                    CircleButtonAnimationView(animate: $showPortfolio)
                )
            Spacer()
            Text(showPortfolio ? "Portfolio" : "Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
                .animation(.none)
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: showPortfolio ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()){
                        showPortfolio.toggle()
                    }
                }
        }
        .padding(.horizontal)
        
    }
    
    private var allCoinsList : some View{
        //Coin List
        List{
            ForEach(vm.allCoins){ coin in
                CoinRowView(coin: coin, showHoldingsColumn: false)
                    .listRowInsets(.init(
                        top: 10,
                        leading: 0,
                        bottom: 10,
                        trailing: 10
                    ))
            }
        }
        .listStyle(PlainListStyle())
        
    }
    private var portfolioCoinsList : some View{
        //Coin List
        List{
            ForEach(vm.portfolioCoins){ coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
                    .listRowInsets(.init(
                        top: 10,
                        leading: 0,
                        bottom: 10,
                        trailing: 10
                    ))
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var columnTitles : some View{
        HStack{
            Text("Coin")
            Spacer()
            if showPortfolio{
                Text("Holdings")
            }
            Text("Price")
                .frame(width: UIScreen.main.bounds.width/3.5, alignment: .trailing)
        }
        .font(.caption)
        .foregroundColor(Color.theme.secondaryText)
        .padding(.horizontal)
    }
}
