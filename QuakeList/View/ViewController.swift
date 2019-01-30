//
//  ViewController.swift
//  QuakeList
//
//  Created by Kaitlyn Wright on 1/29/19.
//  Copyright © 2019 Kaitlyn Wright. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var quakeArray: Array<Earthquake> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Fetch Date
        let currentDate = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: currentDate)!
        let formatter = DateFormatter()
        
        // Set title
        formatter.dateFormat = "MM/dd/yyyy"
        titleLabel.text = "Magnitudes & Locations of Earthquakes\n" + String(formatter.string(from: thirtyDaysAgo)) + " - " + String(formatter.string(from: currentDate))
        
        // Fetch earthquake data
        formatter.dateFormat = "yyyy-MM-dd"
        let earthquakeURL = URL(string: "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=" + String(formatter.string(from: thirtyDaysAgo)) + "&endtime=" + String(formatter.string(from: currentDate)) + "&minmagnitude=5")
        
        URLSession.shared.dataTask(with: earthquakeURL!, completionHandler: { (data, response, error) in
            
            if error != nil {
                let alertController = UIAlertController(title: "Internet connection offline.", message: nil, preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            // parse geojson
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                if let earthquakeArray = jsonObj!.value(forKey: "features") as? NSArray {
                    
                    // add earthquakes to array
                    for quake in earthquakeArray {
                        let feature = quake as! NSDictionary
                        let properties = feature.value(forKey: "properties") as! NSDictionary
                        let featurePlace = properties.value(forKey: "place") as! String
                        let featureMag = properties.value(forKey: "mag") as! NSNumber
                        let featureURL = properties.value(forKey: "url") as! String
                        let featureStatus = properties.value(forKey: "status") as! String
                        
                        let earthquake = Earthquake(magnitude: String(String(format: "%f", featureMag.doubleValue).prefix(3)), place: featurePlace, url: featureURL)
                        
                        // check to see if data has been reviewed
                        if featureStatus == "reviewed" {
                            self.quakeArray.append(earthquake)
                        }
                    }
                }
            }
            // update tableview data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }).resume()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: self.quakeArray[indexPath.row].url)
        if url == nil {
            return
        }
        UIApplication.shared.open(url!)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "EarthquakeCell", for: indexPath) as? EarthquakeCell
        if cell == nil {
            cell = EarthquakeCell()
        }
        
        let magnitude = Double(self.quakeArray[indexPath.row].magnitude)!
        if magnitude >= 5.0 && magnitude < 6.0 {
            cell?.textLabel?.textColor = UIColor.green
        }
        else if magnitude >= 6.0 && magnitude < 7.0 {
            cell?.textLabel?.textColor = UIColor.orange
        }
        else {
            cell?.textLabel?.textColor = UIColor.red
        }
        
        cell!.textLabel?.text = self.quakeArray[indexPath.row].magnitude
        cell!.detailTextLabel?.text = self.quakeArray[indexPath.row].place
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.quakeArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
