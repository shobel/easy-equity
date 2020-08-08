import Foundation
import Charts

class PriceChartPriceFormatter: IAxisValueFormatter {
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if (value < 0){
            return "0"
        }
        return String(format: "%.2f", Float(value))
    }
}
