//
//  ScoreCheck.swift
//  Yatzy
//
//  Created by Jon Eikholm on 07/02/2018.
//  Copyright © 2018 Jon Eikholm. All rights reserved.
//




import Foundation
import UIKit
class ScoreCheck {
    let ROW = Row()
    var methods : [(inout [Int])->(Int)] = []
    init(){
        for _ in 1...18 { // add empty methods
            methods.append({(buttons) in
                return 0
            })
        }
        createMethods()
    }
    
    func createMethods(){
        createOnePairMethod()
        createTwoPairsMethod()
        createN_OfAKindMethod(row: ROW.threeOfAKind, ofAKind: 3)
        createN_OfAKindMethod(row: ROW.fourOfAKind, ofAKind: 4)
        createN_OfAKindMethod(row: ROW.yatzy, ofAKind: 5)
        createSmallStraightMethod()
        createLargeStraightMethod()
        createFullHouseMethod()
        createChanceMethod()
    }
    
    
    func calculate1to6(buttons:[UIButton], number:Int) -> Int {
        var sum = 0
        for button in buttons {
            if button.tag == number {
                sum += button.tag
            }
        }
        return sum
    }
    
     func createOnePairMethod() {
        methods[ROW.onePair] = {(diceValues) in
            print("onePair is called")
            var pairs:[Int] = []
            for outerIndex in 0..<diceValues.count {
                for innerIndex in (outerIndex + 1)..<diceValues.count {
                    if diceValues[outerIndex] == diceValues[innerIndex] {
                        pairs.append(diceValues[outerIndex])
                    }
                }
            }
            if pairs.count > 0 { // then find biggest pair
                return 2 * pairs.max()!
            }
            return 0
        }
        
    }
    
     func createTwoPairsMethod() {
        methods[ROW.twoPairs] = {(diceValues) in
            print("twoPair is called")
            let firstPairValue = self.methods[self.ROW.onePair](&diceValues) / 2
            var sum = 0
            if firstPairValue > 0 {
                var hasRemovedOne = false
                print("Before loop: diceValues.count is \(diceValues.count)")
                var max = diceValues.count
                var index = 0
                while index < max {
                    print("index: \(index) max is \(max)")
                    if diceValues[index] == firstPairValue && !hasRemovedOne {
                        diceValues.remove(at: index)
                        max -= 1
                        hasRemovedOne = true
                    }else if diceValues[index] == firstPairValue && hasRemovedOne {
                        diceValues.remove(at: index)
                        break // now we have removed twice, then return
                    }
                    index += 1
                }
                sum = 2 * firstPairValue
                print("first pair: \(sum)")
            }else {
                return 0
            }
            var pairs:[Int] = []
            for outerIndex in 0..<diceValues.count {
                for innerIndex in (outerIndex + 1)..<diceValues.count {
                    if diceValues[outerIndex] == diceValues[innerIndex] {
                        pairs.append(diceValues[outerIndex])
                    }
                }
            }
            if pairs.count > 0 { // then find biggest pair
                let secondPairValue = 2 * pairs.max()!
                print("second pair: \(secondPairValue)")
                return sum + secondPairValue
            }
            return 0 // if not 2 pairs, then just return 0
        }
    }
    
    func createN_OfAKindMethod(row:Int, ofAKind: Int) {
        methods[row] = {(diceValues) in
            print("\(ofAKind) of a kind is called")
            var occurranceMap = [Int](repeatElement(0, count: 7)) // one extra because of zero based index
            for num in diceValues {
                occurranceMap[num] += 1
            }
            for (key,val) in occurranceMap.enumerated() {
                if val == 5 && row == self.ROW.yatzy {// Special Yatzy rule
                    return 50
                }
                if val > ofAKind-1 {
                    return ofAKind * key
                }
            }
            return 0
        }
    }
    
    
    func createFullHouseMethod() {
        methods[ROW.fullHouse] = {(diceValues) in
            let threeOfAKind = self.methods[self.ROW.threeOfAKind](&diceValues) / 3
            if threeOfAKind > 0 {
                for _ in 0...2 { // remove 3 values, where value=threeOfAKind
                    diceValues.remove(at: diceValues.index(of: threeOfAKind)!)
                }
                if diceValues[0] == diceValues[1] {
                    return diceValues[0] * 2 + threeOfAKind * 3
                }
            }
            return 0
        }
    }
    
    func createChanceMethod() {
        methods[ROW.chance] = {(diceValues) in
            print("chance is called")
            return diceValues.reduce(0,+)
        }
    }
    
    func createSmallStraightMethod() {
        methods[ROW.smallStraight] = {(diceValues) in
            let diceSet = Set(diceValues)
            let smallSet = Set([1,2,3,4,5])
            return smallSet.isSubset(of: diceSet) ? 15 : 0
        }
    }
    
    func createLargeStraightMethod() {
        methods[ROW.largeStraight] = {(diceValues) in
            let diceSet = Set(diceValues)
            let smallSet = Set([2,3,4,5,6])
            return smallSet.isSubset(of: diceSet) ? 20 : 0
        }
    }
    
    
}
































