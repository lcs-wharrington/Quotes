//
//  ContentView.swift
//  Quotes
//
//  Created by William Robert Harrington on 2022-02-25.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Stored properties
    @State var currentQuote: Quote = Quote(quoteText:"When you are offended at any man\'s fault, turn to yourself and study your own failings. Then you will forget your anger.", quoteAuthor:"Epictetus", senderName:"", senderLink:"", quoteLink:"http://forismatic.com/en/22b6b234e5/")
    
    //List of favorite quotes
    @State var favourites: [Quote] = []
    
    // Detect when app moves between the foreground, background, and inactive states
    // NOTE: A complete list of keypaths that can be used with @Environment can be found here:
    // https://developer.apple.com/documentation/swiftui/environmentvalues
    @Environment(\.scenePhase) var scenePhase
    
    // Determine if current quote is a favoirite
    @State var currentQuoteAddedToFavourites: Bool = false
    
    // MARK: Computed properties
    var body: some View {
        VStack {
            
            VStack{
                Text(currentQuote.quoteText)
                                .font(.title)
                                .minimumScaleFactor(0.5)
                                .padding(30)
                            
                HStack{
                    
                    Spacer()
                    
                    Text("-\(currentQuote.quoteAuthor)")
                        .font(.title3)
                        .minimumScaleFactor(0.5)
                        .padding(30)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary, lineWidth: 4)
                )
            
            
            
            Image(systemName: "heart.circle")
                .font(.largeTitle)
                .foregroundColor(currentQuoteAddedToFavourites == true ? .red : .secondary)
                .onTapGesture {
                    
                    if currentQuoteAddedToFavourites == false {
                        
                        favourites.append(currentQuote)
                        
                        currentQuoteAddedToFavourites = true
                    }
                }
            
            Button(action: {
                
                // Task call new quote
                Task {
                    await loadNewQuote()
                }
                
            }, label: {
                Text("Another one!")
            })
                .buttonStyle(.bordered)
            
            HStack {
                Text("Favourites")
                    .bold()
                
                Spacer()
            }
            
            //Individual favourites
            List(favourites, id: \.self) { currentFavourite in
                Text(currentFavourite.quoteText)
            }
            Spacer()
        }
        
        // React to changes of state for the app (foreground, background, and inactive)
        .onChange(of: scenePhase) { newPhase in
            
            if newPhase == .inactive {
                
                print("Inactive")
                
            } else if newPhase == .active {
                
                print("Active")
                
            } else if newPhase == .background {
                
                print("Background")
                
                // Permanently save the list of tasks
                persistFavourites()
            }
        }
        
        
        // Task load a new quote and load list of favourites
        .task {
            
            await loadNewQuote()
            
            print("Tried to load new quote")
            
            loadFavourites()
        }
        
        //Navigation Title
        .navigationTitle("Quotes")
        .padding()
    }
    
    // MARK: Functions
    
    func loadNewQuote() async {
        
        // Assemble the URL that points to the endpoint
        let url = URL(string: "http://forismatic.com/en/22b6b234e5/")!
        
        // Request URL
        var request = URLRequest(url: url)
        
        // Request JSON data
        request.setValue("application/json",
                         forHTTPHeaderField: "Accept")
        
        // Share the session between app and endpoint
        let urlSession = URLSession.shared
        
        do {
            
            // Retreve raw data from the endpoint
            let (data, _) = try await urlSession.data(for: request)
            
           // Attempts to decode raw data and then put it into Quote struct
            currentQuote = try JSONDecoder().decode(Quote.self, from: data)
            
           // Resets the heart icons coulour
            currentQuoteAddedToFavourites = false
            
        } catch {
            print("Could not retrieve or decode the JSON from endpoint.")
            
            // Print the contents of the "error" constant that the do-catch block populates
            print(error)
        }
        
    }
    
    // Saves (persists) the data to local storage on the device
    func persistFavourites() {
        
        // Get a URL that points to the saved JSON data containing our list of tasks
        let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
        
        // Try to encode the data in our people array to JSON
        do {
            // Create an encoder
            let encoder = JSONEncoder()
            
            // Ensure the JSON written to the file is human-readable
            encoder.outputFormatting = .prettyPrinted
            
            // Encode the list of favourites we've collected
            let data = try encoder.encode(favourites)
            
            // Actually write the JSON file to the documents directory
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            
            // See the data that was written
            print("Saved data to documents directory successfully.")
            print("===")
            print(String(data: data, encoding: .utf8)!)
            
        } catch {
            
            print(error.localizedDescription)
            print("Unable to write list of favourites to documents directory in app bundle on device.")
            
        }
    }
    
    // Loads favourites from local storage on the device into the list of favourites
    func loadFavourites() {
        
        // Get a URL that points to the saved JSON data containing our list of favourites
        let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
        print(filename)
        
        // Attempt to load from the JSON in the stored / persisted file
        do {
            
            // Load the raw data
            let data = try Data(contentsOf: filename)
            
            // Contents of loaded file
            print("Got data from file, contents are:")
            print(String(data: data, encoding: .utf8)!)
            
            // Decode data into Swift data structure
            favourites = try JSONDecoder().decode([Quote].self, from: data)
            
        } catch {
            
            // Identify the error
            print(error.localizedDescription)
            print("Could not load data from file, initializing with tasks provided to initializer.")
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}
