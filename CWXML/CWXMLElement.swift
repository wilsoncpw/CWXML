//
//  CWXMLElement.swift
//  XMLTest
//
//  Created by Colin Wilson on 12/10/2017.
//  Copyright © 2017 Colin Wilson. All rights reserved.
//

import Foundation

public func splitQName (qname: String)->(prefix: String, localName: String) {
    if var p = qname.index(of: ":") {
        let _prefix = String (qname [..<p])
        p = qname.index(p, offsetBy: 1)
        return (prefix: _prefix, localName: String (qname [p...]))
    } else {
        return (prefix: "", localName: qname)
    }
}

open class CWXMLElement: CWXMLNode {
    weak var parent: CWXMLNode?
    public let name: String             // Qualified name
    var attributes : [String: String]?
    var namespaces: [String: String]?
    public var text: String?
    private (set) public var children : [CWXMLElement]?
    
    private var _uri: String?
    private var _prefix: String?
    private var _localName: String?
    
    public var prefix: String {
        if _prefix == nil {
            let px = splitQName(qname: name)
            _prefix = px.prefix
            _localName = px.localName
        }
        return _prefix!
    }
    
    public var namespaceUri: String? {
        if _uri == nil {
            guard let namespaces = namespaces else {
                return nil
            }
            
            _uri = namespaces [prefix]
        }
        return _uri!
    }
    
    public var localName: String {
        let _ = prefix
        return _localName ?? ""
    }
    
    public init (name: String) {
        self.name = name
    }
    
    public init (name: String, URI: String?) {
        self.name = name
    }
    
    func internalAppendChild (elem: CWXMLElement) {
        if children == nil {
            children = [CWXMLElement] ()
        }

        children!.append(elem)
        elem.parent = self
    }
    
    public func isAncestorOf (_ elem: CWXMLElement)->Bool {
        var p = elem
        
        while let pElem = p.parentElement {
            if pElem === self {
                return true
            }
            p = pElem
        }
        return false
    }
}

extension CWXMLElement: Equatable {
    public static func ==(lhs: CWXMLElement, rhs: CWXMLElement) -> Bool {
        return lhs === rhs
    }
}

public extension CWXMLElement {
    public var parentElement: CWXMLElement? {
        return parent as? CWXMLElement ?? nil
    }
    
    public var document: CWXMLDocument? {
        var p = self
        
        while let px = p.parent as? CWXMLElement {
            p = px
        }
        return p.parent as? CWXMLDocument ?? nil
    }
    
    public func attribute (forName name: String) -> String? {
        return attributes? [name]
    }
    
 
    @discardableResult public func appendChild (elem: CWXMLElement) throws -> CWXMLElement {
        func _appendChild (elem: CWXMLElement) throws {
            
            // Before removing the elem from it's old parent, check that it's not
            // our ancestor.  Otherwise we're fucked!
            if elem.isAncestorOf (self) {
                throw CWXMLError.CantInsertAncestor
            }
            
            // Remove the elem from its parent's children
            if let eParent = elem.parentElement {
                try eParent.removeChild (elem: elem)
            }
            internalAppendChild(elem: elem)
        }
        
        // If we have a document, and so does elem, check that they match
        if let document = document {
            if let eDoc = elem.document {
                guard document === eDoc else {
                    throw CWXMLError.WrongDocument
                }
            }
            try _appendChild(elem: elem)
        } else {
            // We don't have a document - check that the elem doesn't either
            guard elem.document == nil else {
                throw CWXMLError.WrongDocument
            }
            try _appendChild(elem: elem)
        }
        return elem
    }
    
    @discardableResult public func removeChild (elem: CWXMLElement) throws ->CWXMLElement {
        if children == nil {
            throw CWXMLError.ChildNotFound
        }
        guard let idx = children!.index (of: elem) else {
            throw CWXMLError.ChildNotFound
        }
        
        elem.parent = nil
        return children!.remove(at: idx)
    }
}

public extension CWXMLElement {
    public func namespace (forPrefix prefix: String) -> String? {
        return namespaces? [prefix]
    }
    
    public func resolveNamespace (forName qname: String, defaultPrefix: String = "") -> String? {
        let s = qname.components(separatedBy:":")
        
        if s.count > 1 {
            return namespace(forPrefix:s [0])
        }
        return namespace(forPrefix:defaultPrefix)
    }
    
    public func elements(forLocalName name: String, namespaceUri: String?) -> [CWXMLElement] {
        guard let children = children else {
            return [CWXMLElement] ()
        }
        
        return children.filter() {
            elem in
            return (namespaceUri == nil || (elem.namespaceUri != nil && elem.namespaceUri! == namespaceUri!)) && name == elem.localName
        }
    }
    
    public func elements(forName name: String) -> [CWXMLElement] {
        let s = name.components(separatedBy: ":")
        
        if s.count >= 2 {
            guard let namespaces = namespaces, let namespaceUri = namespaces [s [0]] else {
                return [CWXMLElement] ()
            }
            return elements(forLocalName: s [1], namespaceUri: namespaceUri)
        }
        
        guard let children = children else {
            return [CWXMLElement] ()
        }
        
        return children.filter() {
            elem in
            elem.name == name
        }
    }
}
