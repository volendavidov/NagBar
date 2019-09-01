//
//  StatusPanel.swift
//  NagBar
//
//  Created by Volen Davidov on 28.02.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class StatusPanel : NSObject {
    
    // The panel height is limited to that number. If the panel needs to be bigger to
    // contain all monitoring items, then a scroller is added (see below).
    let maxPanelHeight: CGFloat = 500;
    
    let results: Array<MonitoringItem>
    let panelBounds: NSRect
    
    var panel: StatusNSPanel?
    
    init(results: Array<MonitoringItem>, panelBounds: NSRect) {
        self.results = results
        self.panelBounds = panelBounds
    }
    
    func load() {
        // first initialize the table, we will know the width of the panel this way
        let statusTable = StatusPanelTable()
        statusTable.initTable(results)
        
        // Get the total width of the panel by suming all columns in the table
        var allColumnsWidth = CGFloat(0)
        for column in statusTable.tableColumns {
            allColumnsWidth += column.width
        }
        
        var xCoords = (self.panelBounds.origin.x + self.panelBounds.size.width - (allColumnsWidth))
        
        // We always want to start from the leftmost part of the display, including the dock if its position is on the left side.
        let visibleScreenRect = NSScreen.main?.visibleFrame
        if (xCoords < visibleScreenRect!.origin.x) {
            xCoords = visibleScreenRect!.origin.x
        }
        
        // The height of the panel is the number of rows * 19 (the height of a single row).
        // The height cannot be more than maxPanelHeight. If it is, we will add scroller and arrow several lines below.
        let rowHeight = 19
        var panelHeight = CGFloat(rowHeight * self.results.count);
        if (panelHeight > maxPanelHeight) {
            panelHeight = maxPanelHeight
        }
        
        let yCoords = self.panelBounds.origin.y - CGFloat(panelHeight);
        
        let frame = NSMakeRect(xCoords, yCoords, allColumnsWidth, panelHeight)
        
        panel = StatusNSPanel(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false)
        panel!.hasShadow = true
        panel!.makeKeyAndOrderFront(nil)
        
        let scrollView: NSScrollView
        
        if panelHeight == maxPanelHeight {
            let arrowRect = CGRect(x: 0, y: maxPanelHeight - 20, width: panel!.contentView!.bounds.size.width, height: 20);
            let drawArrow = DrawArrow(frame: arrowRect)
            scrollView = NSScrollView(frame: panel!.contentView!.bounds)
            scrollView.addSubview(drawArrow)
        } else {
            scrollView = UnscrollableScrollView(frame: panel!.contentView!.bounds)
        }
        
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.documentView = statusTable
        panel!.contentView?.addSubview(scrollView)
        statusTable.reloadData()
    }
}

class UnscrollableScrollView : NSScrollView {
    override func scrollWheel(with theEvent: NSEvent) {
        
    }
}

class StatusNSPanel : NSPanel {
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}

class DrawArrow : NSView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let rectPath = NSBezierPath()
        rectPath.move(to: NSMakePoint(0, 0))
        rectPath.line(to: NSMakePoint(0, 0))
        rectPath.line(to: NSMakePoint(dirtyRect.size.width, 0))
        rectPath.line(to: NSMakePoint(dirtyRect.size.width, dirtyRect.size.height))
        rectPath.line(to: NSMakePoint(0, dirtyRect.size.width))
        rectPath.line(to: NSMakePoint(0, 0))
        rectPath.close()
        
        NSColor(calibratedWhite: 0.0, alpha: 0.3).setFill()
        rectPath.fill()
        
        let startingPoint = dirtyRect.size.width/2;
        
        let path = NSBezierPath()
        path.move(to: NSMakePoint(startingPoint, 0))
        path.line(to: NSMakePoint(startingPoint - 75, 15))
        path.line(to: NSMakePoint(startingPoint - 25, 15))
        path.line(to: NSMakePoint(startingPoint - 25, 20))
        path.line(to: NSMakePoint(startingPoint + 25, 20))
        path.line(to: NSMakePoint(startingPoint + 25, 15))
        path.line(to: NSMakePoint(startingPoint + 75, 15))
        path.close()
        
        let lightColor = NSColor(calibratedWhite: 0.3, alpha: 0.9)
        let darkColor = NSColor(calibratedWhite: 0.1, alpha: 0.9)
        
        let fillGradient = NSGradient(starting: lightColor, ending:darkColor)
        fillGradient?.draw(in: path, angle: 270)
    }
}
