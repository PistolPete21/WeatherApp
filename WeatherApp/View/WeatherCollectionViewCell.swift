//
//  WeatherCollectionViewCell.swift
//  WeatherApp
//
//  Created by Peter Schwartz on 1/20/22.
//

import Foundation
import UIKit

class WeatherCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var hourlyTemp: UILabel!
    @IBOutlet weak var hourlyTime: UILabel!
    @IBOutlet weak var hourlyIcon: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
}
