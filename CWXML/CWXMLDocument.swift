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

public enum CWXMLError: Error {
    case WrongDocument
    case ChildNotFound
    case CantInsertAncestor
    case NamespaceError
}


open class CWXMLNode {
    public init () {
    }
}


open class CWXMLDocument: CWXMLNode {
    
    var comments = [String] ()
    var processingInstructions = [String] ()
    private (set) public var rootElement: CWXMLElement?
    private (set) public var url: URL?
    
    required override public init () {
        super.init()
    }
    
    open func noteURL (url: URL?) {
        self.url = url
    }
    
    func internalSetRootElement (elem: CWXMLElement) {
        rootElement = elem
        elem.parent = self
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
}
