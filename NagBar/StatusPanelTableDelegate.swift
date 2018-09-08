//
//  StatusPanelTableDelegate.swift
//  NagBar
//
//  Created by Volen Davidov on 01.03.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class StatusPanelTableDelegate: NSObject, NSTableViewDelegate {
    private var results: Array<MonitoringItem>
    
    init(results: Array<MonitoringItem>) {
        self.results = results
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        tableView.intercellSpacing = NSMakeSize(0, 2)
        
        let tableColumn = tableColumn as! SPTableColumn
        
        return tableColumn.createViewForRow(row)
    }
    
    // this is needed, because selected rows will have blue outlines otherwise
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return StatusTableRowView()
    }
}

class StatusTableRowView : NSTableRowView {
    override func drawSelection(in dirtyRect: NSRect) {
        var newRect = dirtyRect
        
//        this can be build on 10.9 as well using the following code
//        let contextPointer = NSGraphicsContext.currentContext()!.graphicsPort
//        let context = unsafeBitCast(contextPointer, CGContextRef.self)
        
        let context = NSGraphicsContext.current()!.cgContext
        
        context.setFillColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        newRect.size.height -= 2
        newRect.origin.y += 1
        
        context.fill(NSRectToCGRect(newRect))
    }
}

protocol SPTableColumnProtocol {
    func setResults(_ results: Array<MonitoringItem>)
    func createViewForRow(_ row: Int) -> NSView
}


class SPTableColumn : NSTableColumn, SPTableColumnProtocol  {

    var results: Array<MonitoringItem> = []
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // we want to set the column width in the initialization
    init(results: Array<MonitoringItem>) {
        super.init(identifier: "")
        self.results = results
    
        self.initTable()
    }
    
    // this function must be overwritten
    func columnWidth(_ monitoringItem: MonitoringItem, font: Dictionary<String,NSFont>) -> CGFloat {
        return CGFloat(0)
    }
    
    func setResults(_ results: Array<MonitoringItem>) {
        self.results = results
        self.initTable()
    }
    
    func initTable() {
        let font = [NSFontAttributeName: NSFont.systemFont(ofSize: 16.0)]
        
        var columnWidth = CGFloat(0)
        
        for item in results {
            let width = self.columnWidth(item, font: font)
            if width > columnWidth {
                columnWidth = width
            }
        }
        
        self.width = columnWidth
    }
    
    func createViewForRow(_ row: Int) -> NSView {

        let background = TableViewCellBackground(frame: NSMakeRect(0, 0, self.width, 16), color: self.getColor(status: self.results[row].status))
        
        let text = NSTextField(frame: NSMakeRect(0, 0, self.width, 16))
        text.isEditable = false
        text.isBezeled = false
        text.isBordered = false
        text.drawsBackground = false
        text.tag = row
        
        text.stringValue = self.setValue(row)
        
        background.addSubview(text)
        
        return background
    }
    
    func getColor(status: String) -> NSColor {
        
        let colorStatusMap = [
            "CRITICAL": "criticalColor",
            "WARNING": "warningColor",
            "UNKNOWN": "unknownColor",
            "PENDING": "pendingColor",
            "DOWN": "downColor",
            "UNREACHABLE": "unreachableColor",
            "UP": "upColor",
            "OK": "okColor"
        ]
        
        guard let colorSettingsName = colorStatusMap[status] else {
            return NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
        let color = Settings().stringForKey(colorSettingsName)
        
        let colorArr = color!.components(separatedBy: ",")
        
        let red = CGFloat(Double(colorArr[0])!)
        let green = CGFloat(Double(colorArr[1])!)
        let blue = CGFloat(Double(colorArr[2])!)
        let alpha = CGFloat(Double(colorArr[3])!)
        
        return NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
    }
    
    func setValue(_ row: Int) -> String {
        return ""
    }
}

class SPMonitoringInstanceTableColumn : SPTableColumn {
    override func setValue(_ row: Int) -> String {
        return self.results[row].monitoringInstance!.name
    }
    
    override func columnWidth(_ monitoringItem: MonitoringItem, font: Dictionary<String,NSFont>) -> CGFloat {
        return monitoringItem.monitoringInstance!.name.size(withAttributes: font).width
    }
}

class SPHostTableColumn : SPTableColumn {
    override func setValue(_ row: Int) -> String {
        // set the host column to empty string if the current host is the same as the previous host
        if row == 0 {
            return self.results[row].host
        }
        
        let prevStatusItem = self.results[row - 1]
        
        if prevStatusItem.monitoringInstance != self.results[row].monitoringInstance {
            return self.results[row].host
        }
        
        if prevStatusItem.host != self.results[row].host {
            return self.results[row].host
        }
        
        return ""
    }
    
    override func columnWidth(_ monitoringItem: MonitoringItem, font: Dictionary<String,NSFont>) -> CGFloat {
        return monitoringItem.host.size(withAttributes: font).width
    }
}

class SPServiceTableColumn : SPTableColumn {
    override func setValue(_ row: Int) -> String {
        return self.results[row].service
    }
    
    override func columnWidth(_ monitoringItem: MonitoringItem, font: Dictionary<String,NSFont>) -> CGFloat {
        return monitoringItem.service
            .size(withAttributes: font).width
    }
    
}

class SPAcknowledgedDowntimeTableColumn : SPTableColumn {
    override func setValue(_ row: Int) -> String {
        if self.results[row].acknowledged && self.results[row].downtime {
            return "✓🕒"
        } else if self.results[row].acknowledged {
            return "✓"
        } else if self.results[row].downtime {
            return "🕒"
        } else {
            return ""
        }
    }
    
    override func columnWidth(_ monitoringItem: MonitoringItem, font: Dictionary<String,NSFont>) -> CGFloat {
        if monitoringItem.acknowledged && monitoringItem.downtime {
            return "✓🕒".size(withAttributes: font).width
        } else if monitoringItem.acknowledged {
            return "✓".size(withAttributes: font).width
        } else if monitoringItem.downtime {
            return "🕒".size(withAttributes: font).width
        } else {
            return "".size(withAttributes: font).width
        }
    }
    
}

class SPStatusTableColumn : SPTableColumn {
    override func setValue(_ row: Int) -> String {
        return self.results[row].status
    }
    
    override func columnWidth(_ monitoringItem: MonitoringItem, font: Dictionary<String,NSFont>) -> CGFloat {
        return monitoringItem.status.size(withAttributes: font).width
    }
}

class SPDurationTableColumn : SPTableColumn {
    override func setValue(_ row: Int) -> String {
        return self.results[row].duration
    }
    
    override func columnWidth(_ monitoringItem: MonitoringItem, font: Dictionary<String,NSFont>) -> CGFloat {
        return monitoringItem.duration.size(withAttributes: font).width
    }
}

class SPLastCheckTableColumn : SPTableColumn {
    override func setValue(_ row: Int) -> String {
        return self.results[row].lastCheck
    }
    
    override func columnWidth(_ monitoringItem: MonitoringItem, font: Dictionary<String,NSFont>) -> CGFloat {
        return monitoringItem.lastCheck.size(withAttributes: font).width
    }
}

class SPStatusInformationTableColumn : SPTableColumn {
    
    let statusInformationLength = CGFloat(Settings().doubleForKey("statusInformationLength"))
    
    override func setValue(_ row: Int) -> String {
        return self.results[row].statusInformation
    }
    
    override func columnWidth(_ monitoringItem: MonitoringItem, font: Dictionary<String,NSFont>) -> CGFloat {
        var width = monitoringItem.statusInformation.size(withAttributes: font).width
        if width > statusInformationLength {
            width = statusInformationLength
        }
        return width
    }
}

class SPAttemptTableColumn : SPTableColumn {
    override func setValue(_ row: Int) -> String {
        return self.results[row].attempt
    }
    
    override func columnWidth(_ monitoringItem: MonitoringItem, font: Dictionary<String,NSFont>) -> CGFloat {
        return monitoringItem.attempt.size(withAttributes: font).width
    }
}

class TableViewCellBackground : NSView {
    var color: NSColor
    
    init(frame: NSRect, color: NSColor) {
        self.color = color
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let startingColor = NSColor(calibratedRed: self.color.redComponent - 0.1, green: self.color.greenComponent - 0.1, blue: self.color.blueComponent - 0.1, alpha: 0.8)
        let endingColor = NSColor(calibratedRed: self.color.redComponent, green: self.color.greenComponent, blue: self.color.blueComponent, alpha: 0.8)
        
        let topShineStartColor = NSColor(calibratedWhite: 1.0, alpha: 0.05).usingColorSpaceName("NSCalibratedRGBColorSpace")
        let topShineEndColor = NSColor(calibratedWhite: 1.0, alpha: 0.0).usingColorSpaceName("NSCalibratedRGBColorSpace")
        
        let topShineRect = CGRect(x: dirtyRect.minX, y: dirtyRect.midY, width: dirtyRect.width, height: CGFloat(floorf(Float(dirtyRect.height) / 2.0)))
        
//        this can be built on 10.9 as well using the following code
//        let contextPointer = NSGraphicsContext.currentContext()!.graphicsPort
//        let context = unsafeBitCast(contextPointer, CGContextRef.self)
        
        let context = NSGraphicsContext.current()!.cgContext
        
        drawLinearGradient(context, startColor: startingColor, endColor: endingColor, rect: dirtyRect);
        
        drawLinearGradient(context, startColor: topShineStartColor!, endColor: topShineEndColor!, rect: topShineRect);
        
        let bottomShineStartColor = NSColor(calibratedWhite: 0.0, alpha: 0.0).usingColorSpaceName("NSCalibratedRGBColorSpace")
        let bottomShineEndColor = NSColor(calibratedWhite: 0.0, alpha: 0.05).usingColorSpaceName("NSCalibratedRGBColorSpace")
        
        let bottomShineRect = CGRect(x: dirtyRect.minX, y: dirtyRect.minY, width: dirtyRect.width, height: CGFloat(floorf(Float(dirtyRect.height) / 2.0)))
        
        drawLinearGradient(context, startColor: bottomShineStartColor!,endColor:  bottomShineEndColor!,rect:  bottomShineRect);
    }
    
    func drawLinearGradient(_ context: CGContext, startColor: NSColor, endColor: NSColor, rect: CGRect) -> Void {
        
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        let colors: Array<CGFloat> = [startColor.redComponent,
            startColor.greenComponent,
            startColor.blueComponent,
            startColor.alphaComponent,
            endColor.redComponent,
            endColor.greenComponent,
            endColor.blueComponent,
            endColor.alphaComponent,
        ]
        
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: colors, locations: nil, count: 2);
        let startPoint = CGPoint(x: rect.midX, y: rect.minY);
        let endPoint = CGPoint(x: rect.midX, y: rect.maxY);
        
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0));
    }
}
