import Foundation
import Charts

class VolumeChartFormatter: NSObject, IAxisValueFormatter {
    
    private var axisLabels:[Double] = []
    
    public func setAxisLabels(_ labels:[Double]){
        axisLabels = labels
    }
    
    public func resetAxisLabels(){
        axisLabels.removeAll()
    }
    
    public func addAxisLabel(_ value: Double){
        axisLabels.append(value)
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if (value < 0){
            return ""
        }
        if value > 0{
            return NumberFormatter.formatNumber(num: axisLabels.max() ?? 0.0)
        } else {
            return ""
        }
    }
}
