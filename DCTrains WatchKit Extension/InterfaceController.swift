//
//  InterfaceController.swift
//  DCTrains WatchKit Extension
//
//  Created by Peter Olsen on 12/19/15.
//  Copyright © 2015 Peter Olsen. All rights reserved.
//

import WatchKit
import Foundation


class TableRowController: NSObject {
    @IBOutlet weak var destination: WKInterfaceLabel!
    @IBOutlet weak var minutes: WKInterfaceLabel!
}

class IncidentController: NSObject {
    @IBOutlet weak var text: WKInterfaceLabel!
}


class InterfaceController: WKInterfaceController {
    @IBOutlet var incidents: WKInterfaceTable?
    @IBOutlet var ballstonWest: WKInterfaceTable?
    var ballstonWestTime = Date(timeIntervalSince1970: 0)
    @IBOutlet var ballstonEast: WKInterfaceTable?
    var ballstonEastTime = Date(timeIntervalSince1970: 0)
    @IBOutlet var mclean: WKInterfaceTable?
    var mcleanTime = Date(timeIntervalSince1970: 0)
    @IBOutlet var metroCenter: WKInterfaceTable?
    var rosslynTime = Date(timeIntervalSince1970: 0)
    @IBOutlet var rosslyn: WKInterfaceTable?
    var foggyBottomTime = Date(timeIntervalSince1970: 0)
    @IBOutlet var foggyBottom: WKInterfaceTable?
    var metroCenterTime = Date(timeIntervalSince1970: 0)
    var incidentsTime = Date(timeIntervalSince1970: 0)
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        updateData()
    }
    
    override func didAppear() {
        updateData()
    }
    
    func updateData() {
        if ballstonWest != nil {
            if Date().timeIntervalSince(ballstonWestTime) > 15 {
                loadDataFor(ballstonWest!, station: "K04", track: "2")
                ballstonWestTime = Date()
            }
        } else if ballstonEast != nil {
            if Date().timeIntervalSince(ballstonEastTime) > 15 {
                loadDataFor(ballstonEast!, station: "K04", track: "1")
                ballstonEastTime = Date()
            }
        } else if mclean != nil {
            if Date().timeIntervalSince(mcleanTime) > 15 {
                loadDataFor(mclean!, station: "N01", track: "1")
                mcleanTime = Date()
            }
        } else if rosslyn != nil {
            if Date().timeIntervalSince(rosslynTime) > 15 {
                loadDataFor(rosslyn!, station: "C05", track: "2")
                rosslynTime = Date()
            }
        } else if foggyBottom != nil {
            if Date().timeIntervalSince(foggyBottomTime) > 15 {
                loadDataFor(foggyBottom!, station: "C04", track: "2")
                foggyBottomTime = Date()
            }
        } else if metroCenter != nil {
            if Date().timeIntervalSince(metroCenterTime) > 15 {
                loadDataFor(metroCenter!, station: "C01", track: "2")
                metroCenterTime = Date()
            }
        } else if incidents != nil {
            if Date().timeIntervalSince(incidentsTime) > 15 {
                loadIncidents(incidents!)
                incidentsTime = Date()
            }
        }
    }
    
    func loadDataFor(_ table: WKInterfaceTable, station: String, track: String) {
        func setTableText(_ s: String) {
            table.setNumberOfRows(1, withRowType: "default")
            let row = table.rowController(at: 0) as! TableRowController
            row.destination.setText(s)
            row.minutes.setText(" ")
        }
        
        setTableText("Loading...")
        
        let urlPath = "https://api.wmata.com/StationPrediction.svc/json/GetPrediction/\(station)"
        guard let url = URL(string: urlPath) else {
            setTableText("Bad URL")
            return
        }
        let config = URLSessionConfiguration.ephemeral
        config.httpAdditionalHeaders = ["api_key": api_key]
        config.timeoutIntervalForRequest = TimeInterval(5)
        
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url, completionHandler: {
            data, response, error in
            
            var results: [(line: String, dest: String, min: String, car: String)] = []
            
            guard let data = data else {
                setTableText("No data")
                return
            }
            
            var json: Any
            do {
                json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
            } catch {
                setTableText("Bad JSON")
                return
            }
            
            guard let dict = json as? NSDictionary else {
                setTableText("Bad return")
                return
            }
            
            guard let trainArray = dict["Trains"] as? NSArray else {
                setTableText("Bad trains")
                return
            }
            
            for trainDict in trainArray {
                guard let train = trainDict as? NSDictionary else {
                    setTableText("Bad train")
                    return
                }
                guard var destination = train["Destination"] as? String else {
                    setTableText("Bad dest")
                    return
                }
                switch destination {
                case "ssenger":
                    destination = "NoPassngrs"
                default:
                    break
                }
                
                guard let line = train["Line"] as? String else {
                    setTableText("Bad line")
                    return
                }
                
                guard let group = train["Group"] as? String else {
                    setTableText("Bad group")
                    return
                }
                guard var minutes = train["Min"] as? String else {
                    setTableText("Bad min")
                    return
                }
                minutes = minutes.capitalized

                let car = train["Car"] as? String ?? ""
                
                if group == track {
                    results.append((line: line, dest: destination, min: minutes, car: car))
                }
            }
            if results.count == 0 {
                setTableText("No trains")
                return
            }
            table.setNumberOfRows(results.count, withRowType: "default")
            for (index, result) in results.enumerated() {
                let row = table.rowController(at: index) as! TableRowController
                let lineColor: UIColor
                switch result.line {
                case "SV":
                    lineColor = UIColor.lightGray
                case "OR":
                    lineColor = UIColor.orange
                case "BL":
                    lineColor = UIColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
                case "RD":
                    lineColor = UIColor.red
                case "GR":
                    lineColor = UIColor.green
                case "YL":
                    lineColor = UIColor.yellow
                default:
                    lineColor = UIColor.white
                }
                let dest = NSAttributedString(string: result.dest, attributes: [NSAttributedString.Key.foregroundColor:lineColor])
                row.destination.setAttributedText(dest)
                let mins = NSAttributedString(string: result.min, attributes: [NSAttributedString.Key.foregroundColor: result.car == "8" ? UIColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0) : UIColor.white])
                row.minutes.setAttributedText(mins)
            }
        })
        task.resume()
    }
    
    func loadIncidents(_ table: WKInterfaceTable) {
        func setTableText(_ s: String) {
            table.setNumberOfRows(1, withRowType: "default")
            let row = table.rowController(at: 0) as! IncidentController
            row.text.setText(s)
        }
        
        setTableText("Loading...")
        
        let urlPath = "https://api.wmata.com/Incidents.svc/json/Incidents"
        guard let url = URL(string: urlPath) else {
            setTableText("Bad URL")
            return
        }
        let config = URLSessionConfiguration.ephemeral
        config.httpAdditionalHeaders = ["api_key": api_key]
        config.timeoutIntervalForRequest = TimeInterval(5)
        
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url, completionHandler: {
            data, response, error in
            
            var results: [String] = []
            
            if error != nil {
                setTableText(error!.localizedDescription)
                return
            }
            
            guard let data = data else {
                setTableText("No data")
                return
            }
            
            var json: Any
            do {
                json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
            } catch {
                setTableText("Bad JSON")
                return
            }
            
            guard let dict = json as? NSDictionary else {
                setTableText("Bad return")
                return
            }
            
            guard let incidentArray = dict["Incidents"] as? NSArray else {
                setTableText("Bad incidents")
                return
            }
            
            for incidentDict in incidentArray {
                guard let incident = incidentDict as? NSDictionary else {
                    setTableText("Bad incident")
                    return
                }
                guard let description = incident["Description"] as? String else {
                    setTableText("Bad description")
                    return
                }
                results.append(description)
            }
            if results.count == 0 {
                setTableText("No incidents")
                return
            }
            table.setNumberOfRows(results.count, withRowType: "default")
            for (index, result) in results.enumerated() {
                let row = table.rowController(at: index) as! IncidentController
                row.text.setText(result)
            }
        })
        task.resume()
    }
    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
