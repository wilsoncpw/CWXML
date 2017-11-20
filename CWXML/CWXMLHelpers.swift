//
//  CWXMLHelpers.swift
//  CWXML
//
//  Created by Colin Wilson on 17/11/2017.
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

public func stringByDecodingXMLEntities (_ st: String)->String? {
    
    if st.count < 4 {
        return st
    }
    
    var rv = ""
    var s = st
    
    while let idx = s.index (of: "&") {
        
        rv = rv + s.substring (to: idx)
        s = s.substring (from: s.index (idx, offsetBy: 1))
        
        if let eidx = s.index (of: ";") {
            switch (s.substring(to: eidx)) {
            case "amp": rv += "&"
            case "quot": rv += "\""
            case "apos": rv += "'"
            case "lt": rv += "<"
            case "gt": rv += ">"
            default: return nil
            }
            s = s.substring(from: s.index (eidx, offsetBy:1))
            
        } else {
            return nil
        }
    }
    
    rv += s
    return rv
}

public func stringByEncodingXMLEntities (_ st: String)->String {
    if st == "" {
        return ""
    }
    
    var rv = ""
    var s = st
    var p = s.startIndex
    
    while p != s.endIndex {
        
        let ch : Character = st [p]
        switch ch {
        case "&": rv += "&amp;";
        case "\"": rv += "&quot;"
        case "'": rv += "&apos;"
        case "<": rv += "&lt;"
        case ">": rv += "&gt;"
        default : rv.append (ch)
        }
        p = s.characters.index (p, offsetBy: 1)
    }
    
    return rv
    
}

