//
//  ViewController.swift
//  RM-Search-Imperative
//
//  Created by Adam Mika on 4/4/21.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var searchField: UITextField!
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  
  // Search results to display in UITableView
  var searchResults: [Character] = []
  
  // Keep track of last search term to avoid duplicates
  var lastSearchTerm: String?
  
  // Timer to avoid searching while typing
  var debounceTimer: Timer?
  
  // Amount of time to wait before auto serching
  let debounceTime: TimeInterval = 0.3
  
  // Minimum amount of characters that can trigger auto search
  let minCharacterCount = 3
  
  @IBAction func textDidChange(_ sender: UITextField) {
    guard let term = sender.text else { return }
    autoSearch(for: term)
  }
  
  @IBAction func searchTapped() {
    guard let term = searchField?.text else { return }
    search(for: term)
  }
  
  private func autoSearch(for term: String) {
    guard term.count >= minCharacterCount else { return }
    
    debounceTimer?.invalidate()
    debounceTimer = Timer.scheduledTimer(
      withTimeInterval: debounceTime,
      repeats: false) { [weak self] _ in
      self?.search(for: term)
    }
  }
  
  private func search(for term: String) {
    let searchTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !searchTerm.isEmpty else { return }
    guard self.lastSearchTerm != searchTerm else { return }
        
    API.search(for: searchTerm) { results in
      self.lastSearchTerm = searchTerm
      self.searchResults = results
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
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
