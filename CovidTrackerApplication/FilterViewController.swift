//
//  FilterViewController.swift
//  CovidTrackerApplication
//
//  Created by Nuthan Raju Pesala on 09/06/21.
//

import UIKit

class FilterViewController: UIViewController, UISearchControllerDelegate {

    private var tableView: UITableView = {
       let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.tableFooterView = UIView()
        return tv
    }()
    
    var states = [State]()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var completion : ((State) -> Void)? 
    
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        self.getAllStates()
        navigationController?.navigationBar.prefersLargeTitles = false
        self.title = "Select State"
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search State"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func getAllStates() {
        APICaller.shared.getStateList { [weak self] (result) in
            switch result {
            case .success(let states):
                self?.states = states
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error:", error.localizedDescription as Any)
            }
        }
    }

}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = states[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
        let state = states[indexPath.row]
        completion?(state)
    }
}

extension FilterViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text , !text.isEmpty else {
            return
        }
        if self.states.count != 0 {
            self.states = self.states.filter({
                $0.name.lowercased().contains(text.lowercased())
            })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }else {
            self.getAllStates()
        }
    }
}
