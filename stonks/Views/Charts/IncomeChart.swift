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
        case QUARTERLY, ANNUAL
    }
    private var chartMode: ChartMode = ChartMode.QUARTERLY
           
    public func setup(company:Company, financialDelegate: FinancialsViewController){
        self.delegate = delegate
        self.financialDelegate = financialDelegate
        self.company = company
               
        self.chartDescription?.enabled = false
        self.legend.enabled = true
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
                    
        //self.xAxis.valueFormatter = self
        //self.xAxis.labelRotationAngle = CGFloat(45.0)
        self.xAxis.labelFont = UIFont(name: "HelveticaNeue", size: 12.0)!
        self.xAxis.enabled = true
        self.xAxis.axisMinimum = -0.5
        self.xAxis.drawGridLinesEnabled = false
        self.xAxis.labelPosition = .bottom
        self.xAxis.granularityEnabled = true
        self.xAxis.drawAxisLineEnabled = true
        self.xAxis.wordWrapEnabled = false
        self.xAxis.centerAxisLabelsEnabled = true
        self.xAxis.valueFormatter = self
        //self.drawBarShadowEnabled = true
//        self.extraTopOffset = 0
        self.extraBottomOffset = 15
        self.setChartData()
    }
             
    private func setChartData(){
        self.xLabels = []
        var revEntries:[BarChartDataEntry] = []
        var incomeEntries:[BarChartDataEntry] = []
        var opIncEntries:[BarChartDataEntry] = []
        var incomes = self.company.income
        if self.chartMode == ChartMode.ANNUAL {
            incomes = self.company.incomeAnnual
        }
        if var inc = incomes {
            inc = Array(inc.prefix(4)).reversed()
            for i in 0..<inc.count {
                let incomeEntry = inc[i]
                self.xLabels.append(NumberFormatter.formatDateToMonthYearShort(incomeEntry.reportDate!))
                incomeEntries.append(BarChartDataEntry(x: Double(i), y: Double(incomeEntry.netIncome!)))
                revEntries.append(BarChartDataEntry(x: Double(i), y: Double(incomeEntry.totalRevenue!)))
                opIncEntries.append(BarChartDataEntry(x: Double(i), y: Double(incomeEntry.operatingIncome!)))
            }
      
            let incomeSet = BarChartDataSet(entries: incomeEntries)
            self.configureDataSet(dataset: incomeSet, label: "Income", color: Constants.orange)
            let revSet = BarChartDataSet(entries: revEntries)
            self.configureDataSet(dataset: revSet, label: "Revenue", color: Constants.blue)
            let opSet = BarChartDataSet(entries: opIncEntries)
            self.configureDataSet(dataset: opSet, label: "Operating Income", color: Constants.purple)

            DispatchQueue.main.async {
                let data = BarChartData()
                data.addDataSet(revSet)
                data.addDataSet(incomeSet)
                data.addDataSet(opSet)
                
                let groupSpace = 2.0
                let barSpace = 1.0
                let barWidth = 5.0
                
                data.barWidth = barWidth
                let gg = data.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
                self.xAxis.axisMinimum = 0.0
                self.xAxis.axisMaximum = Double(0) + gg * Double(incomeSet.count)
                data.groupBars(fromX: Double(0), groupSpace: groupSpace, barSpace: barSpace)
                self.xAxis.granularity = self.xAxis.axisMaximum / Double(incomeSet.count)

                let percentRange = (data.yMax - data.yMin)*0.2
                self.leftAxis.axisMinimum = data.yMin - percentRange
                if data.yMin > 0 && self.leftAxis.axisMinimum < 0 {
                    self.leftAxis.axisMinimum = 0
                }

                self.data = data
                self.notifyDataSetChanged()
            }
        }
    }
    
    public func changeChartMode(chartMode:String){
        switch chartMode {
        case "QUARTERLY":
            self.chartMode = ChartMode.QUARTERLY
        case "ANNUAL":
            self.chartMode = ChartMode.ANNUAL
        default:
            self.setChartData()
        }
        self.setChartData()
    }
    
    func configureDataSet(dataset: BarChartDataSet, label:String, color: UIColor) {
        dataset.valueTextColor = Constants.darkGrey
        dataset.drawValuesEnabled = true
        dataset.highlightEnabled = false
        dataset.valueFormatter = self
        dataset.valueFont = UIFont(name: "Futura", size: 9)!
        dataset.label = label
        dataset.setColor(color)
    }
}

extension IncomeChart: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let count = self.xLabels.count
        guard let axis = axis, count > 0 else {
            return ""
        }
        let factor = axis.axisMaximum / Double(count)
        let index = Int((value / factor).rounded())
        if index >= 0 && index < count {
            return self.xLabels[index]
        }
        return ""
//        return xLabels[Int(value) % xLabels.count]
    }
}

extension IncomeChart: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return NumberFormatter.formatNumber(num: value)
    }
}

