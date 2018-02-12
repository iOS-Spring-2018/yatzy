//
//  ViewController.swift
//  Yatzy
//
//  Created by Jon Eikholm on 05/02/2018.
//  Copyright © 2018 Jon Eikholm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var p1Label: UILabel!
    @IBOutlet weak var p2Label: UILabel!
    @IBOutlet weak var die1: UIButton!
    @IBOutlet weak var die2: UIButton!
    @IBOutlet weak var die3: UIButton!
    @IBOutlet weak var die4: UIButton!
    @IBOutlet weak var die5: UIButton!
    @IBOutlet weak var rollCountLabel: UILabel!
    @IBOutlet weak var valueView: UIView!
    @IBOutlet weak var p1View: UIView!
    @IBOutlet weak var p2View: UIView!
    
    var pointTypes = [String]()
    var dieButtons = [UIButton]() // empty array of UIImageView
    var playerViews = [UIView]()
    var playerLabels = [UILabel]()
    let rowSpacing = 33
    var currentPlayer = -1;
    let ROW = Row()
    var map = [Int:[Int: Int]]() // game model [playerNr: [Row:Value]]
    var currentDiceValues:[Int] = [0,0,0,0,0]
    var scoreCheck = ScoreCheck()
    var rollCount:Int = 0 {
        didSet{
            rollCountLabel.text = "\(rollCount)"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        map[1] = [Int: Int]()
        map[2] = [Int: Int]()
        initalizePointTypes()
        intializeMap(playerNumber: 1)
        intializeMap(playerNumber: 2)
        initializeDies()
        playerViews.append(contentsOf: [p1View, p2View])
        for view in playerViews {
                createLabels(view:view)
        }
        playerLabels.append(contentsOf: [p1Label, p2Label])
        changePlayer()
    }
    
    
    func initalizePointTypes(){
        pointTypes.append(contentsOf: ["","1", "2", "3", "4", "5", "6", "SUM", "Bonus", "1 pair"])  // ends on index 9. That is why there is
        pointTypes.append(contentsOf: ["2 pair", "3 of a kind", "4 of a kind", "Small Straight"]) // ends on index 13
        pointTypes.append(contentsOf: ["Large Straight", "Full House", "Chance", "Yatzy", "Total Sum"]) // ends on index 17 (Yatzy)
        for index in 1..<pointTypes.count {
            let label1 = UILabel(frame: CGRect(x: 0, y: rowSpacing * (index-1), width: 110, height: 20))
            label1.text = pointTypes[index]
            label1.backgroundColor = UIColor.white
            valueView.addSubview(label1)
        }
    }
    
    func intializeMap(playerNumber: Int){
       for index in 1...pointTypes.count {
        map[playerNumber]![index] = 0
        }
    }
    
    func createLabels(view: UIView) {
        var label:UILabel!
        for index in 1...pointTypes.count {
            label = UILabel(frame: CGRect(x: 0, y: rowSpacing * (index-1), width: 40, height: 20))
            label.text = ""
            label.tag = index
            label.isUserInteractionEnabled = true
            label.backgroundColor = UIColor.white
            let tap = UITapGestureRecognizer(target: self, action: #selector(labelTapped(sender:)))
            label.addGestureRecognizer(tap)
            view.addSubview(label)
        }
    }
    
    fileprivate func initializeDies() {
        dieButtons.append(die1)
        dieButtons.append(die2)
        dieButtons.append(die3)
        dieButtons.append(die4)
        dieButtons.append(die5)
        for button in dieButtons {
            button.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        }
    }
    
    
    func calculateSum(playerNr: Int) -> (sum:Int, totalsum:Int){
        var sum = 0
        for index in 1..<ROW.SUM {
            sum += map[playerNr]![index]!
        }
        if sum > 62 && map[playerNr]![ROW.Bonus] == 0 {
            map[playerNr]![ROW.Bonus] = 50
            updateBonus(playerNr: playerNr, value: 50)
        } else {
            print("Line 114")
        }
        map[playerNr]![ROW.SUM] = sum
        var totalSum = sum
        for index in (ROW.Bonus)..<ROW.TOTALSUM {
            totalSum += map[playerNr]![index]!
        }
        map[playerNr]![ROW.TOTALSUM] = totalSum
        return (sum, totalSum)
    }
    
    func updateBonus(playerNr: Int, value: Int){
        let view = playerViews[playerNr-1];
        let label = view.viewWithTag(ROW.Bonus) as? UILabel
        label?.text = "\(value)"
    }
    
    func updateSum(playerNr: Int, sum: Int, totalSum: Int){
        let view = playerViews[playerNr-1];
           let label = view.viewWithTag(ROW.SUM) as? UILabel
            label?.text = "\(sum)"
            let label2 = view.viewWithTag(ROW.TOTALSUM) as? UILabel
            label2?.text = "\(totalSum)"
    }
    
    
    @objc func labelTapped(sender: UITapGestureRecognizer){
       calculateRound(sender: sender)
        let sums = calculateSum(playerNr: currentPlayer)
        updateSum(playerNr: currentPlayer, sum: sums.sum, totalSum: sums.totalsum)
        clearButtonSelection()
        changePlayer()
        rollCount = 0
        currentDiceValues = [0,0,0,0,0] // reset the array, because it has been reduced by some methods (f.ex. 2 pairs)
        print("Current player: \(currentPlayer) ")
    }
    
    func calculateRound(sender: UITapGestureRecognizer){
        let label = sender.view as? UILabel
        let row = label?.tag ?? -1
        let view = playerViews[currentPlayer-1];  // locate view based on current player
        let label2 = view.viewWithTag(row) as? UILabel // locate correct row
        var roundSum = 0
        if row <= 6 {
            roundSum = scoreCheck.calculate1to6(buttons: dieButtons, number: row) //
        }else {
            roundSum = scoreCheck.methods[row](&currentDiceValues) // brilliant call here: a dynamic method call ! (skips the normal switch statement)
        }
        for button in dieButtons {
            button.alpha = 1.0
        }
        map[currentPlayer]![row] = roundSum;
        if let lbl = label2 {
            lbl.text = "\(roundSum)"
        }
    }

    func changePlayer(){
        if currentPlayer == 1 {
            currentPlayer = 2
        } else if currentPlayer == 2 || currentPlayer == -1 {
            currentPlayer = 1
        }
        for label in playerLabels {
            label.isHighlighted = false
            label.backgroundColor = UIColor.white
        }
        playerLabels[currentPlayer-1].isHighlighted = true
        playerLabels[currentPlayer-1].highlightedTextColor = UIColor.blue
        playerLabels[currentPlayer-1].backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
     
    }
    
    func clearButtonSelection(){
        for button in dieButtons {
            button.alpha = 1.0
        }
        
    }
    

    
    @objc func buttonAction(sender: UIButton!) {
        // toggle selected/not selected
        if(sender.alpha == 1.0){
            sender.alpha = 0.5
        }else {
            sender.alpha = 1.0
        }
    }
    
    func assignImage(button: UIButton, number: Int) {
        button.setImage(UIImage(named: "\(number).png"), for: UIControlState.normal)
        
    }

    @IBAction func rollPressed(_ sender: Any) {
        if rollCount > 2 {
            print("MAX number of rolls exceeded")
            return
        }
        rollCount += 1
        if let btn = sender as? UIButton {
            btn.backgroundColor = UIColor.gray
        }
        for (i,button) in dieButtons.enumerated() {
            if button.alpha == 1.0 {
            let nr = Int(arc4random_uniform(6) + 1)
                button.tag = nr
            assignImage(button: button, number: nr)
                currentDiceValues[i] = nr
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

























