//
//  SwiftRegex.swift
//  SwiftRegex
//
//  Created by John Holdsworth on 26/06/2014.
//  Copyright (c) 2014 John Holdsworth.
//
//  $Id: //depot/SwiftRegex/SwiftRegex.swift#37 $
//
//  This code is in the public domain from:
//  https://github.com/johnno1962/SwiftRegex
//

import Foundation

infix operator <~ { associativity none precedence 130 }

private let lock = DispatchSemaphore.init(value: 1)
private var swiftRegexCache = [String: NSRegularExpression]()

internal final class SwiftRegex: NSObject {
    var target:String
    var regex: NSRegularExpression
    
    init(target:String, pattern:String, options:NSRegularExpression.Options?) {
        /*if dispatch_semaphore_wait(lock, dispatch_time(dispatch_time_t(DispatchTime.now()), Int64(10 * NSEC_PER_MSEC))) != 0 {
            fatalError("This should never happen")
        }*/
        
        self.target = target
        if let regex = swiftRegexCache[pattern] {
            self.regex = regex
        } else {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options:
                    NSRegularExpression.Options.dotMatchesLineSeparators)
                swiftRegexCache[pattern] = regex
                self.regex = regex
            } catch let error as NSError {
                SwiftRegex.failure(message: "Error in pattern: \(pattern) - \(error)")
                self.regex = NSRegularExpression()
            }
        }
        lock.signal()
        super.init()
    }

    private static func failure(message: String) {
        fatalError("SwiftRegex: \(message)")
    }

    private var targetRange: NSRange {
        return NSRange(location: 0,length: target.utf16.count)
    }
    
    private func substring(range: NSRange) -> String? {
        if range.location != NSNotFound {
            return (target as NSString).substring(with: range)
        } else {
            return nil
        }
    }
    
    func doesMatch(options: NSRegularExpression.MatchingOptions!) -> Bool {
        return range(options: options).location != NSNotFound
    }
    
    func range(options: NSRegularExpression.MatchingOptions) -> NSRange {
        return regex.rangeOfFirstMatch(in: target as String, options: [], range: targetRange)
    }
    
    func match(options: NSRegularExpression.MatchingOptions) -> String? {
        return substring(range: range(options: options))
    }
    
    func groups() -> [String]? {
        return groupsForMatch(match: regex.firstMatch(in: target as String, options:
            NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: targetRange))
    }
    
    private func groupsForMatch(match: NSTextCheckingResult?) -> [String]? {
        guard let match = match else {
            return nil
        }
        var groups = [String]()
        for groupno in 0...regex.numberOfCaptureGroups {
            if let group = substring(range: match.rangeAt(groupno)) {
                groups += [group]
            } else {
                groups += ["_"] // avoids bridging problems
            }
        }
        return groups
    }
    
    subscript(groupno: Int) -> String? {
        get {
            return groups()?[groupno]
        }
        
        set(newValue) {
            if newValue == nil {
                return
            }
            
            for match in Array(matchResults().reversed()) {
                let replacement = regex.replacementString(for: match,
                                                          in: target as String, offset: 0, template: newValue!)
                let mut = NSMutableString(string: target)
                mut.replaceCharacters(in: match.rangeAt(groupno), with: replacement)
                
                target = mut as String
            }
        }
    }
    
    func matchResults() -> [NSTextCheckingResult] {
        let matches = regex.matches(in: target as String, options:
            NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: targetRange)
            as [NSTextCheckingResult]
        
        return matches
    }
    
    func ranges() -> [NSRange] {
        return matchResults().map { $0.range }
    }
    
    func matches() -> [String] {
        return matchResults().map( { self.substring(range: $0.range)!})
    }
    
    func allGroups() -> [[String]?] {
        return matchResults().map { self.groupsForMatch(match: $0) }
    }
    
    func dictionary(options: NSRegularExpression.MatchingOptions!) -> Dictionary<String,String> {
        var out = Dictionary<String,String>()
        for match in matchResults() {
            out[substring(range: match.rangeAt(1))!] = substring(range: match.rangeAt(2))!
        }
        return out
    }
    
    func substituteMatches(substitution: ((NSTextCheckingResult, UnsafeMutablePointer<ObjCBool>) -> String),
        options:NSRegularExpression.MatchingOptions) -> String {
            let out = NSMutableString()
            var pos = 0
            
            regex.enumerateMatches(in: target as String, options: options, range: targetRange ) {match, flags, stop in
                let matchRange = match!.range
                out.append( self.substring(range: NSRange(location:pos, length:matchRange.location-pos))!)
                out.append( substitution(match!, stop) )
                pos = matchRange.location + matchRange.length
            }
            
            out.append(substring(range: NSRange(location:pos, length:targetRange.length-pos))!)
            
            return out as String
    }
    
    var boolValue: Bool {
        return doesMatch(options: nil)
    }
}

extension String {
    subscript(pattern: String, options: NSRegularExpression.Options) -> SwiftRegex {
        return SwiftRegex(target: self, pattern: pattern, options: options)
    }
}

extension String {
    subscript(pattern: String) -> SwiftRegex {
        return SwiftRegex(target: self, pattern: pattern, options: nil)
    }
}

func <~ (left: SwiftRegex, right: String) -> String {
    return left.substituteMatches(substitution: {match, stop in
        return left.regex.replacementString( for: match,
                                             in: left.target as String, offset: 0, template: right )
        }, options: [])
}
