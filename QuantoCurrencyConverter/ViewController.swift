//
//  ViewController.swift
//  QuantoCurrencyConverter
//
//  Created by Tawanda Kanyangarara on 04/05/2017.
//  Copyright © 2017 Tawanda Kanyangarara. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol citySelectionDelegate {
    func loadCityData(baseArray:Array<String>, destArray:Array<String>,baseCountryKey:String,destCountryKey:String)
    
}

class ViewController: UIViewController, baseDataSentDelegate, destDataSentDelegate, selectedCityDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var cityDelegate: citySelectionDelegate? = nil
    
    var destCityData = [CityData]()
    var baseCityData = [CityData]()
    var baseCapitalData = [CityData]()
    
    var productList:Int!
    var destProdListDict: Dictionary<String, AnyObject>!
    var baseProdListDict: Dictionary<String, AnyObject>!
    var capitalName:String!
    
    var isBaseFull = false
    var isDestFull = false
    
    @IBOutlet weak var productTableView:UITableView!
    var countryCity: Dictionary<String, AnyObject>!
    var cityProds: Dictionary<String, AnyObject>!
    //Operation Buttons
    @IBOutlet weak var divideBtn: UIButton!
    @IBOutlet weak var subtractBtn: UIButton!
    @IBOutlet weak var multiplyBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var decimalBtn: UIButton!
    
    
    @IBOutlet weak var calculationLbl: UILabel!
    
    @IBOutlet weak var baseCurrencyLbl: UILabel!
    
    
    @IBOutlet weak var destinationCurrencyLbl: UILabel!
    

    @IBOutlet weak var destinationCurrencyBtn: UIButton!
    @IBOutlet weak var baseCurrencyBtn: UIButton!
    var baseCities:[String] = []
    var destCities:[String] = []
    @IBOutlet weak var mcmealDestLbl: UILabel!
    @IBOutlet weak var mealDestLbl: UILabel!
    @IBOutlet weak var domBeerDestLbl: UILabel!
    @IBOutlet weak var cokeDestLbl: UILabel!
    
    
    var destCapital:String!
    var productRangeSel: String!
    var cityIndexRow: Int!
    var baseCurrSymbol: String!
    var destCurrSymbol: String!
    
    var destCountryKey:String!
    var baseCountryKey:String!
    var currentRates: CurrentExchange!
    
    var displayRunningNumber = ""
    var runningNumber = ""
    var leftValStr = ""
    var rightValStr = ""
    var result = "0"
    
    enum Operation: String {
        case Divide = "/"
        case Multiply = "*"
        case Subtract = "-"
        case Add = "+"
        case Empty = "Empty"
    }
    
    var currentOperation = Operation.Empty
    
    var buttonsEnabled: Bool!
    var decimalEnabled: Bool!
    
    var baseCurrSel: String!
    var destCurrSel: String!

   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.productList = 0

        
        productTableView.delegate = self
        productTableView.dataSource = self
        
        currentRates = CurrentExchange()
        currentRates.downloadExchangeRates {}
        
        self.decimalEnabled = true
        decimalBtn.isUserInteractionEnabled = true
        
        calculationLbl.text = "0"
        baseCurrencyLbl.text = "0"
        destinationCurrencyLbl.text = "0"
        destinationCurrencyLbl.textColor = UIColor(red:0/255, green:0/255, blue:0/255, alpha:0.2)
        
        self.cokeDestLbl.text = "0"
        self.domBeerDestLbl.text = "0"
        self.mealDestLbl.text = "0"
        self.mcmealDestLbl.text = "0"
        
        
        self.baseCurrencyBtn.contentHorizontalAlignment = .left
        self.destinationCurrencyBtn.contentHorizontalAlignment = .left
        
        self.productRangeSel = "norm"
        
        self.destProdListDict = [:]
        self.baseProdListDict = [:]
        
        self.disableBtns()
        
        if self.destCurrSel == nil || self.baseCurrSel == nil {
            self.destCurrSel = "ZAR"
            self.baseCurrSel = "GBP"
            self.baseCurrencyBtn.setTitle("United Kingdom [GBP]", for: .normal)
            self.destinationCurrencyBtn.setTitle("South Africa [ZAR]", for: .normal)
            
        }
        
    }
    
    @IBAction func citySelVC(_ sender: Any) {

    

    }
    
    @IBAction func productRangePressed(sender: UIButton){

        if self.destCityData.count > 0 && self.baseCityData.count > 0 {
            
        
            if self.cityIndexRow != nil {
                
                if sender.tag == 10{
                    self.productRangeSel = "low"
                    
                    self.getDestCitiesProd(countryKey: self.destCountryKey, cityKey: self.destCities[self.cityIndexRow], productRange: self.productRangeSel)
                    self.getBaseCitiesProd(countryKey: self.baseCountryKey, cityKey: self.baseCities[self.cityIndexRow], productRange: self.productRangeSel)
                    self.globalProdAmount()
                    self.productTableView.reloadData()
                    
                } else if sender.tag == 11 {
                    self.productRangeSel = "norm"
                    self.getDestCitiesProd(countryKey: self.destCountryKey, cityKey: self.destCities[self.cityIndexRow], productRange: self.productRangeSel)
                    self.getBaseCitiesProd(countryKey: self.baseCountryKey, cityKey: self.baseCities[self.cityIndexRow], productRange: self.productRangeSel)
                    self.globalProdAmount()
                    self.productTableView.reloadData()
                } else {
                    self.productRangeSel = "high"
                    self.getDestCitiesProd(countryKey: self.destCountryKey, cityKey: self.destCities[self.cityIndexRow], productRange: self.productRangeSel)
                    self.getBaseCitiesProd(countryKey: self.baseCountryKey, cityKey: self.baseCities[self.cityIndexRow], productRange: self.productRangeSel)
                    self.globalProdAmount()
                    self.productTableView.reloadData()
                    
                }
                
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for:indexPath) as? ProductCell{
                cell.configureProductCell(productRange:self.productRangeSel, baseCurr:self.baseCurrSel, destCurr: self.destCurrSel, destCurrSymbol: self.destCurrSymbol, baseCurrSymbol: self.baseCurrSymbol, indexPath: indexPath.row, baseCityProdList: self.baseProdListDict, destCityProdList: self.destProdListDict)
               
                return cell
            } else {
                return ProductCell()
            }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.baseProdListDict.count == self.destProdListDict.count {
                return self.baseProdListDict.count
        } else {
            return self.baseCityData.count
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func loadSelectedCity(baseCitySel:String,destCitySel:String){
        
        self.getDestCitiesProd(countryKey: self.destCountryKey, cityKey: destCitySel, productRange: self.productRangeSel)
        self.getBaseCitiesProd(countryKey: self.baseCountryKey, cityKey: baseCitySel, productRange: self.productRangeSel)
        
        //
        
        self.productTableView.reloadData()
    }
    func userDidEnterDestData(data: CountryData) {
        self.destCountryKey = data.countryName
        self.destinationCurrencyBtn.setTitle("\(data.countryName) [\(data.currencyCode)]", for: .normal)
        self.destCurrSel = data.currencyCode
        self.destCurrSymbol = data.currencySymbol
        self.destCities = data.cities
        self.destCapital = data.capitalName
        self.getDestCitiesProd(countryKey: data.countryName
            , cityKey: data.capitalName, productRange: self.productRangeSel)
        
        self.globalProdAmount()
        
        
        
    }
    
    func userDidEnterBaseData(data: CountryData) {
        self.baseCountryKey = data.countryName
        self.baseCurrencyBtn.setTitle("\(data.countryName) [\(data.currencyCode)]", for: .normal)
        self.baseCurrSel = data.currencyCode
        self.baseCities = data.cities
        self.baseCurrSymbol = data.currencySymbol
        self.getBaseCitiesProd(countryKey: data.countryName
            , cityKey: data.capitalName, productRange: self.productRangeSel)
        

    }
    
    func getDestCitiesProd(countryKey:String, cityKey: String, productRange: String){
        print("--- running: getDestCitiesProd")
        DataService.ds.REF_CITIES.child(countryKey).observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshot {
                    if let countryCityDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let destCityProdData = CityData(cityName:key, countryName:countryKey, productData:countryCityDict)
                        
                        if self.destCityData.isEmpty {
                            self.destCityData.append(destCityProdData)
                        } else {
                            self.destCityData.removeAll()
                            self.destCityData.append(destCityProdData)
                        }
                        for i in (0..<self.destCityData.count){
                            if (self.destCityData[i].cityName == cityKey) {
                                self.destProdListDict.removeAll()
                                self.destProdListDict = self.destCityData[i].productData

                            }
                        }
                    }
                }
            }
        })
    }
    func productAmount(convAm: Float){
        print("--productAmount")
        if self.cityIndexRow != nil {
            print("--cityIndexRow")
            for i in (0..<self.destCityData.count){
                if (destCityData[i].cityName == self.destCities[self.cityIndexRow])
                {
                    let cokeAmount = convAm / Float("\(self.destCityData[i].coke[self.productRangeSel]!)")!
                    let domBeerAmount = convAm / Float("\(self.destCityData[i].domBeer[self.productRangeSel]!)")!
                    let mealAmount = convAm / Float("\(self.destCityData[i].meal[self.productRangeSel]!)")!
                    let mcMealAmount = convAm / Float("\(self.destCityData[i].mcMeal[self.productRangeSel]!)")!
                    self.cokeDestLbl.text = "\(Int(cokeAmount))x"
                    self.domBeerDestLbl.text = "\(Int(domBeerAmount))x"
                    self.mealDestLbl.text = "\(Int(mealAmount))x"
                    self.mcmealDestLbl.text = "\(Int(mcMealAmount))x"
                    
                }
            }
        } else {
            print("--destCapital")
            print(self.destCityData.count)
            for i in (0..<self.destCityData.count){
                if (destCityData[i].cityName == self.destCapital)
                {
                    let cokeAmount = convAm / Float("\(self.destCityData[i].coke[self.productRangeSel]!)")!
                    let domBeerAmount = convAm / Float("\(self.destCityData[i].domBeer[self.productRangeSel]!)")!
                    let mealAmount = convAm / Float("\(self.destCityData[i].meal[self.productRangeSel]!)")!
                    let mcMealAmount = convAm / Float("\(self.destCityData[i].mcMeal[self.productRangeSel]!)")!
                    self.cokeDestLbl.text = "\(Int(cokeAmount))x"
                    self.domBeerDestLbl.text = "\(Int(domBeerAmount))x"
                    self.mealDestLbl.text = "\(Int(mealAmount))x"
                    self.mcmealDestLbl.text = "\(Int(mcMealAmount))x"
                    
                }
            }
        }
    }
    func getBaseCitiesProd(countryKey:String, cityKey: String, productRange: String){
        print("--- running: getBaseCitiesProd")
        DataService.ds.REF_CITIES.child(countryKey).observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshot {
                    if let countryCityDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let baseCityProdData = CityData(cityName:key, countryName: countryKey, productData:countryCityDict)

                        if self.baseCityData.isEmpty {
                            self.baseCityData.append(baseCityProdData)
                        } else {
                            self.baseCityData.removeAll()
                            self.baseCityData.append(baseCityProdData)
                        }
                        self.productList = self.baseCityData[0].productListCount
                        for i in (0..<self.baseCityData.count){
                            if (self.baseCityData[i].cityName == cityKey)
                            {
                                self.baseProdListDict.removeAll()
                                self.baseProdListDict = self.baseCityData[i].productData

                            }
                        }
                    }
                }
            }
            
        })
        
    }
    
    @IBAction func numberPressed(sender: UIButton){
        
        runningNumber += "\(sender.tag)"
        displayRunningNumber += "\(sender.tag)"
        calculationLbl.text = displayRunningNumber
        
        if currentOperation == Operation.Empty {
            result = runningNumber
        }
        baseCurrencyLbl.text = result
        
        if currentOperation != Operation.Empty {
            liveOperation(operation: currentOperation)
        }
        
        self.enableBtns()
        
        //Does Converstion
        if self.destCurrSel != nil && self.baseCurrSel != nil && result != "" {
            
            let stringResult = Float(result)!
            let priceToConver = Float(round(stringResult))
            let convertedAmount = Float(self.currentRates.doConvertion(dest: self.destCurrSel, base: self.baseCurrSel, price: priceToConver))!
            
            if self.destCityData.isEmpty && self.baseCityData.isEmpty {
                
            } else {
                
                if self.destCities.isEmpty {
                    
                } else {
                    self.productAmount(convAm: convertedAmount)
                }
                
            }

            destinationCurrencyLbl.text = "\(Float(round(convertedAmount)))"
            destinationCurrencyLbl.textColor = UIColor(red:0/255, green:0/255, blue:0/255, alpha:1)
        }
        
    }
    
    @IBAction func clearButton(_ sender: Any) {
        
        
        if displayRunningNumber != "" && runningNumber != "" {
            displayRunningNumber.remove(at: displayRunningNumber.index(before: displayRunningNumber.endIndex))
            runningNumber.remove(at: runningNumber.index(before: runningNumber.endIndex))
            liveOperation(operation: currentOperation)
            baseCurrencyLbl.text = result
            calculationLbl.text = displayRunningNumber
            
            if self.destCurrSel != nil && self.baseCurrSel != nil && result != "" {
                let stringResult = Float(result)!
                let priceToConver = Float(round(stringResult))
                
                let convertedAmount = Float(self.currentRates.doConvertion(dest: self.destCurrSel, base: self.baseCurrSel, price: priceToConver))!
                
                destinationCurrencyLbl.text = "\(Float(round(convertedAmount)))"
            }
        } else {
            runningNumber.removeAll()
            displayRunningNumber.removeAll()
            baseCurrencyLbl.text = "0"
            destinationCurrencyLbl.text = "0"
            calculationLbl.text = "0"
            currentOperation = Operation.Empty
            leftValStr = ""
            rightValStr = ""
            runningNumber = ""
            displayRunningNumber = ""
            result = "0"
            
        }
    }
    
    @IBAction func testCurrencyBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "destCurrVCSegue", sender: self)
    }
    
    @IBAction func testBaseCurrencyBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "baseCurrVCSegue", sender: self)
    }
    
    //Operators
    @IBAction func onDividePressed(sender: AnyObject){
        
        if self.buttonsEnabled != false {
            processOperation(operation: .Divide)
            displayRunningNumber += " ÷ "
            
            calculationLbl.text = displayRunningNumber
        }
        self.disableBtns()
        
    }
    @IBAction func onMultiplyPressed(sender: AnyObject){
        if self.buttonsEnabled != false {
            processOperation(operation: .Multiply)
            displayRunningNumber += " X "
            calculationLbl.text = displayRunningNumber
        }
        self.disableBtns()
        
    }
    @IBAction func onSubtractPressed(sender: AnyObject){
        if self.buttonsEnabled != false {
            processOperation(operation: .Subtract)
            displayRunningNumber += " - "
            calculationLbl.text = displayRunningNumber
        }
        self.disableBtns()
        
    }
    @IBAction func onAddPressed(sender: AnyObject){
        if self.buttonsEnabled != false {
            processOperation(operation: .Add)
            displayRunningNumber += " + "
            calculationLbl.text = displayRunningNumber
        }
       
        self.disableBtns()
    }
    
    @IBAction func decimalBtnPressed(_ sender: Any) {
        if self.decimalEnabled == true {
            runningNumber += "."
            displayRunningNumber += "."
            self.decimalEnabled = false
            decimalBtn.isUserInteractionEnabled = false
        }

    }

    @IBAction func swipe(_ sender: UISwipeGestureRecognizer) {
        
        runningNumber.removeAll()
        displayRunningNumber.removeAll()
        
        baseCurrencyLbl.text = "0"
        destinationCurrencyLbl.text = "0"
        calculationLbl.text = "0"
        self.cokeDestLbl.text = "0"
        self.domBeerDestLbl.text = "0"
        self.mealDestLbl.text = "0"
        self.mcmealDestLbl.text = "0"
        currentOperation = Operation.Empty
        leftValStr = ""
        rightValStr = ""
        runningNumber = ""
        displayRunningNumber = ""
        result = "0"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "destCurrVCSegue" {
            let destVC: destCurrVC = segue.destination as! destCurrVC
            destVC.delegate = self
        }
        if segue.identifier == "baseCurrVCSegue" {
            let baseVC: baseCurrVC = segue.destination as! baseCurrVC
            baseVC.delegate = self
        }
        if segue.identifier == "citySelectionSegue" {
            let cityVC: CitySelectionViewController = segue.destination as! CitySelectionViewController
            
            cityVC.baseCities = self.baseCities
            cityVC.destCities = self.destCities
            
            cityVC.delegate = self
        }
        
        
    }
    
    func disableBtns(){
        divideBtn.isUserInteractionEnabled = false
        subtractBtn.isUserInteractionEnabled = false
        multiplyBtn.isUserInteractionEnabled = false
        addBtn.isUserInteractionEnabled = false
        
        self.buttonsEnabled = false
    }
    
    func enableBtns(){
        divideBtn.isUserInteractionEnabled = true
        subtractBtn.isUserInteractionEnabled = true
        multiplyBtn.isUserInteractionEnabled = true
        addBtn.isUserInteractionEnabled = true
        
        self.buttonsEnabled = true
    }
    
    func reCalc() {
        print("Supposed to reCalc numbers on screen based on new selection")
    }
    
    func liveOperation(operation:Operation){
        
        if currentOperation != Operation.Empty {
            if runningNumber != "" {
                
                rightValStr = runningNumber
                
                if currentOperation == Operation.Multiply {
                    result = "\(Float(leftValStr)! * Float(rightValStr)!)"
                } else if currentOperation == Operation.Divide{
                    result = "\(Float(leftValStr)! / Float(rightValStr)!)"
                } else if currentOperation == Operation.Subtract{
                    result = "\(Float(leftValStr)! - Float(rightValStr)!)"
                } else if currentOperation == Operation.Add{
                    result = "\(Float(leftValStr)! + Float(rightValStr)!)"
                }
                
                baseCurrencyLbl.text = result
            }
        }
        
    }
    func processOperation(operation: Operation){
        self.decimalEnabled = true
        decimalBtn.isUserInteractionEnabled = true
        if currentOperation != Operation.Empty {
            if runningNumber != "" {
                
                rightValStr = runningNumber
                runningNumber = ""
                
                if currentOperation == Operation.Multiply {
                    result = "\(Float(leftValStr)! * Float(rightValStr)!)"
                } else if currentOperation == Operation.Divide{
                    result = "\(Float(leftValStr)! / Float(rightValStr)!)"
                } else if currentOperation == Operation.Subtract{
                    result = "\(Float(leftValStr)! - Float(rightValStr)!)"
                } else if currentOperation == Operation.Add{
                    result = "\(Float(leftValStr)! + Float(rightValStr)!)"
                }
                
                leftValStr = result
                baseCurrencyLbl.text = result
                
                //Does Converstion
                if self.destCurrSel != nil && self.baseCurrSel != nil && result != "" {
                    let stringResult = Float(result)!
                    let priceToConver = Float(round(stringResult))
                    
                    let convertedAmount = Float(self.currentRates.doConvertion(dest: self.destCurrSel, base: self.baseCurrSel, price: priceToConver))!
                    
                    destinationCurrencyLbl.text = "\(Float(round(convertedAmount)))"
                }
                
            } else {
                print("rightVal Is empty")
            }
            calculationLbl.text = result
            currentOperation = operation
        }else {
            leftValStr = runningNumber
            runningNumber = ""
            currentOperation = operation
        }
    }

    func globalProdAmount() {
//        print(" --running: globalProdAmount() ")
        let stringResult = Float(result)!
        let priceToConver = Float(round(stringResult))
        let convertedAmount = Float(self.currentRates.doConvertion(dest: self.destCurrSel, base: self.baseCurrSel, price: priceToConver))!
        
        
        if self.destCities.count > 0 {
            self.productAmount(convAm: convertedAmount)
        }
        
    }
}

