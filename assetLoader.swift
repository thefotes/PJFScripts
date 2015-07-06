#!/usr/bin/xcrun swift

import Foundation

let fileManager = NSFileManager.defaultManager()

let args = [String](Process.arguments)

let xcodeProjectPath = args[1].stringByAppendingString("/")
let xcassetPath = args[1].stringByAppendingString("/Images.xcassets/")
let imagesPath = args[2].stringByAppendingString("/")

func nameIncludesAtSign(name: String) -> Bool {
    return (name as NSString).containsString("@")
}

func sanitizedFileNameForRawFileName(rawName: String) -> String {
    var components = [String]()
    
    if nameIncludesAtSign(rawName) {
        components = rawName.componentsSeparatedByString("@")
    } else {
        components = rawName.componentsSeparatedByString(".")
    }
    
    return components.first!
}

func imageSetExistsFor(fileName: String, atPath: String) -> Bool {
    return fileManager.fileExistsAtPath(imageSetPathForImage(fileName))
}

func imageSetPathForImage(imageName: String) -> String {
    return xcassetPath.stringByAppendingString(imageName.stringByAppendingString(".imageset"))
}

func createDirectoryForImageSet(imageSetName: String) -> Bool {
    return fileManager.createDirectoryAtPath(imageSetPathForImage(imageSetName), withIntermediateDirectories: false, attributes: nil, error: nil)
}

func createEmptyContentsJSON(imageSetName: String) {
    var contentsJSON = NSMutableDictionary()
    contentsJSON["images"] = []
    contentsJSON["info"] = NSDictionary(objects: [1, "xcode"], forKeys: ["version", "author"])
    
    let jsonData = NSJSONSerialization.dataWithJSONObject(contentsJSON, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
    
    fileManager.createFileAtPath(contentsJSONFor(imageSetName), contents: jsonData!, attributes: nil)
}

func contentsJSONFor(imageNamed: String) -> String {
    return imageSetPathForImage(imageNamed).stringByAppendingString("/Contents.json")
}

func scaleFor(fileNamed: String) -> String {
    if (fileNamed as NSString).containsString("2x") {
        return "2x"
    } else if (fileNamed as NSString).containsString("3x") {
        return "3x"
    } else {
        return "1x"
    }
}

func individualImageJSON(fileName: String) -> NSDictionary {
    return NSDictionary(objects: ["universal", scaleFor(fileName), fileName], forKeys: ["idiom", "scale", "filename"])
}

func updateContentsJSON(pathToContentsJSON: String, imageDictionary: NSDictionary) {
    var currentJSON = NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: pathToContentsJSON)!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSMutableDictionary
    
    var imagesArray = currentJSON["images"] as! [NSDictionary]

    imagesArray.append(imageDictionary)
    
    currentJSON["images"] = imagesArray
    
    fileManager.removeItemAtPath(pathToContentsJSON, error: nil)
    
    let jsonData = NSJSONSerialization.dataWithJSONObject(currentJSON, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
    
    fileManager.createFileAtPath(pathToContentsJSON, contents: jsonData!, attributes: nil)
}

func UIImageExtensionPath() -> String {
    return xcodeProjectPath.stringByAppendingString("/UIImage+Images.swift")
}

func UIImageExtensionExists() -> Bool {
    return fileManager.fileExistsAtPath(UIImageExtensionPath())
}

func createEmptyUIImageExtensionFile() {
    let emptyExtension = "import UIKit \n\nextension UIImage { \n\n}"
    fileManager.createFileAtPath(UIImageExtensionPath(), contents: (emptyExtension as NSString).dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
}

func cleanFileName(original: String) -> String {
    return original.stringByReplacingOccurrencesOfString("-", withString: "", options: nil, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.decimalDigitCharacterSet())
}

func addClassMethodToUIImageExtensionFor(fileName: String) {
    let currentExtension = String(contentsOfFile: UIImageExtensionPath(), encoding: NSUTF8StringEncoding, error: nil)!
    var components = currentExtension.componentsSeparatedByString("extension UIImage {")
    
    if !((currentExtension as NSString).containsString(cleanFileName(fileName))) {
        let fileNameWithQuotes = NSString(format: "\"%@\"", cleanFileName(fileName))
        
        let newMethod = "\n\t\tclass func \(cleanFileName(fileName))() -> UIImage {\n\t\t\treturn UIImage(named: \(fileNameWithQuotes))!\n\t\t}"
        var newArray = [components[0], "extension UIImage {\n"]
        newArray.append(newMethod)
        for thing in components[1...components.count - 1] {
            newArray.append(thing)
        }
        
        var string = ""
        
        for theThing in newArray {
            string = string.stringByAppendingString(theThing)
        }
        
        fileManager.removeItemAtPath(UIImageExtensionPath(), error: nil)
        fileManager.createFileAtPath(UIImageExtensionPath(), contents: (string as NSString).dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
    }
}

let enumerator = fileManager.enumeratorAtPath(imagesPath)

while let element = enumerator?.nextObject() as? String {
    let cleanFileName = sanitizedFileNameForRawFileName(element)
    
    if !imageSetExistsFor(cleanFileName, xcassetPath) {
        createDirectoryForImageSet(cleanFileName)
        createEmptyContentsJSON(cleanFileName)
    }
    
    if !UIImageExtensionExists() {
        createEmptyUIImageExtensionFile()
    } else {
        addClassMethodToUIImageExtensionFor(cleanFileName)
    }
    
    fileManager.copyItemAtPath(imagesPath.stringByAppendingString(element), toPath: imageSetPathForImage(cleanFileName).stringByAppendingString("/\(element)"), error: nil)
    updateContentsJSON(contentsJSONFor(cleanFileName), individualImageJSON(element))
}
