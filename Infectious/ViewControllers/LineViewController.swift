//
//  LineViewController.swift
//  Infectious
//
//  Created by Thomas Hartmann on 3/22/20.
//  Copyright © 2020 Thomas Hartmann. All rights reserved.
//

//
//  LineDemoViewController.swift
//  ChartsDemo-OSX
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts

import Foundation
import Cocoa
import Charts

var chartVC = NSViewController()
var lineViewUpdateTimer = Timer()

open class LineViewController: NSViewController {
    @IBOutlet var lineChartView: LineChartView!
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        chartVC = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.start), name: Notification.Name(rawValue: "start"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.stop), name: Notification.Name(rawValue: "stop"), object: nil)
    }
    
    override open func viewWillAppear() {
        
        self.lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        self.lineChartView.chartDescription?.text = "spatial temporal SIRD population data"
        //lineChartView.AxisBase.  setDrawGridLines = false
        var axis = lineChartView.xAxis as AxisBase
        axis.drawGridLinesEnabled = false
        axis.axisMinimum = 0.0
        
        axis = lineChartView.getAxis(.left)
        axis.drawGridLinesEnabled = false
        
        axis = lineChartView.getAxis(.right)
        axis.drawGridLinesEnabled = false
        axis.drawLabelsEnabled = false
        axis.drawAxisLineEnabled = false
        
        //print(lineChartView.xAxis as? AxisBase)
        startUpdateTimer()
    }
    
    func startUpdateTimer() {
        lineViewUpdateTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            
            if animationIsRunning { self.updateChartData() }
        }
    }
    
    func stopUpdateTimer() {
        if lineViewUpdateTimer.isValid { lineViewUpdateTimer.invalidate() }
        
    }
    
    @objc func stop()  {
        print("received stop")
        stopUpdateTimer()
    }
    
    @objc func start()  {
        print("received start")
        lineChartView.data?.clearValues()
        lineChartView.setNeedsDisplay(self.view.frame)
        startUpdateTimer()
    }
    
     func updateChartData() {

        let data = LineChartData()

        var sEntries : [ChartDataEntry] = []
        var iEntries : [ChartDataEntry] = []
        var rEntries : [ChartDataEntry] = []
        var dEntries : [ChartDataEntry] = []

        for e in sir {
            let x = Double(e.x)
            var val = ChartDataEntry(x: x, y: Double(e.s))
            sEntries.append(val)
            
            val = ChartDataEntry(x: x, y: Double(e.i))
            iEntries.append(val)

            val = ChartDataEntry(x: x, y: Double(e.r))
            rEntries.append(val)

            val = ChartDataEntry(x: x, y: Double(e.d))
            dEntries.append(val)
        }
        
        let ds1 = LineChartDataSet(entries: sEntries, label: "Susceptible")
        //ds1.circleColors = [NSUIColor.red]
        ds1.circleRadius = 1.0
        ds1.setCircleColor(NSUIColor.gray)
        ds1.setColor(NSUIColor.gray)
        
        data.addDataSet(ds1)
        
        let ds2 = LineChartDataSet(entries: iEntries, label: "Infected")
        ds2.circleRadius = 1.0
        ds2.setCircleColor(NSUIColor.red)
        ds2.setColor(NSUIColor.red)
        data.addDataSet(ds2)
        
        let dsR = LineChartDataSet(entries: rEntries, label: "Recovered")
        dsR.circleRadius = 1.0
        dsR.setCircleColor(NSUIColor.blue)
        dsR.setColor(NSUIColor.blue)
        data.addDataSet(dsR)
        
        let dsD = LineChartDataSet(entries: dEntries, label: "Dead")
        dsD.circleRadius = 1.0
        dsD.setCircleColor(NSUIColor.black)
        dsD.setColor(NSUIColor.black)
        data.addDataSet(dsD)

        self.lineChartView.data = data
        //self.lineChartView.gridBackgroundColor = NSUIColor.white
    }
}
