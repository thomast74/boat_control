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
        configure(chart: twdHistoryChart)
        configure(chart: twsHistoryChart)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("WindHistoryViewController: viewWillAppear")
        
        modelManager?.setDelegate(self)
        modelManager?.sendCurrentData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("WindHistoryViewController: viewWillDisappear")
    }
    
    func configure(chart: ScatterChartView) {
        chart.chartDescription?.enabled = false
        chart.dragEnabled = true
        chart.setScaleEnabled(true)
        chart.pinchZoomEnabled = false
        chart.rightAxis.enabled = false
        chart.legend.enabled = false

        let leftAxis = chart.leftAxis
        leftAxis.inverted = true
        leftAxis.labelPosition = .outsideChart
        leftAxis.drawBottomYLabelEntryEnabled = false
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.labelFont = .systemFont(ofSize: 16, weight: .light)
        leftAxis.labelTextColor = .lightGray
        
        let xAxis = chart.xAxis
        xAxis.labelPosition = .top
        xAxis.drawGridLinesEnabled = true
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

        var leftAxisMax = ceil(valuesTWD.first?.y ?? 1.0)
        if leftAxisMax == 0.0 {
            leftAxisMax = 1.0
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
            self.setNewChartData(chart: self.twdHistoryChart, data: twdData, leftAxisMax: leftAxisMax, leftAxisMin: nil)
            self.setNewChartData(chart: self.twsHistoryChart, data: twsData, leftAxisMax: leftAxisMax, leftAxisMin: 0)
        }
    }
    
    func modelManager(didReceiveNavigation navigation: Navigation) {
    }
    
    func modelManager(didReceiveNavigationHistory navigationHistory: [NavigationAggregate]) {
    }
    
    private func setNewChartData(chart: ScatterChartView, data: ScatterChartData, leftAxisMax: Double, leftAxisMin: Double?) {
        if leftAxisMin != nil {
            chart.leftAxis.axisMinimum = leftAxisMin!
        }
        
        chart.leftAxis.axisMaximum = leftAxisMax
        chart.data = data
        chart.notifyDataSetChanged()
    }


}
