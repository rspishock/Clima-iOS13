//
//  WeatherManager.swift
//  Clima
//
//  Created by Ryan Spishock on 4/9/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}


struct WeatherManager {
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=51576b51f64a6682658fa9d27c76c318&units=imperial"
    //    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=51576b51f64a6682658fa9d27c76c318"
    
    var delegate: WeatherManagerDelegate?
    
    //    func fetchWeather(cityName: String, unit: String) {
    func fetchWeather(cityName: String) {
        //        let urlString = "\(weatherURL)&q=\(cityName)&units=\(unit)"
        let urlString = "\(weatherURL)&q=\(cityName)"
        //        print(urlString)
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        // 1. Create URL
        if let url = URL(string: urlString) {
            
            // 2. Creatre a URLSession
            let session = URLSession(configuration: .default)
            
            // 3. Give the session a task
            // Closure
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.passJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            // 4. Start the task
            task.resume()
        }
    }
    
    func passJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
