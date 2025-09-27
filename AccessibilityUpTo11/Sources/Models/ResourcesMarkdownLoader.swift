import Foundation
import Ignite

// MARK: - Resources Markdown Loader

struct ResourcesMarkdownLoader {
    
    static func loadResources() -> ResourcesData {
        guard let contentURL = getResourcesURL() else { 
            print("Warning: Could not find resources.md file")
            return ResourcesData(sections: [])
        }
        
        do {
            let markdown = try String(contentsOf: contentURL)
            return parseResourcesMarkdown(markdown)
        } catch {
            print("Error loading resources content: \(error)")
            return ResourcesData(sections: [])
        }
    }
    
    private static func parseResourcesMarkdown(_ markdown: String) -> ResourcesData {
        var sections: [ResourceSectionData] = []
        var currentSection: ResourceSectionData?
        var currentSubsection: ResourceSubsectionData?
        
        let lines = markdown.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty { continue }
            
            // Check for main section (#)
            if trimmedLine.hasPrefix("# ") {
                // Save previous section if it exists
                if let section = currentSection {
                    sections.append(section)
                }
                
                    let sectionTitle = String(trimmedLine.dropFirst(2))
                    currentSection = ResourceSectionData(title: sectionTitle, subsections: [])
                    currentSubsection = nil
            }
            // Check for subsection (##)
            else if trimmedLine.hasPrefix("## ") {
                // Save previous subsection if it exists
                if let subsection = currentSubsection, var section = currentSection {
                    section.subsections.append(subsection)
                    currentSection = section
                }
                
                    let subsectionTitle = String(trimmedLine.dropFirst(3))
                    currentSubsection = ResourceSubsectionData(title: subsectionTitle, items: [])
            }
            // Check for list item (*)
            else if trimmedLine.hasPrefix("* ") {
                let itemLine = String(trimmedLine.dropFirst(2))
                if let resourceItem = parseResourceItem(itemLine) {
                    if var subsection = currentSubsection {
                        subsection.items.append(resourceItem)
                        currentSubsection = subsection
                        } else if var section = currentSection {
                            // If no subsection, create a default one for direct list items under main sections
                            let defaultSubsection = ResourceSubsectionData(title: "Resources", items: [resourceItem])
                            section.subsections.append(defaultSubsection)
                            currentSection = section
                        }
                }
            }
        }
        
        // Save the last section and subsection
        if let subsection = currentSubsection, var section = currentSection {
            section.subsections.append(subsection)
            currentSection = section
        }
        
        if let section = currentSection {
            sections.append(section)
        }
        
        return ResourcesData(sections: sections)
    }
    
    private static func parseResourceItem(_ itemLine: String) -> ResourceItem? {
        // Parse markdown link format: [title](url) - description by author (publisher)
        let linkPattern = #"\[([^\]]+)\]\(([^)]+)\)"#
        let regex = try? NSRegularExpression(pattern: linkPattern)
        let range = NSRange(itemLine.startIndex..., in: itemLine)
        
        guard let match = regex?.firstMatch(in: itemLine, range: range),
              let titleRange = Range(match.range(at: 1), in: itemLine),
              let urlRange = Range(match.range(at: 2), in: itemLine) else {
            return nil
        }
        
        let title = String(itemLine[titleRange])
        let url = String(itemLine[urlRange])
        
        // Extract description and author from the remaining text
        let remainingText = String(itemLine[itemLine.index(itemLine.startIndex, offsetBy: match.range.upperBound)...])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        var description: String?
        var author: String?
        var publisher: String?
        
        // Look for "by [author]" pattern - handle both linked and plain text authors
        let authorLinkedPattern = #"by \[([^\]]+)\]"#
        let authorPlainPattern = #"by ([^(\[]+?)(?:\s*\(|$)"#
        
        if let authorMatch = try? NSRegularExpression(pattern: authorLinkedPattern).firstMatch(in: remainingText, range: NSRange(remainingText.startIndex..., in: remainingText)),
           let authorRange = Range(authorMatch.range(at: 1), in: remainingText) {
            author = String(remainingText[authorRange])
        } else if let authorMatch = try? NSRegularExpression(pattern: authorPlainPattern).firstMatch(in: remainingText, range: NSRange(remainingText.startIndex..., in: remainingText)),
                  let authorRange = Range(authorMatch.range(at: 1), in: remainingText) {
            author = String(remainingText[authorRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Look for publisher in parentheses (but not author links)
        let publisherPattern = #"\(([^)]+)\)"#
        if let publisherMatch = try? NSRegularExpression(pattern: publisherPattern).firstMatch(in: remainingText, range: NSRange(remainingText.startIndex..., in: remainingText)),
           let publisherRange = Range(publisherMatch.range(at: 1), in: remainingText) {
            let publisherText = String(remainingText[publisherRange])
            // Only use as publisher if it doesn't look like a URL
            if !publisherText.hasPrefix("http") {
                publisher = publisherText
            }
        }
        
        // Extract description (everything before "by" or publisher info, clean up links)
        let descriptionText = remainingText
            .replacingOccurrences(of: authorLinkedPattern, with: "", options: String.CompareOptions.regularExpression)
            .replacingOccurrences(of: authorPlainPattern, with: "", options: String.CompareOptions.regularExpression)
            .replacingOccurrences(of: publisherPattern, with: "", options: String.CompareOptions.regularExpression)
            .replacingOccurrences(of: #"\[([^\]]+)\]\([^)]+\)"#, with: "$1", options: String.CompareOptions.regularExpression) // Convert remaining links to plain text
            .replacingOccurrences(of: #"\[([^\]]+)\]"#, with: "$1", options: String.CompareOptions.regularExpression) // Convert remaining markdown links to plain text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " - ", with: "")
            .replacingOccurrences(of: "  ", with: " ") // Clean up double spaces
            .replacingOccurrences(of: #"^\s*[:\-]\s*"#, with: "", options: String.CompareOptions.regularExpression) // Remove leading colons and dashes
            .replacingOccurrences(of: #"[,\s]+$"#, with: "", options: String.CompareOptions.regularExpression) // Remove trailing commas and spaces
        
        if !descriptionText.isEmpty && descriptionText != "-" {
            description = descriptionText
        }
        
        return ResourceItem(
            title: title,
            description: description,
            url: url,
            author: author,
            publisher: publisher,
            markdownText: itemLine
        )
    }
    
    private static func getResourcesURL() -> URL? {
        // Try to get the current working directory and build the path
        let currentPath = FileManager.default.currentDirectoryPath
        
        // Try different possible paths
        let possiblePaths = [
            "\(currentPath)/Resources",  // When running from AccessibilityUpTo11 directory
            "\(currentPath)/AccessibilityUpTo11/Resources",  // When running from Ignite directory
            "Resources",  // Relative path from AccessibilityUpTo11
            "AccessibilityUpTo11/Resources"  // Relative path from Ignite
        ]
        
        for path in possiblePaths {
            let url = URL(fileURLWithPath: "\(path)/resources.md")
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }
        
        print("Warning: Could not find resources.md file. Tried paths: \(possiblePaths)")
        return nil
    }
}
