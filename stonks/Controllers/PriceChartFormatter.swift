import Foundation
import Charts

class PriceChartFormatter: NSObject, IAxisValueFormatter {
    
    private var xAxisLabels:[String] = []
    private var xAxisLabelsFull:[String] = []
    private var xAxisLabelsTenMin:[String] = []
    
    public func setXAxisLabelsFull(_ labels:[String]){
        xAxisLabelsFull = labels
    }
    
    public func setXAxisLabelsTenMin(_ labels:[String]){
        xAxisLabelsTenMin = labels
    }
    
    public func resetXAxisLabels(){
        xAxisLabels.removeAll()
        xAxisLabelsFull.removeAll()
        xAxisLabelsTenMin.removeAll()
    }
    
    public func addXAxisLabelFull(_ value: String){
        xAxisLabelsFull.append(value)
    }
    
    public func addXAxisLabelTenMin(_ value: String){
        xAxisLabelsTenMin.append(value)
    }
    
    public func setActiveLabels(_ active: String) {
        if active == "line" {
            xAxisLabels = xAxisLabelsFull
        } else if active == "candle" {
            xAxisLabels = xAxisLabelsTenMin
        }
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if xAxisLabels.count > Int(value) {
            return xAxisLabels[Int(value)]
        }
        return ""
    }
}
