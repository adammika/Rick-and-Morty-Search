//
//  API.swift
//  RM-Search-Reactive
//
//  Created by Adam Mika on 4/4/21.
//

import Combine
import Foundation

struct Response<T>: Codable where T: Codable {
  var results: [T]
}

struct Character: Codable, Hashable {
  let name: String
  let species: String
}

final class API {
  typealias Callback = ([Character]) -> Void
  
  static func searchPublisher(_ term: String) -> AnyPublisher<[Character], Never> {
    let url = URL(string: "https://rickandmortyapi.com/api/character/?name=\(term)")!

    return URLSession.shared.dataTaskPublisher(for: url)
      .map { $0.0 }
      .decode(type: Response<Character>.self, decoder: JSONDecoder())
      .map { $0.results }
      .replaceError(with: [])
      .eraseToAnyPublisher()
  }
}
