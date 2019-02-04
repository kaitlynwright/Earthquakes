//
//  ViewController.swift
//  QuakeList
//
//  Created by Kaitlyn Wright on 1/30/19.
//  Copyright © 2019 Kaitlyn Wright. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateButton: UIBarButtonItem!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    var quakeArray: Array<Earthquake> = []
    var pickerData = [30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1]
    var daysToDisplay = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.layer.borderWidth = 3
        pickerView.layer.borderColor = UIColor.black.cgColor
        pickerView.isHidden = true
        
        tableView.rowHeight = 60
        tableView.dataSource = self
        tableView.delegate = self
        picker.delegate = self
        picker.dataSource = self
        
        refreshData()
    }
    
    func refreshData() {
        self.quakeArray = []
        
        // Fetch Date
        let currentDate = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -(daysToDisplay), to: currentDate)!
        let formatter = DateFormatter()
        
        // Set title
        formatter.dateFormat = "MM/dd/yyyy"
        titleLabel.text = "USGS Earthquakes\n" + String(formatter.string(from: thirtyDaysAgo)) + " - " + String(formatter.string(from: currentDate))
        
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
            formatter.dateFormat = "MM/dd/yyyy HH:mm"
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                if let earthquakeArray = jsonObj!.value(forKey: "features") as? NSArray {
                    
                    // add earthquakes to array
                    for quake in earthquakeArray {
                        let feature = quake as! NSDictionary
                        let properties = feature.value(forKey: "properties") as! NSDictionary
                        let featurePlace = properties.value(forKey: "place") as! String
                        let featureMag = properties.value(forKey: "mag") as! NSNumber
                        let featureTime = NSDate(timeIntervalSince1970: TimeInterval(properties.value(forKey: "time") as! Int) / 1000)
                        let featureURL = properties.value(forKey: "url") as! String
                        let featureStatus = properties.value(forKey: "status") as! String
                        
                        let earthquake = Earthquake(magnitude: String(String(format: "%f", featureMag.doubleValue).prefix(3)), place: featurePlace, time: formatter.string(from: featureTime as Date), url: featureURL)
                        
                        // check if data has been reviewed
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
    
    // MARK - Actions
    @IBAction func dateButtonClicked(_ sender: Any) {
        pickerView.isHidden = false
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        pickerView.isHidden = true
        refreshData()
        tableView.reloadData()
    }
    
    @IBAction func refreshButtonClicked(_ sender: Any) {
        refreshData()
        tableView.reloadData()
    }
}

// MARK - TableView Extension
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
            cell?.magnitudeLabel?.textColor = UIColor.green
        }
        else if magnitude >= 6.0 && magnitude < 6.5 {
            cell?.magnitudeLabel?.textColor = UIColor.orange
        }
        else {
            cell?.magnitudeLabel?.textColor = UIColor.red
        }
        
        cell!.magnitudeLabel?.text = self.quakeArray[indexPath.row].magnitude
        cell!.locationLabel?.text = self.quakeArray[indexPath.row].place
        cell!.timeLabel?.text = self.quakeArray[indexPath.row].time
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.quakeArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

// MARK - Picker Extension
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerData[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(row)
        self.daysToDisplay = pickerData[row]
    }
}
