//
//  PopupViewController.swift
//  WeatherApp
//
//  Created by Peter Schwartz on 1/24/22.
//

import Foundation
import UIKit

protocol PopUpDelegate {
    func refreshWeather(latitude: Double, longitude: Double)
}

class PopupViewController: UIViewController {
    static let identifier = "PopupViewController"
    
    var delegate: PopUpDelegate?
    
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var latitudeTextBox: UITextField!
    @IBOutlet weak var longitudeTextBox: UITextField!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var laterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        dialogView.layer.cornerRadius = 6.0
        dialogView.layer.borderWidth = 1.2
        dialogView.layer.borderColor = UIColor(named: "electricBlue")?.cgColor
    }

    @IBAction func laterButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okButtonClick(_ sender: Any) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeatherViewController") as? WeatherViewController
        
        let lat = (latitudeTextBox.text as? NSString)?.doubleValue ?? 0.0
        let lon = (longitudeTextBox.text as? NSString)?.doubleValue ?? 0.0
        
        self.delegate?.refreshWeather(latitude: lat, longitude: lon)

        self.dismiss(animated: true, completion: nil)
    }
    
    static func showPopup(parentVC: UIViewController){
        if let popupViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopupViewController") as? PopupViewController {
            popupViewController.modalPresentationStyle = .custom
            popupViewController.modalTransitionStyle = .crossDissolve
            popupViewController.delegate = parentVC as? PopUpDelegate
            parentVC.present(popupViewController, animated: true)
        }
    }
}
