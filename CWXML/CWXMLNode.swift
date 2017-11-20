//
//  CWXMLNode.swift
//  CWXML
//
//  Created by Colin Wilson on 17/11/2017.
//  Copyright © 2017 Colin Wilson. All rights reserved.
//

import Foundation

public class CWXMLNode : Equatable {
    public enum NodeType {
        case Document
        case Element
        case Comment
        case ProcessingInstruction
    }
    
    public let nodeType: NodeType
    private (set) public var children : [CWXMLNode]?
    private (set) public var level = 0
    
    public static func ==(lhs: CWXMLNode, rhs: CWXMLNode) -> Bool {
        return lhs === rhs
    }
    
    public init (nodeType: NodeType) {
        self.nodeType = nodeType
    }
    
    public var XML: String {
        return ""
    }
    
    public var stringValue: String? {
        return nil
    }
    
    internal func addChild (node: CWXMLNode) {
        if children == nil {
            children = [CWXMLNode] ()
        }
        children!.append(node)
        node.level = level + 1
    }
    
    internal func removeChild (node: CWXMLNode) {
        guard let idx = children?.index(of: node) else {
            return
        }
        children!.remove(at: idx)
        if children!.count == 0 {
            children = nil
        }
    }
}

