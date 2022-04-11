//
//  FavoritesViewController.swift
//  WeatherApp
//
//  Created by Peter Schwartz on 1/25/22.
//

import Foundation
import UIKit

class FavoritesViewController : UIViewController, UINavigationControllerDelegate {
    
    var favoriteLocation: Location!
    var locations: [Location]!
    var cityState: String = ""
    var favoriteCellPath: IndexPath? = nil
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    var dataController: DataController!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let navItem = UINavigationItem(title: "Favorites")
        let closeItem = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: #selector(closeTapped))
        
        navItem.rightBarButtonItem = closeItem

        navBar.setItems([navItem], animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteTableViewCell")!
                
        cell.textLabel?.text = "\(locations[indexPath.row].latitude), \(locations[indexPath.row].longitude)"
        cell.detailTextLabel?.text = locations[indexPath.row].cityState
        
        if locations[indexPath.row].favorite {
            cell.imageView?.image = UIImage(systemName: "star.fill")
            favoriteCellPath = indexPath
        } else {
            cell.imageView?.image = UIImage(systemName: "star")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if favoriteCellPath != nil || favoriteCellPath == indexPath {
            if favoriteCellPath == indexPath {
                locations[indexPath.row].favorite = false
                favoriteCellPath = nil
                tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                locations[favoriteCellPath!.row].favorite = false
                locations[indexPath.row].favorite = true
                tableView.reloadRows(at: [indexPath, favoriteCellPath!], with: .automatic)
                favoriteCellPath = indexPath
            }
        } else {
            locations[indexPath.row].favorite = true
            favoriteCellPath = indexPath
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        try? dataController?.viewContext.save()
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            dataController.viewContext.delete(locations[indexPath.row])

            locations.remove(at: indexPath.row)
            
            try? dataController?.viewContext.save()

            tableView.reloadData()
        }
    }
    
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
}
