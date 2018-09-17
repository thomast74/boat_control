//
//  LogViewController.swift
//  Boat Control
//
//  Created by Thomas Trageser on 09/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import UIKit
import Charts

class NavigationLogViewController: UIViewController, ModelManagerDelegate {

    var modelManager: ModelManager?

    @IBOutlet weak var cogChart: LineChartView!
    @IBOutlet weak var hdgChart: LineChartView!
    @IBOutlet weak var sogChart: LineChartView!
    @IBOutlet weak var brpChart: LineChartView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("NavigationLogViewController: viewDidLoad")
        configure(chart: cogChart)
        configure(chart: hdgChart)
        configure(chart: sogChart)
        configure(chart: brpChart)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("NavigationLogViewController: viewWillAppear")
        
        modelManager?.setDelegate(self)
        modelManager?.sendCurrentData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("NavigationLogViewController: viewWillDisappear")
        cogChart.clearValues()
        hdgChart.clearValues()
        sogChart.clearValues()
        brpChart.clearValues()
    }
    
    @IBAction func btnSettingsTouchDown(_ sender: Any) {
        print("Settings page requested")
        let settingsVC = self.storyboard!.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        self.present(settingsVC, animated: true, completion: nil)
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

    func modelManager(didReceiveSentence nmeaObj: NMEA_BASE) {
    }
    
    func modelManager(didReceiveSystemMessage message: String, of type: MessageType) {
        // TODO: Need to find a way to show error
    }
    
    func modelManager(didReceiveWind wind: Wind) {
    }
    
    func modelManager(didReceiveWindHistory windHistory: [WindAggregate]) {
    }
    
    func modelManager(didReceiveNavigation navigation: Navigation) {
    }
    
    func modelManager(didReceiveNavigationHistory navigationHistory: [NavigationAggregate]) {
        var valuesCOG: [ChartDataEntry] = []
        var valuesHDG: [ChartDataEntry] = []
        var valuesAvgSOG: [ChartDataEntry] = []
        var valuesMaxSOG: [ChartDataEntry] = []
        var valuesMinSOG: [ChartDataEntry] = []
        var valuesBPR: [ChartDataEntry] = []

        for nav in navigationHistory {
            valuesCOG.append(ChartDataEntry(x: nav.hoursSince, y: nav.COG))
            valuesHDG.append(ChartDataEntry(x: nav.hoursSince, y: nav.HDG))
            valuesAvgSOG.append(ChartDataEntry(x: nav.hoursSince, y: nav.avgSOG))
            valuesMaxSOG.append(ChartDataEntry(x: nav.hoursSince, y: nav.maxSOG))
            valuesMinSOG.append(ChartDataEntry(x: nav.hoursSince, y: nav.minSOG))
            if nav.BPR > 0 {
                valuesBPR.append(ChartDataEntry(x: nav.hoursSince, y: nav.BPR))
            }
        }
        
        let avgSOGDataSet = getLineChartDataSet(data: valuesAvgSOG, label: "AVGSOG", color: .white)
        let maxSOGDataSet = getLineChartDataSet(data: valuesMaxSOG, label: "MAXSOG", color: .red)
        let minSOGDataSet = getLineChartDataSet(data: valuesMinSOG, label: "MINSOG", color: .green)

        let cogData = getLineChartData(data: valuesCOG, label: "COG")
        let hdgData = getLineChartData(data: valuesHDG, label: "HDG")
        let bprData = getLineChartData(data: valuesBPR, label: "BPR")

        let sogData = LineChartData(dataSets: [avgSOGDataSet, maxSOGDataSet, minSOGDataSet])
        sogData.setDrawValues(false)

        DispatchQueue.main.async {
            self.setNewChartData(chart: self.cogChart, data: cogData, leftAxisMin: nil, leftAxisMax: nil)
            self.setNewChartData(chart: self.hdgChart, data: hdgData, leftAxisMin: nil, leftAxisMax: nil)
            self.setNewChartData(chart: self.sogChart, data: sogData, leftAxisMin: 0, leftAxisMax: nil)
            if valuesBPR.count > 0 {
                self.setNewChartData(chart: self.brpChart, data: bprData, leftAxisMin: nil, leftAxisMax: nil)
            }
        }
    }

    private func getLineChartDataSet(data: [ChartDataEntry], label: String, color: NSUIColor) -> LineChartDataSet {
        
        let dataSet = LineChartDataSet(values: data, label: label)
        //dataSet.mode = .cubicBezier
        dataSet.drawCirclesEnabled = false
        dataSet.lineWidth = 2
        dataSet.setColor(color)
        
        return dataSet
    }

    private func getLineChartData(data: [ChartDataEntry], label: String) -> LineChartData {
        let dataSet = getLineChartDataSet(data: data, label: label, color: .white)
        
        let chartData = LineChartData(dataSet: dataSet)
        chartData.setDrawValues(false)

        return chartData
    }
    
    private func setNewChartData(chart: LineChartView, data: LineChartData, leftAxisMin: Double?, leftAxisMax: Double?) {
        if leftAxisMin != nil {
            chart.leftAxis.axisMinimum = leftAxisMin!
        }
        if leftAxisMax != nil {
            chart.leftAxis.axisMaximum = leftAxisMax!
        }

        chart.clearValues()
        chart.xAxis.valueFormatter = ReverseValueFormatter()
        chart.data = data
        chart.notifyDataSetChanged()
    }

}
