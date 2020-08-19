import Foundation
import Charts

class BigNumberAxisFormatter: IAxisValueFormatter {
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if abs(value) > 999999999 {
            return String(NumberFormatter.formatNumberWithPossibleDecimal(value/1000000000)) + "B"
        }
        if abs(value) > 999999 {
            return String(NumberFormatter.formatNumberWithPossibleDecimal(value/1000000)) + "M"
        }
        if abs(value) > 999 {
            return String(NumberFormatter.formatNumberWithPossibleDecimal(value/1000)) + "K"
        }
        if (value - floor(value) > 0.000001) { // 0.000001 can be changed depending on the level of precision you need
            return String(format: "%.2f", value)
        }
        return String(format: "%.0f", value)
    }
}
