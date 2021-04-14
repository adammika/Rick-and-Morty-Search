//
//  API.swift
//  RM-Search-Imperative
//
//  Created by Adam Mika on 4/4/21.
//

import Foundation

struct Response<T>: Codable where T: Codable {
  var results: [T]
}

struct Character: Codable {
  let name: String
  let species: String
}

final class API {
  typealias Callback = ([Character]) -> Void
  
  static func search(for term: String,
                     callback: @escaping Callback) {
    let url = URL(string: "https://rickandmortyapi.com/api/character/?name=\(term)")!
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil, let data = data else {
        print("Something went wrong with network request")
        return
      }
      
      let decoder = JSONDecoder()
      guard let decodedResponse = try? decoder.decode(Response<Character>.self, from: data) else {
        print("Something went wrong with decoding")
        return
      }
      
      callback(decodedResponse.results)
    }.resume()
  }
}
