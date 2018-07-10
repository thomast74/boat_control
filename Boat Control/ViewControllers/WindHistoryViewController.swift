//
//  WindHistoryViewController.swift
//  Boat Control
//
//  Created by Thomas Trageser on 04/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import UIKit
import Charts

class WindHistoryViewController: UIViewController, ModelManagerDelegate {
    
    var modelManager: ModelManager?
    
    @IBOutlet weak var aparentWindAngle: NumberView!
    @IBOutlet weak var aparentWindSpeed: NumberView!
    @IBOutlet weak var aparentWindDirection: NumberView!
    @IBOutlet weak var trueWindAngle: NumberView!
    @IBOutlet weak var trueWindSpeed: NumberView!
    @IBOutlet weak var trueWindDirection: NumberView!
    @IBOutlet weak var twdHistoryChart: ScatterChartView!
    @IBOutlet weak var twsHistoryChart: ScatterChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("WindHistoryViewController: viewDidLoad")
        configureTWDHistoryChart()
        configureTWSHistoryChart()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("WindHistoryViewController: viewWillAppear")
        
        modelManager?.setDelegate(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("WindHistoryViewController: viewWillDisappear")
    }
    
    
    func configureTWDHistoryChart() {
        twdHistoryChart.chartDescription?.enabled = false
        twdHistoryChart.dragEnabled = true
        twdHistoryChart.setScaleEnabled(true)
        twdHistoryChart.pinchZoomEnabled = false
        twdHistoryChart.rightAxis.enabled = false
        twdHistoryChart.legend.enabled = false

        let leftAxis = twdHistoryChart.leftAxis
        leftAxis.inverted = true
        leftAxis.labelPosition = .outsideChart
        leftAxis.drawBottomYLabelEntryEnabled = false
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.labelFont = .systemFont(ofSize: 16, weight: .light)
        leftAxis.labelTextColor = .lightGray
        
        let xAxis = twdHistoryChart.xAxis
        xAxis.labelPosition = .top
        xAxis.drawGridLinesEnabled = false
        xAxis.labelFont = .systemFont(ofSize: 16, weight: .light)
        xAxis.labelTextColor = .lightGray
    }

    func configureTWSHistoryChart() {
        twsHistoryChart.chartDescription?.enabled = false
        twsHistoryChart.dragEnabled = true
        twsHistoryChart.setScaleEnabled(true)
        twsHistoryChart.pinchZoomEnabled = false
        twsHistoryChart.rightAxis.enabled = false
        twsHistoryChart.legend.enabled = false
        
        let leftAxis = twsHistoryChart.leftAxis
        leftAxis.inverted = true
        leftAxis.labelPosition = .outsideChart
        leftAxis.drawBottomYLabelEntryEnabled = false
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.labelFont = .systemFont(ofSize: 16, weight: .light)
        leftAxis.labelTextColor = .lightGray
        
        let xAxis = twsHistoryChart.xAxis
        xAxis.labelPosition = .top
        xAxis.axisMinimum = 0.0
        xAxis.drawGridLinesEnabled = false
        xAxis.labelFont = .systemFont(ofSize: 16, weight: .light)
        xAxis.labelTextColor = .lightGray
    }

    @IBAction func btnSettingsTownDown(_ sender: Any) {
        print("Settings page requested")
        let settingsVC = self.storyboard!.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        self.present(settingsVC, animated: true, completion: nil)
    }
    
    func modelManager(didReceiveSentence nmeaObj: NMEA_BASE) {
    }
    
    func modelManager(didReceiveSystemMessage message: String, of type: MessageType) {
        // TODO: Need to find a way to show error
    }
    
    func modelManager(didReceiveWind wind: Wind) {
        DispatchQueue.main.async {
            self.aparentWindAngle.value = wind.AWA
            self.aparentWindSpeed.value = wind.AWS
            self.aparentWindDirection.value = self.modelManager?.geomagneticField?.trueToMagnetic(trueDegree: wind.AWD) ?? wind.AWD
            self.trueWindAngle.value = wind.TWA
            self.trueWindSpeed.value = wind.TWS
            self.trueWindDirection.value =  self.modelManager?.geomagneticField?.trueToMagnetic(trueDegree: wind.TWD) ??  wind.TWD
        }
    }
    
    func modelManager(didReceiveWindHistory windHistory: [WindAggregate]) {
        var valuesTWD: [ChartDataEntry] = []
        var valuesTWS: [ChartDataEntry] = []
        var valuesMaxTWS: [ChartDataEntry] = []
        let geomagneticField = self.modelManager?.geomagneticField
        
        for wind in windHistory {
            let twdMag = (geomagneticField?.trueToMagnetic(trueDegree: wind.TWD) ?? wind.TWD).rounded(toPlaces: 0)
            valuesTWD.append(ChartDataEntry(x: twdMag, y: wind.hoursSince))
            valuesTWS.append(ChartDataEntry(x: wind.TWS, y: wind.hoursSince))
            valuesMaxTWS.append(ChartDataEntry(x: wind.maxTWS, y: wind.hoursSince))
        }

        var twdMaxLeftAxis = ceil(valuesTWD.first?.y ?? 1.0)
        if twdMaxLeftAxis == 0.0 {
            twdMaxLeftAxis = 1.0
        }
        var twsMaxLeftAxis = ceil(valuesTWS.first?.y ?? 0.0)
        if twsMaxLeftAxis == 0.0 {
            twsMaxLeftAxis = 1.0
        }

        let twdDataSet = ScatterChartDataSet(values: valuesTWD, label: "TWD")
        twdDataSet.setScatterShape(.circle)
        twdDataSet.scatterShapeSize = 5
        twdDataSet.setColor(.white)
        
        let twsDataSet = ScatterChartDataSet(values: valuesTWS, label: "TWS")
        twsDataSet.setScatterShape(.circle)
        twsDataSet.scatterShapeSize = 5
        twsDataSet.setColor(.white)

        let maxTwsDataSet = ScatterChartDataSet(values: valuesMaxTWS, label: "MAXTWS")
        maxTwsDataSet.setScatterShape(.circle)
        maxTwsDataSet.scatterShapeSize = 5
        maxTwsDataSet.setColor(.red)

        
        let twdData = ScatterChartData(dataSet: twdDataSet)
        twdData.setDrawValues(false)

        let twsData = ScatterChartData(dataSets: [twsDataSet, maxTwsDataSet])
        twsData.setDrawValues(false)

        DispatchQueue.main.async {
            self.twdHistoryChart.leftAxis.axisMaximum = twdMaxLeftAxis
            self.twdHistoryChart.data = twdData
            self.twdHistoryChart.notifyDataSetChanged()
            
            self.twsHistoryChart.leftAxis.axisMaximum = twsMaxLeftAxis
            self.twsHistoryChart.data = twsData
            self.twsHistoryChart.notifyDataSetChanged()
        }
    }
    
    func modelManager(didReceiveNavigation navigation: Navigation) {
    }
    
    func modelManager(didReceiveNavigationHistory navigationHistory: [NavigationAggregate]) {
    }

}
