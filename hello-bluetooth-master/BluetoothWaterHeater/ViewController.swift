import UIKit

class ViewController: UIViewController {
    var simpleBluetoothIO: SimpleBluetoothIO!
    
    
    var heaterStatusOn : Bool = false
    var curTemp : Float = 40.0
    let offset : CGFloat = 82
    var tempNumber : Int8 = 0
    let step: Float = 15
    let rate: Double = 2.5 / 10.0
    var ece: Double = 0.0;
    var efe: Double = 0.0;
    //var data: [[String]] = [[]]

    //@IBOutlet weak var ledToggleButton: UIButton!
    
    @IBOutlet weak var startDisplay: UILabel!
    
    @IBOutlet weak var heaterToggleButton: UIButton!
    
    @IBOutlet weak var curDisplay: UILabel!
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var curSlider: UISlider!{
        didSet{
            curSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        }
    }
    
    @IBOutlet weak var slider: UISlider!{
        didSet{
            slider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        }
    }
    @IBOutlet weak var pledDisplay: UILabel!
    
    @IBOutlet weak var etnDisplay: UILabel!
    
    @IBOutlet weak var cedDisplay: UILabel!
    
    @IBOutlet weak var EnergyConsumption: UILabel!
    
    @IBOutlet weak var energyEfficiency: UILabel!
    
    @IBOutlet weak var taskSlider: UISlider!
    
    @IBOutlet weak var taskDisplay: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up the heater button display
        heaterToggleButton.setTitle("On", for: .selected)
        heaterToggleButton.setBackgroundImage(#imageLiteral(resourceName: "bg_button_enabled"), for: .selected)
        heaterToggleButton.setTitle("Off", for: .normal)
        heaterToggleButton.setBackgroundImage(#imageLiteral(resourceName: "bg_button_disabled"), for: .normal)
        
        updateDisplay(display)
        updateCurDisplay(curDisplay)
        displayAsTemp(startDisplay, 40.0)
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let minOut : String;
        //let mins = (minutes + Int(sender.value)) % 60
        //print(mins)
        if (minutes < 10) {
            minOut = "\("0")\(minutes)"
        } else {
            minOut = String(minutes)
        }
        
        
        //convertCSV(file: "CAISO-demand-1.csv")
        var data = readDataFromCSV(fileName: "CAISO-demand-1", fileType: "csv")
        data = cleanRows(file: data!)
        let csvRows = csv(data: data!)
        print(csvRows[1][1]) // UXM n. 166/167
        
        taskDisplay.text = "\(hour):\(minOut)"
        determineCED(data: csvRows)
        determinePLED(data: csvRows)
        determineETN()
        
        print("beginning bluetooth search")

        simpleBluetoothIO = SimpleBluetoothIO(serviceUUID: "19B10010-E8F2-537E-4F6C-D104768A1214", delegate: self)
        
        print("ending bluetooth search")
    }
    
    @IBAction func heaterToggleButtonDown(_ sender: Any) {
        if (!heaterStatusOn) {
            simpleBluetoothIO.writeValue(value: Int8(Int(slider.value)))
            heaterStatusOn = true
            heaterToggleButton.isSelected = true
        } else {
            simpleBluetoothIO.writeValue(value: 0)
            heaterStatusOn = false
            heaterToggleButton.isSelected = false
            EnergyConsumption.text = "0.0 kw/hr"
            energyEfficiency.text = "0.0%"
        }
    }
    
    @IBAction func updateValue(_ sender: UISlider) {
        sender.value = max(sender.value, curSlider.value)
        updateDisplay(display)
        determineETN()
        if (heaterStatusOn) {
            let toWrite = Int8(min(127, (sender.value)))
            simpleBluetoothIO.writeValue(value: toWrite)
        }
    }
    
    @IBAction func updateTaskSlider(_ sender: UISlider) {
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let minOut : String;
        let mins = max(0, (minutes + Int(sender.value)) % 60)
        print(mins)
        if (mins < 10) {
            minOut = "\("0")\(mins)"
        } else {
            minOut = String(mins)
        }
        print("hours = \(hour):\(minOut)")
        taskDisplay.text = ("\((hour + ((Int(sender.value) + minutes) / 60)) % 24):\(minOut)")
    }
    
    private func displayAsTemp(_ d: UILabel, _ f : Float) {
        d.text = String(round(f * 10.0) / 10.0) + " °F"
    }
    
    private func updateDisplay(_ display: UILabel) {
        displayAsTemp(display, slider.value)
        display.center = CGPoint(x: slider.center.x - (offset), y: CGFloat(890 - 4.2 * slider.value))
    }
    
    private func updateCurDisplay(_ display: UILabel) {
        displayAsTemp(display, curTemp)
        display.center = CGPoint(x: curSlider.center.x + (offset), y: CGFloat(890 - 4.2 * curSlider.value))
    }
    
    func updateCurTempSlider() {
        curSlider.value = curTemp
        updateCurDisplay(curDisplay)
        determineETN()
        if (heaterStatusOn) {
            EnergyConsumption.text = "\(ece) kW/hr"
            energyEfficiency.text = "\(efe)%"
        }
    }
    
    private func readDataFromFile(file:String)-> String!{
        guard let filepath = Bundle.main.path(forResource: file, ofType: "csv")
            else {
                return nil
        }
        do {
            let contents = try String(contentsOfFile: filepath)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    private func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
    
    func getStringFieldsForRow(row:String, delimiter:String)-> [String]{
        //return row.componentsSeparatedByString(delimiter)
        return row.components(separatedBy: delimiter)
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    func determineCED(data: [[String]]) {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = (calendar.component(.minute, from: date)) / 5 * 5
        let str = Int(data[2][Int(hour / 12 + minutes / 5 + 1)])
        let val : String;
        if (str! < 20000) {
            val = "LOW"
            cedDisplay.textColor = UIColor.cyan
        } else if (str! < 21000) {
            val = "MEDIUM"
            cedDisplay.textColor = UIColor.white
        } else {
            val = "HIGH"
            cedDisplay.textColor = UIColor.red
        }
        cedDisplay.text = val
    }
    
    private func determinePLED(data: [[String]]) {
        var max = 0
        var index = 0
        for i in 1..<((data[2]).count) {
            if (max < Int(data[2][i])!) {
                max = Int(data[2][i])!
                index = i
            }
        }
        pledDisplay.text = data[0][index]
    }
    
    private func determineETN() {
        var mins = max(0, Int(Double(slider.value - curSlider.value) / rate))
        let hours = mins / 60
        mins = mins % 60
        let minOut : String;
        if (mins < 10) {
            minOut = "\("0")\(mins)"
        } else {
            minOut = String(mins)
        }
        etnDisplay.text = String("\(hours):\(minOut)")
    }
}

extension ViewController: SimpleBluetoothIODelegate {
    func simpleBluetoothIO(simpleBluetoothIO: SimpleBluetoothIO, didReceiveValue value: Int8) {
        print(value)
        if (tempNumber == 0) {
            startDisplay.text = String(Float(value))
            tempNumber = 1
        }
        else {
            if (value >= 40 && value <= 150) {
                print("In the if statement")
                curTemp = Float(value)
                updateCurTempSlider()
        }   else if (value < 10){
                ece = Double(value) / 2.768;
            } else {
                efe = Double(value) / 1.592 * 100.0;
            }
        }
    }
}
