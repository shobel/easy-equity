//
//  CashflowChart.swift
//  stonks
//
//  Created by Samuel Hobel on 8/16/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class CashflowChart: BarChartView {

    private var financialDelegate: FinancialsViewController!
    private var company:Company!
           
    public func setup(company:Company, financialDelegate: FinancialsViewController){
        self.delegate = delegate
        self.financialDelegate = financialDelegate
        self.company = company
               
        self.chartDescription?.enabled = false
        self.legend.enabled = true // legend
        self.dragEnabled = false
        self.setScaleEnabled(false)
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
        self.autoScaleMinMaxEnabled = true
            
        self.leftAxis.drawGridLinesEnabled = false
        self.leftAxis.drawAxisLineEnabled = true
        self.leftAxis.enabled = true
        self.leftAxis.valueFormatter = self
        self.rightAxis.enabled = false
                    
        self.xAxis.valueFormatter = self
        self.xAxis.enabled = true
        self.xAxis.axisMinimum = -0.5
        self.xAxis.drawGridLinesEnabled = false
        self.xAxis.labelPosition = .bottom
        self.xAxis.granularity = 1
        self.xAxis.drawAxisLineEnabled = true
        self.xAxis.wordWrapEnabled = true
            
        //self.drawBarShadowEnabled = true
        self.extraTopOffset = 10 //isnt doing anything
        self.extraBottomOffset = 20
        self.setChartData()
    }
             
    private func setChartData(){
        if let cf = self.company.cashflow {
            var incomeBarChartEntries:[BarChartDataEntry] = []
            var cashflowBarChartEntries:[BarChartDataEntry] = []
            for i in 0..<cf.count {
                let cashflowEntry = cf[i]
                incomeBarChartEntries.append(BarChartDataEntry(x: Double(i), y: Double(cashflowEntry.netIncome!)))
                cashflowBarChartEntries.append(BarChartDataEntry(x: Double(i), y: Double(cashflowEntry.cashFlow!)))
            }
            
            let incomeset = BarChartDataSet(entries: incomeBarChartEntries)
            let cashflowset = BarChartDataSet(entries: cashflowBarChartEntries)
            self.configureDataSet(dataset: incomeset, label: "Income")
            self.configureDataSet(dataset: cashflowset, label: "Cashflow")
                
            DispatchQueue.main.async {
                let data = BarChartData()
                data.addDataSet(incomeset)
                data.addDataSet(cashflowset)
                data.groupBars(fromX: Double(0), groupSpace: 0.3, barSpace: 0.05)

                data.barWidth = 0.4
                self.data = data
                self.notifyDataSetChanged()
            }
        }
    }
    
    func configureDataSet(dataset: BarChartDataSet, label:String) {
        dataset.valueTextColor = Constants.darkGrey
        dataset.drawValuesEnabled = true
        dataset.highlightEnabled = false
        dataset.valueFormatter = self
        dataset.valueFont = UIFont(name: "Futura-Bold", size: 12)!
        dataset.label = label
    }
}

extension CashflowChart: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        //return xlabels[Int(value) % xlabels.count]
        return NumberFormatter.formatNumber(num: value)
    }
}

extension CashflowChart: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return NumberFormatter.formatNumber(num: value)
    }
}

