//
//  SpiralityStack.swift
//  Spirality
//
//  Created by Daniel on 09/12/2017.
//  Copyright © 2017 Daniel. All rights reserved.
//

import UIKit

enum PenStyle {
    case pencil
    case bucket
}

struct SpiralityDrawRecordItem {
    var color = UIColor.white
    var linWidth: CGFloat = 1/UIScreen.main.scale
    var layers = [CAShapeLayer]()
    var paths = [CGMutablePath]()
    var duration: Double = 0
    var penStyle: PenStyle = .pencil
    mutating func updateCollects(num:Int) {
        self.layers.removeAll()
        self.paths.removeAll()
        (0...num).forEach { _ in
            let layer = CAShapeLayer()
            layer.lineWidth = linWidth
            layer.strokeColor = color.cgColor
            layer.fillColor = penStyle == .pencil ? UIColor.clear.cgColor : color.cgColor
            layers.append(layer)
            paths.append(CGMutablePath())
        }
    }
}

class SpiralityStack {
    var allHistoryRecords = [SpiralityDrawRecordItem]()
    var showingHistoryRecords = [SpiralityDrawRecordItem]()
    var temportItem: SpiralityDrawRecordItem?
    
    func push(item: SpiralityDrawRecordItem?) {
        guard let item = item else { return }
        showingHistoryRecords.append(item)
        allHistoryRecords = showingHistoryRecords
    }
    func pop() -> SpiralityDrawRecordItem? {
        return showingHistoryRecords.removeLast()
    }
    func clean() {
        allHistoryRecords.forEach{ $0.layers.forEach{ $0.removeFromSuperlayer() } }
        allHistoryRecords.removeAll()
        showingHistoryRecords.removeAll()
    }
    func back() ->SpiralityDrawRecordItem? {
        return showingHistoryRecords.removeLast()
    }
    func forward() ->SpiralityDrawRecordItem? {
        if allHistoryRecords.count > showingHistoryRecords.count {
            let item = allHistoryRecords[showingHistoryRecords.count]
            showingHistoryRecords.append(item)
            return item
        } else {
            return nil
        }
    }
}

extension SpiralityStack {
    var isEnableMoveItemForward: Bool {
        return showingHistoryRecords.count < allHistoryRecords.count
    }
    var isEnableCancelLastItem: Bool {
        return showingHistoryRecords.count > 0
    }
    func playAnimation() {
        let times = showingHistoryRecords.map { $0.duration }
        
        showingHistoryRecords.enumerated().forEach { (index, item) in
            
            item.layers.forEach({ (layer) in
                var animation:CABasicAnimation!
                if item.penStyle == .pencil {
                    layer.strokeEnd = 0;
                    animation = CABasicAnimation.init(keyPath: "strokeEnd")
                } else {
                    layer.opacity = 0;
                    animation = CABasicAnimation.init(keyPath: "opacity")
                }
                animation.duration = item.duration
                animation.fromValue = 0;
                animation.toValue = 1
                animation.beginTime = CACurrentMediaTime() + times.enumerated().reduce(0.0, { (result, arg1) -> Double in
                    if arg1.0 >= index {
                        return result
                    } else {
                        return result + arg1.1
                    }
                });
                animation.isRemovedOnCompletion = false
                animation.fillMode = CAMediaTimingFillMode.forwards
                layer.add(animation, forKey: "animation");
            })
        }
    }
}









