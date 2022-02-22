//
//  ContentView.swift
//  Quotes
//
//  Created by William Robert Harrington on 2022-02-22.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Stored Properties
    
    @State var currentQuote: Quote = Quote(quoteText: "", quoteAuthor: "", senderName: "", senderLink: "", quoteLink: "")
    
    // MARK: Computed Properties
    
    var body: some View {
        
        // MARK: UI
        
        VStack{
            
            // Displayed quote
            VStack{
                
                Text("The two most poerful warriors are patience and time")
                    .font(.system(size: 20))
                    .bold()
                    .padding()
                
                HStack{
                    
                    Spacer()
                    Text("- Leo Tolstoy")
                        .italic()
                        .padding()
                    
                }
            }
            
            .multilineTextAlignment(.leading)
            .padding(30)
            .overlay(RoundedRectangle(cornerRadius: 0)
            .stroke(Color.primary, lineWidth: 4))
            .padding(10)
            
            // Heart Circle
            Image(systemName: "heart.circle")
                .resizable()
                .frame(width: 40, height: 40, alignment: .center)
                .foregroundColor( .gray)
            
            // Another one! button
            Button(action: {
                
                print("Button was pressed")
                
            }, label: {
                
                Text("Another One!")
            })
            
            .buttonStyle(.bordered)
            
            HStack{
                
                Text("Favourites")
                    .font(.title3)
                    .bold()
                
                Spacer()
                
            }
            
            // List
            List {
                Text("Nothimng is a wast of time if you use the experience wisely.")
                Text("If your action inspire others to dream more, learn more, do more and become more, you are a leader.")
                
            }
        }
        
        // MARK: Task
        .task{
            
            //locate url
            let url = URL(string: "http://forismatic.com/en/ababb23b16/")!
            
            //Define data type
            //configure request to web site
            var request = URLRequest(url: url)
            
            //Ask for json
            request.setValue("appliction/json", forHTTPHeaderField: "Accept")
            
            //Start session to interact with the endpoint
            let urlSession = URLSession.shared
            
            //Attempt to fetch new Quote
            //Possible do-catch result
            do {
                
                //retreve raw data from endpoint
                let (data, _) = try await urlSession.data(for: request)
                
                //Attept at decode data to swift struct
                //takes the data and trys to apply it to "currentQuote"
                currentQuote = try JSONDecoder().decode(Quote.self, from: data)
                
            } catch {
                
                print("Failed to retreive or decode the JSON from endpoint.")
                // Print the errored code
                print(error)
            }
        }
        
        .navigationTitle("Quotes")
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}
