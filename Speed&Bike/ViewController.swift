//
//  ViewController.swift
//  Speed&Bike
//
//  Created by Marcos Gonzalez Diaz on 31/8/18.
//  Copyright © 2018 Marcos Gonzalez Diaz. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate{
    
    let locationManager = CLLocationManager()
    
    
    private var movimiento = false
    private var gps = true
    private var altitude : CLLocationDistance!
    private var gainaltitude : CLLocationDistance = 0
    private var distance = 0.0
    private var firstdistance = 0.0
    private var sumdif = 0.0
    private var speed: Double!
    private var avgspeed: Double = 0.0
    private var slope: Double!
    private let distancefilter = 5.0
    private var contador = 0
    private var startLocation: CLLocation?
    private var lastLocation:CLLocation?
    private var time: Int = 0
    private var timer: Timer!
    
    @IBOutlet weak var tiempo: UILabel!
   
    @IBOutlet weak var velocidad: UILabel!
    
    @IBOutlet weak var distancia: UILabel!
    @IBOutlet weak var pendiente: UILabel!
    @IBOutlet weak var velocidadmedia: UILabel!
    
    @IBOutlet weak var altitudacum: UILabel!
    @IBOutlet weak var altitud: UILabel!
    
    @IBOutlet weak var PlayStop: UIButton!
    @IBAction func play(_ sender: UIButton) {
        if movimiento == false && gps == true{
            movimiento = true
            //startTime = Date().timeIntervalSince1970
            timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTime)), userInfo: nil, repeats: true)
            sender.setImage(UIImage(named: "Stop.png"), for: .normal)
        } else if movimiento == true{
            sender.setImage(UIImage(named: "Play.png"), for: .normal)
            timer.invalidate()
            startLocation = nil
            velocidad.text? = String(format: "%.1f", 0) + " km/h"
            movimiento = false
        }
    }
    
    func updateDisplay(){
        self.updateTime()
        distancia.text? = String(format: "%.1f", distance) + " km"
        altitudacum.text? = String(format: "%.0f", gainaltitude) + " m"
        velocidadmedia.text? = String(format: "%.1f", avgspeed)
        velocidad.text? = String(format: "%.1f", speed*3.6) + " km/h"
    }
    
    @IBAction func reset(_ sender: UIButton) {
        if movimiento == true{
            self.play(PlayStop)
        }
        speed = 0
        firstdistance = 0
        distance = 0
        gainaltitude = 0
        avgspeed = 0
        time = -1
        slope = 0
        startLocation = nil
        movimiento = false
        updateDisplay()
    }
    
    
    @IBAction func gps_button(_ sender: UIButton) {
        if gps == false{
            gps = true
            locationManager.startUpdatingLocation()
            sender.setImage(UIImage(named: "satellite_on.png"), for: .normal)
        } else{
            if movimiento == true {
                self.play(PlayStop)
            }
            gps = false
            locationManager.stopUpdatingLocation()
            sender.setImage(UIImage(named: "satellite_off.png"), for: .normal)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        
        // For use when the app is open & in the background
        locationManager.requestAlwaysAuthorization()
        
        // For use when the app is open
        //locationManager.requestWhenInUseAuthorization()
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // You can change the location accuary here.
            locationManager.distanceFilter = 5.0
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            //locationManager.activityType = .fitness
            locationManager.startUpdatingLocation()
            //locationManager.requestLocation()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if movimiento == true && gps == true {
            
            speed = manager.location!.speed
            if speed < 0 {
                speed = 0
            }
            velocidad.text? = String(format: "%.1f", speed*3.6) + " km/h"
            
            if startLocation == nil {
                startLocation = locations.last
            }else if let lastLocation = locations.last{
                distance += lastLocation.distance(from: startLocation!)/1000
                distancia.text? = String(format: "%.1f", distance) + " km"
                startLocation = lastLocation
            }
            
            if contador == 10 && (distance - firstdistance) != 0{
                slope = sumdif * 0.1 / (distance - firstdistance)
                pendiente.text? = String(format: "%.1f", slope) + "%"
                firstdistance = distance
            }
            
            
            if time>0 {avgspeed = distance * 3600 / Double(time)}
            velocidadmedia.text? = String(format: "%.1f", avgspeed)
        }
        
        if Double((locations.last?.verticalAccuracy)!) > 0.0 {
            if altitude == nil{
                altitude = locations.last?.altitude
            }
            let difal = (locations.last?.altitude)! - altitude
            if contador < 10 {
                contador += 1
                sumdif += difal
            }
            else{
                if sumdif > 0 && movimiento == true {
                    gainaltitude += sumdif
                    altitudacum.text? = String(format: "%.0f", gainaltitude) + " m"
                }
                contador = 0
                sumdif = 0
            }
            
            altitude = locations.last?.altitude
            altitud.text? = String(format: "%.0f", altitude) + " m"
        }
    }
    
    @objc func updateTime(){
        time += 1
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        tiempo.text? = String(hours) + ":" + String(format: "%02d" ,minutes) + ":" + String(format: "%02d" ,seconds)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clErr = error as? CLError {
            switch clErr {
            case CLError.locationUnknown:
                print("location unknown")
            case CLError.denied:
                print("denied")
            default:
                print("other Core Location error")
            }
        } else {
            print("other error:", error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

}

