//
//  CashflowChart.swift
//  stonks
//
//  Created by Samuel Hobel on 8/16/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class IncomeChart: BarChartView {

    private var financialDelegate: FinancialsViewController!
    private var company:Company!
    private var xLabels:[String] = []
    private enum ChartMode {
        case REVENUE, NETINCOME, OPERATINGINCOME
    }
    private var chartMode: ChartMode = ChartMode.REVENUE
           
    public func setup(company:Company, financialDelegate: FinancialsViewController){
        self.delegate = delegate
        self.financialDelegate = financialDelegate
        self.company = company
               
        self.chartDescription?.enabled = false
        self.legend.enabled = false
        self.dragEnabled = false
        self.setScaleEnabled(false)
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
        self.autoScaleMinMaxEnabled = true
            
        self.leftAxis.drawGridLinesEnabled = false
        self.leftAxis.drawAxisLineEnabled = true
        self.leftAxis.enabled = true
        self.leftAxis.valueFormatter = BigNumberAxisFormatter()
        self.leftAxis.drawZeroLineEnabled = true
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
//        self.extraTopOffset = 0
        self.extraBottomOffset = 15
        self.setChartData()
    }
             
    private func setChartData(){
        self.xLabels = []
        var colors:[UIColor] = []
        if let inc = self.company.income {
            let inc = Array(inc.reversed())
            var barChartEntries:[BarChartDataEntry] = []
            for i in 0..<inc.count {
                let incomeEntry = inc[i]
                var val:Int = 0
                self.xLabels.append(incomeEntry.reportDate!)
                if self.chartMode == ChartMode.NETINCOME {
                    val = incomeEntry.netIncome!
                } else if self.chartMode == ChartMode.OPERATINGINCOME {
                    val = incomeEntry.operatingIncome!
                } else if self.chartMode == ChartMode.REVENUE{
                    val = incomeEntry.totalRevenue!
                }
                barChartEntries.append(BarChartDataEntry(x: Double(i), y: Double(val)))
                if val > 0 {
                    colors.append(Constants.green)
                } else {
                    colors.append(Constants.darkPink)
                }
            }
            
            let set = BarChartDataSet(entries: barChartEntries)
            set.colors = colors
            self.configureDataSet(dataset: set, label: "Income")
            
            DispatchQueue.main.async {
                let data = BarChartData()
                data.addDataSet(set)
                let percentRange = (data.yMax - data.yMin)*0.2
                self.leftAxis.axisMinimum = data.yMin - percentRange
                if data.yMin > 0 && self.leftAxis.axisMinimum < 0 {
                    self.leftAxis.axisMinimum = 0
                }

                data.barWidth = 0.4
                self.data = data
                self.notifyDataSetChanged()
            }
        }
    }
    
    public func changeChartMode(chartMode:String){
        switch chartMode {
        case "REVENUE":
            self.chartMode = ChartMode.REVENUE
        case "NET INCOME":
            self.chartMode = ChartMode.NETINCOME
        case "OP INCOME":
            self.chartMode = ChartMode.OPERATINGINCOME
        default:
            self.setChartData()
        }
        self.setChartData()
    }
    
    func configureDataSet(dataset: BarChartDataSet, label:String) {
        dataset.valueTextColor = Constants.darkGrey
        dataset.drawValuesEnabled = true
        dataset.highlightEnabled = false
        dataset.valueFormatter = self
        dataset.valueFont = UIFont(name: "Futura", size: 12)!
        dataset.label = label
    }
}

extension IncomeChart: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return xLabels[Int(value) % xLabels.count]
    }
}

extension IncomeChart: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return NumberFormatter.formatNumber(num: value)
    }
}

