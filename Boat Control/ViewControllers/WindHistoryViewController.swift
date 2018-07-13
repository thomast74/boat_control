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
    @IBOutlet weak var twdHistoryChart: LineChartView!
    @IBOutlet weak var twsHistoryChart: LineChartView!
    
    
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
        twdHistoryChart.clearValues()
        twsHistoryChart.clearValues()
    }
    
    func configure(chart: LineChartView) {
        chart.chartDescription?.enabled = false
        chart.dragEnabled = true
        chart.setScaleEnabled(true)
        chart.pinchZoomEnabled = false
        chart.rightAxis.enabled = false
        chart.legend.enabled = false
        
        let leftAxis = chart.leftAxis
        leftAxis.labelPosition = .outsideChart
        leftAxis.drawBottomYLabelEntryEnabled = false
        leftAxis.drawGridLinesEnabled = true
        leftAxis.labelFont = .systemFont(ofSize: 16, weight: .light)
        leftAxis.labelTextColor = .lightGray
        
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
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
        var valuesAvgTWS: [ChartDataEntry] = []
        var valuesMaxTWS: [ChartDataEntry] = []
        var valuesMinTWS: [ChartDataEntry] = []
        let geomagneticField = self.modelManager?.geomagneticField
        
        let hoursSinceMax = windHistory.max { (w1, w2) -> Bool in
            return w1.hoursSince < w2.hoursSince
        }?.hoursSince ?? 1.0
        
        for wind in windHistory {
            let twdMag = (geomagneticField?.trueToMagnetic(trueDegree: wind.TWD) ?? wind.TWD).rounded(toPlaces: 0)
            valuesTWD.append(ChartDataEntry(x: hoursSinceMax - wind.hoursSince, y: twdMag))
            valuesAvgTWS.append(ChartDataEntry(x: hoursSinceMax - wind.hoursSince, y: wind.avgTWS))
            valuesMaxTWS.append(ChartDataEntry(x: hoursSinceMax - wind.hoursSince, y: wind.maxTWS))
            valuesMinTWS.append(ChartDataEntry(x: hoursSinceMax - wind.hoursSince, y: wind.minTWS))
        }
        
        let twdDataSet = getLineChartDataSet(data: valuesTWD, label: "TWD", color: .white)
        let twsAvgDataSet = getLineChartDataSet(data: valuesAvgTWS, label: "TWSAVG", color: .white)
        let twsMaxDataSet = getLineChartDataSet(data: valuesMaxTWS, label: "TWSMAX", color: .red)
        let twsMinDataSet = getLineChartDataSet(data: valuesMinTWS, label: "TWSMIN", color: .green)

        let twdData = LineChartData(dataSet: twdDataSet)
        twdData.setDrawValues(false)

        let twsData = LineChartData(dataSets: [twsAvgDataSet, twsMaxDataSet, twsMinDataSet])
        twsData.setDrawValues(false)

        DispatchQueue.main.async {
            self.setNewChartData(chart: self.twdHistoryChart, data: twdData, xAxisMax: hoursSinceMax, leftAxisMin: nil, leftAxisMax: nil)
            self.setNewChartData(chart: self.twsHistoryChart, data: twsData, xAxisMax: hoursSinceMax, leftAxisMin: 0, leftAxisMax: nil)
        }
    }
    
    func modelManager(didReceiveNavigation navigation: Navigation) {
    }
    
    func modelManager(didReceiveNavigationHistory navigationHistory: [NavigationAggregate]) {
    }
    
    private func getLineChartDataSet(data: [ChartDataEntry], label: String, color: NSUIColor) -> LineChartDataSet {
        let dataSet = LineChartDataSet(values: data, label: label)
        dataSet.mode = .cubicBezier
        dataSet.drawCirclesEnabled = false
        dataSet.lineWidth = 2
        dataSet.setColor(color)
        
        return dataSet
    }

    
    private func setNewChartData(chart: LineChartView, data: LineChartData, xAxisMax: Double, leftAxisMin: Double?, leftAxisMax: Double?) {
        if leftAxisMin != nil {
            chart.leftAxis.axisMinimum = leftAxisMin!
        }
        if leftAxisMax != nil {
            chart.leftAxis.axisMaximum = leftAxisMax!
        }
        
        chart.clearValues()
        chart.xAxis.axisMinimum = 0
        chart.xAxis.valueFormatter = ReverseValueFormatter(maxValue: xAxisMax)
        chart.data = data
        chart.notifyDataSetChanged()
    }


}
