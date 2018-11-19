//
//  OverlayerView.swift
//  Spirality
//
//  Created by Daniel on 27/11/2017.
//  Copyright © 2017 Daniel. All rights reserved.
//

import UIKit
import ChromaColorPicker

class OverlayerView: UIView {
    
    weak var delegate: SpiralityCanvas?
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var colorPickerBtn: UIButton!
    @IBOutlet weak var spiralityBtn: UIButton!
    @IBOutlet weak var penTypeButton: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var gobackBtn: UIButton!
    @IBOutlet weak var goForwardBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    
    @IBOutlet weak var colorLineView: UIView!
    @IBOutlet weak var spiralityCountLabel: UILabel!
    
    lazy var colorPicker: ChromaColorPicker = {
        let neatColorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 240, height: 240))
        neatColorPicker.delegate = self
        neatColorPicker.padding = 10
        neatColorPicker.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        neatColorPicker.isHidden = true
        neatColorPicker.layer.cornerRadius = neatColorPicker.frame.width/2.0
        neatColorPicker.hexLabel.textColor = UIColor.lightGray
        neatColorPicker.layer.masksToBounds = true
        neatColorPicker.addTarget(self, action: #selector(colorPickerChanged), for: UIControl.Event.valueChanged)
        addSubview(neatColorPicker)
        neatColorPicker.layout()
        return neatColorPicker
    }()
    
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.backgroundColor = UIColor.init(white: 0.2, alpha: 0.8)
        slider.maximumValue = 100
        slider.minimumValue = 2
        slider.value = 30
        slider.isHidden = true
        slider.clipsToBounds = true
        slider.addTarget(self, action: #selector(spiralityCountChanged), for: UIControl.Event.valueChanged)
        addSubview(slider)
        return slider
    }()
    
    lazy var lineLayer: CALayer = {
        let _layer = CALayer()
        _layer.masksToBounds = true
        _layer.backgroundColor = UIColor.white.withAlphaComponent(0.1).cgColor
        return _layer
    }()
    
    lazy var replicatorLayer: CAReplicatorLayer = {
        let size = UIScreen.main.bounds.size
        let length = max(size.width, size.height)
        let _layer = CAReplicatorLayer()
        _layer.masksToBounds = true
        _layer.frame = CGRect(x: 0, y: 0, width: length, height: length)
        _layer.instanceCount = Int(slider.value)
        let angle = -CGFloat.pi * 2 / CGFloat(_layer.instanceCount)
        _layer.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
        
        self.lineLayer.frame = CGRect.init(x: length/2.0, y: -length, width: 1/UIScreen.main.scale, height: length*1.4)
        _layer.addSublayer(self.lineLayer)
        layer.insertSublayer(_layer, at: 0)
        return _layer
    }()
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self && (!colorPicker.isHidden || !slider.isHidden) {
            colorPicker.isHidden = true
            slider.isHidden = true
            return view
        }
        return view == self ? nil: view
    }
    
    override func layoutSubviews() {
        let size = UIScreen.main.bounds.size
        let length = max(size.width, size.height)
        replicatorLayer.frame = CGRect(x: -(length-bounds.size.width)/2.0, y: -(length-bounds.size.height)/2.0, width: length, height: length)
//        replicatorLayer.frame = CGRect(x: 0, y: 0, width: length, height: length)

        colorPicker.center = CGPoint(x: frame.width/2.0, y: frame.height/2.0)
        let rect = spiralityBtn.convert(spiralityBtn.bounds, to: self)
        slider.frame = CGRect.init(x: rect.maxX+4, y: rect.midY - 30/2.0, width: 200, height: 30)
        slider.layer.cornerRadius = 15;
        if UIScreen.main.nativeBounds.height == 2436 && frame.width>frame.height {
            leadingConstraint.constant = 30;
        } else {
            leadingConstraint.constant = 0;
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        colorPicker.isHidden = true
        slider.isHidden = true
    }
}

extension OverlayerView {
    
    @IBAction func pcikerColorAction(_ sender: UIButton) {
        colorPicker.isHidden = !colorPicker.isHidden
        slider.isHidden = true
    }
    
    @IBAction func spiralityAction(_ sender: UIButton) {
        slider.isHidden = !slider.isHidden
        colorPicker.isHidden = true
    }
    
    @IBAction func penTypeChangedAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.penStyle = sender.isSelected ? .bucket : .pencil
    }

    @IBAction func deleteAction(_ sender: UIButton) {
        delegate?.cleanAll()
    }
    
    @IBAction func goBackAction(_ sender: UIButton) {
        delegate?.withdrawHistoryRecord()
    }
    
    @IBAction func goForwardAction(_ sender: UIButton) {
        delegate?.recoverHistoryRecord()
    }
    
    @IBAction func saveToAlbumAction(_ sender: UIButton) {
        guard let delegate = delegate, delegate.stack.showingHistoryRecords.count>0 else { return }
        UIImageWriteToSavedPhotosAlbum(delegate.screenshotImage(), self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac)
        }
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        delegate?.play()
    }
}

private extension OverlayerView {
    
    func present(_ vc: UIAlertController) {
        parentViewController?.present(vc, animated: true, completion: nil)
    }
    
    @objc func colorPickerChanged(picker: ChromaColorPicker) {
        colorLineView.backgroundColor = picker.currentColor
        delegate?.drawColor = picker.currentColor
    }
    
    @objc func spiralityCountChanged(slider: UISlider) {
        let count = Int(slider.value)
        spiralityCountLabel.text = "\(count)"
        delegate?.numberOfDrawer = count
        
        replicatorLayer.instanceCount = count
        let angle = -CGFloat.pi * 2 / CGFloat(count)
        replicatorLayer.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
    }
}

private extension UIView {
    func screenshotImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale*2);
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let screenShot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return screenShot!
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension OverlayerView: ChromaColorPickerDelegate {
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        colorLineView.backgroundColor = color
        delegate?.drawColor = color
        colorPicker.isHidden = true
    }
}
