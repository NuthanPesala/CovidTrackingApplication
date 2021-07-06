//
//  ViewController.swift
//  CovidTrackerApplication
//
//  Created by Nuthan Raju Pesala on 08/06/21.
//

import UIKit
import Charts

class ViewController: UIViewController {

    private var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.tableFooterView = UIView()
        return tv
    }()
    
    private var scope = APICaller.DataScope.national
    
    private var data = [dayData]()
    
    let numberFormatter : NumberFormatter = {
      let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        formatter.locale = .current
        formatter.formatterBehavior = .default
        return formatter
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        self.title = "Covid Cases"
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        createFilterBtn()
        fetchData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    func createFilterBtn() {
        let buttonTitle: String = {
            switch scope {
            case .national: return "National"
            case .state(let state):
                return state.name
            }
        }()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(didTapfilter))
    }
    
    func fetchData() {
        APICaller.shared.getCovidData(for: scope) { [weak self] (result) in
            switch result {
            case .success(let data):
                self?.data = data
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.createGraph()
                }
            case .failure(let error):
                print(error.localizedDescription as Any)
            }
        }
    }
    
    @objc func didTapfilter() {
        let filterVC = FilterViewController()
        filterVC.completion = { state in
            self.scope = .state(state)
        }
        navigationController?.pushViewController(filterVC, animated: true)
    }
    
    private func createGraph() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width / 1.5))
        headerView.clipsToBounds = true
        var entries: [BarChartDataEntry] = []
        let set = data.prefix(20)
        for index in 0..<set.count {
            let dayData = data[index]
            entries.append(.init(x: Double(index), y: Double(dayData.value)))
            
        }
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = ChartColorTemplates.joyful()
        let data : BarChartData = BarChartData(dataSet: dataSet)
        let chart = BarChartView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))
        
        chart.data = data
        headerView.addSubview(chart)
        tableView.tableHeaderView = headerView
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
        let dateString = DateFormatter.prettyFormatter.string(from: data[indexPath.row].date)
        let value = numberFormatter.string(from: NSNumber(value: data[indexPath.row].value))
        cell.textLabel?.text = "\(dateString)" + "  " + "\(value ?? "0")"
        return cell
    }
    
    
}
