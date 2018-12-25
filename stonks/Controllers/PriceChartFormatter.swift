import Foundation
import Charts

class PriceChartFormatter: NSObject, IAxisValueFormatter {
    
    private var xAxisLabels:[String] = []
    
    public func setXAxisLabels(_ labels:[String]){
        xAxisLabels = labels
    }
    
    public func resetXAxisLabels(){
        xAxisLabels.removeAll()
    }
    
    public func addXAxisLabel(_ value: String){
        xAxisLabels.append(value)
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if xAxisLabels.count > Int(value) {
            return xAxisLabels[Int(value)]
        }
        return ""
    }
}
