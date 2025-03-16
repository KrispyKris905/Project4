//
//  ContentView.swift
//  Project 4
//
//  Created by Cristobal Elizarraraz on 3/15/25.
//

import SwiftUI

class MemoryGameViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var numberOfPairs: Int = 3 {
        didSet {
            resetGame()
        }
    }
    
    private let allEmojis = ["🍎", "🍌", "🍉", "🍇", "🍓", "🥑", "🍋", "🍊","🍒", "🍑"]
    private var isProcessing = false
    init() {
        resetGame()
    }
    
    func resetGame() {
        let selectedEmojis = Array(allEmojis.prefix(numberOfPairs))
        let newCards = selectedEmojis.flatMap { emoji in
            [Card(icon: emoji), Card(icon: emoji)]
        }.shuffled()
        
        self.cards = newCards
    }
    
    func flipCard(_ card: Card) {
        guard !isProcessing else { return }
        
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            if !cards[index].isFaceUp {
                let faceUpCards = cards.filter { $0.isFaceUp && !$0.isMatched }
                if faceUpCards.count == 1 {
                    isProcessing = true
                    cards[index].isFaceUp.toggle()
                    checkForMatch(first: faceUpCards[0], second: cards[index])
                } else {
                    cards[index].isFaceUp.toggle()
                }
            }
        }
    }
    
    private func checkForMatch(first: Card, second: Card) {
        if first.icon == second.icon {
            if let firstIndex = cards.firstIndex(where: { $0.id == first.id }),
               let secondIndex = cards.firstIndex(where: { $0.id == second.id }) {
                cards[firstIndex].isMatched = true
                cards[secondIndex].isMatched = true
            }
            isProcessing = false
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let firstIndex = self.cards.firstIndex(where: { $0.id == first.id }),
                   let secondIndex = self.cards.firstIndex(where: { $0.id == second.id }) {
                    self.cards[firstIndex].isFaceUp = false
                    self.cards[secondIndex].isFaceUp = false
                }
                self.isProcessing = false
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = MemoryGameViewModel()
    
    var body: some View {
        ZStack{
            Image("fruit_background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Menu {
                        Button("3 Pairs") { viewModel.numberOfPairs = 3 }
                        Button("6 Pairs") { viewModel.numberOfPairs = 6 }
                        Button("10 Pairs") { viewModel.numberOfPairs = 10 }
                    } label: {
                        Text("Choose Size")
                            .padding(15)
                            .background(Color.yellow)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                    }
                    
                    Button("Reset  Game") {
                        viewModel.resetGame()
                    }
                    .padding(15)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                }
                .padding(5)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 5) {
                        ForEach(viewModel.cards.filter { !$0.isMatched }) { card in
                            CardView(card: card)
                                .onTapGesture {
                                    viewModel.flipCard(card)
                                }
                        }
                    }
                    .padding(5)
                }
            }
        }
    }
}
struct Card: Identifiable {
    let id = UUID()
    let icon: String
    var isFaceUp = false
    var isMatched = false
}
struct CardView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            if card.isFaceUp {
                Text(card.icon)
                    .font(.largeTitle)
                    .frame(width: 110, height: 150)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
                    .frame(width: 110, height: 150)
            }
        }
    }
}
#Preview {
    ContentView()
}
