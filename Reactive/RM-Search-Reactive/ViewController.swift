//
//  ViewController.swift
//  RM-Search-Reactive
//
//  Created by Adam Mika on 4/4/21.
//

import Combine
import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var searchField: UITextField!
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  
  // Search results to display in UITableView
  var searchResults: [Character] = []
  
  // Amount of time to wait before auto serching
  let debounceTime: TimeInterval = 0.3
  
  // Minimum amount of characters that can trigger auto search
  let minCharacterCount = 3
  
  // Combine variables
  var searchSubject = PassthroughSubject<String, Never>()
  var autoSearchSubject = PassthroughSubject<String, Never>()
  var cancellables = Set<AnyCancellable>()
  
  @IBAction func textDidChange(_ sender: UITextField) {
    guard let term = sender.text else { return }
    autoSearchSubject.send(term)
  }
  
  @IBAction func searchTapped() {
    guard let term = searchField.text else { return }
    searchSubject.send(term)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Publishers.Merge(
      autoSearchSubject
        .filter { $0.count >= self.minCharacterCount }
        .debounce(for: .seconds(debounceTime), scheduler: DispatchQueue.main),
      searchSubject
    )
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty }
    .removeDuplicates()
    .flatMap { term in
      API.searchPublisher(term)
    }
    .receive(on: DispatchQueue.main)
    .sink { [unowned self] searchResults in
      self.searchResults = searchResults
      tableView.reloadData()
    }
    .store(in: &cancellables)
  }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
  static let reuseIdentifier = "reuseIdentifier"
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: ViewController.reuseIdentifier)
    if cell == nil {
      cell = UITableViewCell(style: .subtitle, reuseIdentifier: ViewController.reuseIdentifier)
    }
    
    let character = searchResults[indexPath.item]
    cell?.textLabel?.text = character.name
    cell?.detailTextLabel?.text = character.species
    
    return cell!
  }
}
