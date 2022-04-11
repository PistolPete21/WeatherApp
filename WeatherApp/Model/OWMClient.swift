//
//  OWMClient.swift
//  WeatherApp
//
//  Created by Peter Schwartz on 1/20/22.
//

import Foundation

class OWMClient {
    static let apiKey = "{Api_Key_Here}"

    enum Endpoints {
        static let apiBase = "https://api.openweathermap.org"
        static let imageBase = "https://openweathermap.org"

        case grabCurrentForecast(Double, Double)
        case grabWeatherIcon(String)
        
        var url: URL {
            switch self {
            case .grabCurrentForecast(let latitude, let longitude):
                var urlComps = URLComponents(string: Endpoints.apiBase + "/data/2.5/onecall")
                let queryParams = [
                    URLQueryItem(name: "lat", value: "\(latitude)"),
                    URLQueryItem(name: "lon", value: "\(longitude)"),
                    URLQueryItem(name: "exclude", value: "minutely,daily"),
                    URLQueryItem(name: "appid", value: OWMClient.apiKey)
                ]
                urlComps?.queryItems = queryParams
                let result = urlComps?.url?.absoluteString ?? ""
                let url = URL(string: result)!
                return url
            case .grabWeatherIcon(let weatherIcon):
                let result = Endpoints.imageBase + "/img/wn/" + weatherIcon + "@2x.png"
                let url = URL(string: result)!
                return url
            }
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
         }
        
        task.resume()
        
        return task
    }
    
    class func getForecast(latitude: Double, longitude: Double, completion: @escaping (WeatherResponse?, Error?) -> Void) -> Void {
        let url = Endpoints.grabCurrentForecast(latitude, longitude).url
        
        taskForGETRequest(url: url, responseType: WeatherResponse.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func downloadWeatherIcon(weatherIcon: String, completion: @escaping (Data?, Error?) ->Void) {
        let iconUrl = Endpoints.grabWeatherIcon(weatherIcon).url
        
        let task = URLSession.shared.dataTask(with: iconUrl) { data, response, error in
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        task.resume()
    }
}
