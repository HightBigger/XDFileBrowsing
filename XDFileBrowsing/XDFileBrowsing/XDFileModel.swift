//
//  XDFileModel.swift
//  XDFileBrowsing
//
//  Created by xiaoda on 2019/1/4.
//  Copyright © 2019 xiaoda. All rights reserved.
//

import UIKit

public enum XDFileType {
    case XDDirectory    //文件夹
    case XDFile         //文件
}

class XDFileModel: NSObject {

    var filePath: String
    var name: String
    var fileType: XDFileType
 
    init(filePath: String) {
        
        self.filePath = filePath
        
        self.name = filePath.components(separatedBy: "/").last ?? ""
        
        var isDir: ObjCBool = false
        
        _ = FileManager.default.fileExists(atPath:filePath, isDirectory:&isDir)
        
        if isDir.boolValue {
            self.fileType = XDFileType.XDDirectory
        }else{
            self.fileType = XDFileType.XDFile
        }
    }
    
    
}
