//
//  APICaller.swift
//  CovidTrackerApplication
//
//  Created by Nuthan Raju Pesala on 08/06/21.
//

import Foundation
extension DateFormatter {
    
   static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeZone = .current
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
   static let prettyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.locale = .current
        formatter.timeZone = .current
        formatter.dateStyle = .medium
        return formatter
    }()
}

class APICaller {
    
   
    
    static let shared = APICaller()
    private init() {}
    
    struct Constants {
        static let stateUrl = URL(string: "https://api.covidtracking.com/v2/states.json")
    }
    enum DataScope {
        case national
        case state(State)
    }
    
    func getCovidData(for scope: DataScope,completion: @escaping (Result<[dayData], Error>) -> Void) {
        var urlString = ""
        switch scope {
        case .national: urlString = "https://api.covidtracking.com/v2/us/daily.json"
        case .state(let state):
            urlString = "https://api.covidtracking.com/v2/states/\(state.state_code.lowercased())/daily.json" 
        }
        guard let url = URL(string: urlString) else {
            return
        }
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            do {
                let result = try JSONDecoder().decode(CovidDataResponse.self, from: data)
                let models: [dayData] = result.data.compactMap({
                    guard let date = DateFormatter.dayFormatter.date(from: $0.date), let value = $0.cases?.total.value else {
                        return nil
                    }
                    return dayData(date: date, value: value)
                })
                completion(.success(models))
            }catch {
                print("Failed to get data")
            }
        }.resume()
    }
    
    func getStateList(completion: @escaping (Result<[State], Error>)-> Void) {
        guard let url = Constants.stateUrl else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            do {
                let result = try JSONDecoder().decode(StateResponselist.self, from: data)
                completion(.success(result.data))
            }catch {
               print("Failed to get data")
            }
        }.resume()
        
    }
    
}

struct StateResponselist: Codable {
    let data: [State]
}
struct State: Codable {
    let name: String
    let state_code: String
}

struct CovidDataResponse: Codable {
    let data: [CovidDayData]
}
struct CovidDayData: Codable {
    let cases: CovidCases?
    let date: String
}
struct CovidCases: Codable {
    let total: TotalCases
}
struct TotalCases: Codable {
    let value: Int?
}
struct dayData {
    let date: Date
    let value: Int
}
