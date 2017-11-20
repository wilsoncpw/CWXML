//
//  CWXMLDocument.swift
//  XMLTest
//
//  Created by Colin Wilson on 12/10/2017.
//  Copyright © 2017 Colin Wilson. All rights reserved.
//
//  Why ???
//
//  Because XMLDocument doesn't work on iOS!

import Foundation




public class CWXMLDocument: CWXMLNode {
    private (set) var comments = [CWXMLComment] ()
    private (set) var processingInstructions = [CWXMLProcessingInstruction] ()
    private (set) public var rootElement: CWXMLElement?
    
    private (set) public var url: URL?
    
    public let isStandalone = true
    public let characterEncoding : String? = "UTF-8"
    
    required public init () {
        super.init(nodeType: .Document)
    }
    
    public func noteURL (url: URL?) {
        self.url = url
    }
    
    func internalSetRootElement (elem: CWXMLElement) {
        rootElement = elem
        elem.parent = self
        addChild(node: elem)
    }
    
    public func setRootElement (elem: CWXMLElement?) throws {
        guard let elem = elem else {
            rootElement = nil
            return
        }
        
        if let eDoc = elem.document, eDoc !== self {
            throw CWXMLError.WrongDocument
        }
        
        internalSetRootElement(elem: elem)
    }
    
    public override var XML: String {
        get {
            var rv: String
            if let characterEncoding = characterEncoding {
                rv = "<?xml version=\"1.0\" encoding=\"" + characterEncoding + "\"?>\n"
            } else {
                rv = "<?xml version=\"1.0\"?>\n"
             }
            
            if let children = children {
                for child in children {
                    rv += child.XML
                }
            }
            
            return rv
        }
    }
    
    public func addComment (comment: CWXMLComment) {
        comments.append(comment)
        addChild(node: comment)
    }
    
    public func addProcessingInstruction (instruction: CWXMLProcessingInstruction) {
        processingInstructions.append(instruction)
        addChild(node: instruction)
    }
}
