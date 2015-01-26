//
//  AcceptDragView.swift
//  SimpleLauncher
//
//  Created by kitano on 2015/01/27.
//  Copyright (c) 2015年 OneWorld Inc. All rights reserved.
//

import Cocoa

class AcceptDragView: NSView {
    var list:NSMutableArray!
    var imageViewList:[NSImageView]!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //fatalError("init(coder:) has not been implemented")
        list = NSMutableArray()
        imageViewList = [NSImageView]()
        var ud:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var _list:NSArray? = ud.objectForKey("list") as? NSArray
        
        if _list != nil {
            for path:String in _list! as [String] {
                setupIconImageView(path,tag:list.count)
                list.addObject(path)
            }
        }
        

        self.registerForDraggedTypes([NSFilenamesPboardType]);
    }

    override func draggingEntered(sender:NSDraggingInfo)->NSDragOperation{
        return NSDragOperation.Generic;
    }
    
    override func performDragOperation(sender:NSDraggingInfo)->Bool{
        var pboard:NSPasteboard! = sender.draggingPasteboard()
        if pboard != nil {
            pboard = sender.draggingPasteboard()
            if contains(pboard.types as [NSString],NSFilenamesPboardType) {
                var files:[String] = pboard.propertyListForType(NSFilenamesPboardType) as [String]
                if files.count == 1 && list.count < 8{
                    setupIconImageView(files[0],tag:list.count)
                    list.addObject(files[0])
                    var ud:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    ud.setObject(list, forKey:"list")
                    ud.synchronize()
                    return true;
                } else {
                    return false;
                }
            } else {
                return true;
            }
        }
        return false
    }
    
    func openApp(sender:NSClickGestureRecognizer){
        var imageView:NSImageView = sender.view as NSImageView
        NSWorkspace.sharedWorkspace().launchApplication(list.objectAtIndex(imageView.tag-1) as String)
        return
    }
    func deleteApp(sender:NSPressGestureRecognizer){
        var imageView:NSImageView = sender.view as NSImageView
        list.removeObjectAtIndex(imageView.tag-1)
        var ud:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        ud.setObject(list, forKey:"list")
        ud.synchronize()
        
        for imageView:NSImageView in imageViewList {
            imageView.removeFromSuperview()
        }
        imageViewList = [NSImageView]()

        for var i=0;i<list.count; i++ {
            var path:String = list.objectAtIndex(i) as String;
            setupIconImageView(path,tag: i)
        }
        return
    }
    
    func setupIconImageView(path:String,tag i:Int){
        var workspace:NSWorkspace = NSWorkspace.sharedWorkspace();
        var image:NSImage = workspace.iconForFile(path)
        var width:CGFloat  = 100
        var height:CGFloat = 100
        image.size = NSMakeSize(width, height)
        var imageView:NSImageView = NSImageView(frame:
            CGRectMake(
                CGFloat(30  + Int(width) * (i%4)),
                CGFloat(130 - Int(height) * (i/4)),
                width,
                height))
        imageView.tag = i+1;
        imageViewList!.append(imageView)
        imageView.image = image
        var click:NSClickGestureRecognizer = NSClickGestureRecognizer(target: self, action:"openApp:")
        imageView.addGestureRecognizer(click)
        var longclick:NSPressGestureRecognizer = NSPressGestureRecognizer(target: self, action:"deleteApp:")
        imageView.addGestureRecognizer(longclick)
        self.addSubview(imageView)
    }
    
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
