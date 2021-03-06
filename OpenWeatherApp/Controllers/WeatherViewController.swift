//
//  WeatherViewController.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 16/06/2022.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var weatherTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var geoButton: UIButton!
    
    private let locationManager = CLLocationManager()
    private var weatherViewModel: WeatherViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        weatherViewModel = WeatherViewModel(callback: updateUI)
        setupBackgroundImage()
        dismissKeyboardOnTap()
    }
    
    @IBAction func geoButtonPressed() {
        isLoading(true)
        locationManager.requestLocation()
    }
}

// MARK: - UITableView methods

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weatherViewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath)
        let list = weatherViewModel.getListForRow(at: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = weatherViewModel.getLabelText(list)
        content.secondaryText = weatherViewModel.getDescription(list)
        content.secondaryTextProperties.font = .systemFont(ofSize: 12, weight: .medium)
        content.image = UIImage(systemName: weatherViewModel.getImage(list))
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        var content = headerView.defaultContentConfiguration()
        
        content.text = weatherViewModel.getHeaderText()
        content.textProperties.font = .boldSystemFont(ofSize: 16)
        content.textProperties.color = .label
        
        headerView.contentConfiguration = content
        headerView.backgroundConfiguration = .clear()
        
        return headerView
    }
}

// MARK: - UITextField Delegate methods

extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        weatherViewModel.getCitiesForecast(searchTextField.text) { [weak self] errorText in
            DispatchQueue.main.async {
                self?.showAlert(errorText)
            }
        }
        searchTextField.resignFirstResponder()
        return true
    }
}

// MARK: - CLLocationManager Delegate methods

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        weatherViewModel.getGeoWeather(locations.last) { [weak self] errorText in
            DispatchQueue.main.async {
                self?.showAlert(errorText)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: - UIAlertController

extension WeatherViewController {
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
            self?.isLoading(false)
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
}

// MARK: - Private methods

extension WeatherViewController {
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            self?.weatherTableView.reloadData()
            self?.searchTextField.text = ""
            self?.isLoading(false)
        }
    }
    
    private func setupBackgroundImage() {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.image = UIImage(named: "bg")
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.65
        view.insertSubview(imageView, at: 0)
        searchTextField.backgroundColor = .clear
        weatherTableView.backgroundColor = .clear
        weatherTableView.allowsSelection = false
    }
    
    private func dismissKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func isLoading(_ bool: Bool) {
        var config = geoButton.configuration
        config?.showsActivityIndicator = bool
        geoButton.configuration = config
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}
