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
        
        print("LogViewController: viewDidLoad")
        configureCOGHistoryChart()
        configureHDGHistoryChart()
        configureSOGHistoryChart()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("LogViewController: viewWillAppear")
        
        modelManager?.setDelegate(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("LogViewController: viewWillDisappear")
    }
    
    @IBAction func btnSettingsTouchDown(_ sender: Any) {
        print("Settings page requested")
        let settingsVC = self.storyboard!.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        self.present(settingsVC, animated: true, completion: nil)
    }
    
    func configureCOGHistoryChart() {
        cogChart.chartDescription?.enabled = false
        cogChart.dragEnabled = true
        cogChart.setScaleEnabled(true)
        cogChart.pinchZoomEnabled = false
        cogChart.rightAxis.enabled = false
        cogChart.legend.enabled = false
        
        let leftAxis = cogChart.leftAxis
        leftAxis.labelPosition = .outsideChart
        leftAxis.drawBottomYLabelEntryEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.labelFont = .systemFont(ofSize: 16, weight: .light)
        leftAxis.labelTextColor = .lightGray
        
        let xAxis = cogChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = true
        xAxis.labelFont = .systemFont(ofSize: 16, weight: .light)
        xAxis.labelTextColor = .lightGray
    }
    
    func configureHDGHistoryChart() {
        hdgChart.chartDescription?.enabled = false
        hdgChart.dragEnabled = true
        hdgChart.setScaleEnabled(true)
        hdgChart.pinchZoomEnabled = false
        hdgChart.rightAxis.enabled = false
        hdgChart.legend.enabled = false
        
        let leftAxis = hdgChart.leftAxis
        leftAxis.labelPosition = .outsideChart
        leftAxis.drawBottomYLabelEntryEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.labelFont = .systemFont(ofSize: 16, weight: .light)
        leftAxis.labelTextColor = .lightGray
        
        let xAxis = hdgChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = true
        xAxis.labelFont = .systemFont(ofSize: 16, weight: .light)
        xAxis.labelTextColor = .lightGray
    }

    func configureSOGHistoryChart() {
        sogChart.chartDescription?.enabled = false
        sogChart.dragEnabled = true
        sogChart.setScaleEnabled(true)
        sogChart.pinchZoomEnabled = false
        sogChart.rightAxis.enabled = false
        sogChart.legend.enabled = false
        
        let leftAxis = sogChart.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.labelPosition = .outsideChart
        leftAxis.drawBottomYLabelEntryEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.labelFont = .systemFont(ofSize: 16, weight: .light)
        leftAxis.labelTextColor = .lightGray
        
        let xAxis = sogChart.xAxis
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
        
        for nav in navigationHistory {
            valuesCOG.append(ChartDataEntry(x: nav.hoursSince, y: nav.COG))
            valuesHDG.append(ChartDataEntry(x: nav.hoursSince, y: nav.HDG))
            valuesSOG.append(ChartDataEntry(x: nav.hoursSince, y: nav.SOG))
        }
        
        var xAxisMax =  ceil(valuesCOG.last?.x ?? 1.0)
        if xAxisMax == 0.0 {
            xAxisMax = 1.0
        }

        let cogDataSet = LineChartDataSet(values: valuesCOG, label: "COG")
        cogDataSet.drawCirclesEnabled = false
        cogDataSet.lineWidth = 2
        cogDataSet.setColor(.white)

        let hdgDataSet = LineChartDataSet(values: valuesHDG, label: "HDG")
        hdgDataSet.drawCirclesEnabled = false
        hdgDataSet.lineWidth = 2
        hdgDataSet.setColor(.white)

        let sogDataSet = LineChartDataSet(values: valuesSOG, label: "SOG")
        sogDataSet.drawCirclesEnabled = false
        sogDataSet.lineWidth = 2
        sogDataSet.setColor(.white)


        let cogData = LineChartData(dataSet: cogDataSet)
        //cogData.setDrawValues(false)

        let hdgData = LineChartData(dataSet: hdgDataSet)
        hdgData.setDrawValues(false)

        let sogData = LineChartData(dataSet: sogDataSet)
        sogData.setDrawValues(false)

        
        DispatchQueue.main.async {
            self.cogChart.xAxis.axisMinimum = 0
            self.cogChart.xAxis.axisMaximum = xAxisMax
            self.cogChart.data = cogData
            self.cogChart.notifyDataSetChanged()

            self.hdgChart.xAxis.axisMinimum = 0
            self.hdgChart.xAxis.axisMaximum = xAxisMax
            self.hdgChart.data = hdgData
            self.hdgChart.notifyDataSetChanged()

            self.sogChart.xAxis.axisMinimum = 0
            self.sogChart.xAxis.axisMaximum = xAxisMax
            self.sogChart.data = sogData
            self.sogChart.notifyDataSetChanged()
        }
    }

}
