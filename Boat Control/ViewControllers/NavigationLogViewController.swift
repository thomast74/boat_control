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
        var valuesSOG: [ChartDataEntry] = []
        var valuesBPR: [ChartDataEntry] = []

        let hoursSinceMax = navigationHistory.max { (w1, w2) -> Bool in
            return w1.hoursSince < w2.hoursSince
            }?.hoursSince ?? 1.0

        for nav in navigationHistory {
            valuesCOG.append(ChartDataEntry(x: hoursSinceMax - nav.hoursSince, y: nav.COG))
            valuesHDG.append(ChartDataEntry(x: hoursSinceMax - nav.hoursSince, y: nav.HDG))
            valuesSOG.append(ChartDataEntry(x: hoursSinceMax - nav.hoursSince, y: nav.SOG))
            if nav.BPR > 0 {
                valuesBPR.append(ChartDataEntry(x: nav.hoursSince, y: nav.BPR))
            }
        }
        
        let cogData = getLineChartData(data: valuesHDG, label: "COG")
        let hdgData = getLineChartData(data: valuesHDG, label: "HDG")
        let sogData = getLineChartData(data: valuesSOG, label: "SOG")
        let bprData = getLineChartData(data: valuesBPR, label: "BPR")
        
        DispatchQueue.main.async {
            self.setNewChartData(chart: self.cogChart, data: cogData, xAxisMax: hoursSinceMax, leftAxisMin: nil, leftAxisMax: nil)
            self.setNewChartData(chart: self.hdgChart, data: hdgData, xAxisMax: hoursSinceMax, leftAxisMin: nil, leftAxisMax: nil)
            self.setNewChartData(chart: self.sogChart, data: sogData, xAxisMax: hoursSinceMax, leftAxisMin: 0, leftAxisMax: nil)
            self.setNewChartData(chart: self.brpChart, data: bprData, xAxisMax: hoursSinceMax, leftAxisMin: nil, leftAxisMax: nil)
        }
    }
    
    private func getLineChartData(data: [ChartDataEntry], label: String) -> LineChartData {
        let dataSet = LineChartDataSet(values: data, label: label)
        dataSet.mode = .cubicBezier
        dataSet.drawCirclesEnabled = false
        dataSet.lineWidth = 2
        dataSet.setColor(.white)
    
        let lineChartData = LineChartData(dataSet: dataSet)
        lineChartData.setDrawValues(false)

        return lineChartData
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
