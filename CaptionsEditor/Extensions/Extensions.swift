//
//  Exensions.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/30/23.
//

import Foundation


import CoreGraphics

extension CGKeyCode
{
    static let kVK_Option: CGKeyCode = 0x3A
    static let kVK_RightOption: CGKeyCode = 0x3D
    static let kVK_Command: CGKeyCode = 0x37

    
    var isPressed: Bool {
        CGEventSource.keyState(.combinedSessionState, key: self)
    }
    
    static var optionKeyPressed: Bool {
        return Self.kVK_Option.isPressed || Self.kVK_RightOption.isPressed
    }
    
    static var commandKeyPressed: Bool {
        return Self.kVK_Command.isPressed
    }
}
