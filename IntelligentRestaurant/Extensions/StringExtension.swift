//
//  StringExtension.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/12.
//

import Foundation

extension String {
    
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    func isPasswordValid() -> Bool{
        let passwordFormat = "^(?=.*[A-Z])(?=.*[a-z])(?=.*?[0-9])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordFormat)
        return passwordTest.evaluate(with: self)
    }
    
    func secToMin() -> String {
        guard let sec = Int(self) else { return "-1" }
        let min = sec / 60
        return "\(min)"
    }
    
    func secToMinAndSec() -> String {
        guard var sec = Int(self) else { return "-1" }
        let min = sec / 60
        sec = sec % 60;
        return "\(min):\(sec)"
    }
}
