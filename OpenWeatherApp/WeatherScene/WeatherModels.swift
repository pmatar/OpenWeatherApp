//
//  WeatherModels.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 04/07/2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//
import Foundation

typealias WeatherViewModel = WeatherType.WeatherTask.ViewModel
typealias WeatherRequest = WeatherType.WeatherTask.Request
typealias WeatherResponse = WeatherType.WeatherTask.Response
typealias WeatherCell = WeatherType.WeatherTask.ViewModel.CellViewModel

enum WeatherType {
    
    enum WeatherTask {
        struct Request {
            var lat: Double? = nil
            var lon: Double? = nil
            var cities: String? = nil
        }
        
        struct Response {
            var city: City? = nil
            let weatherList: [List]
            let error: String?
        }
        
        struct ViewModel {
            struct CellViewModel {
                let labelText: String?
                let description: String
                let image: String
            }
            
            let cells: [CellViewModel]
            let headerText: String?
            let error: String?
        }
    }
}

