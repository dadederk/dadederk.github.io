import Foundation
import Ignite

// Component for rendering markdown content with proper styling
struct MarkdownRenderer: HTML {
    let content: String
    
    @MainActor var body: some HTML {
        VStack(alignment: .leading) {
            ForEach(parseMarkdown(content)) { element in
                element
            }
        }
        .horizontalAlignment(.leading)
        .class("markdown-content")
    }
    
    private func parseMarkdown(_ content: String) -> [any HTML] {
        let lines = content.components(separatedBy: .newlines)
        var elements: [any HTML] = []
        var i = 0
        
        while i < lines.count {
            let line = lines[i]
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty {
                // Empty line - add spacing
                elements.append(Text("").style(.height, "16px"))
                i += 1
            } else if trimmedLine.hasPrefix("```") {
                // Code block - collect all lines until closing ```
                let language = String(trimmedLine.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                var codeLines: [String] = []
                i += 1
                
                // Collect code lines until we find closing ```
                while i < lines.count {
                    let codeLine = lines[i]
                    if codeLine.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                        break
                    }
                    codeLines.append(codeLine)
                    i += 1
                }
                
                // Create code block element
                let codeContent = codeLines.joined(separator: "\n")
                let highlighterLanguage: HighlighterLanguage? = language.isEmpty ? nil : HighlighterLanguage(rawValue: language)
                elements.append(CodeBlock(highlighterLanguage) {
                    codeContent
                }
                .padding(.vertical, 12))
                i += 1
            } else if trimmedLine.hasPrefix("# ") {
                // H1 heading
                let text = String(trimmedLine.dropFirst(2))
                elements.append(Text(text)
                    .font(.title1)
                    .fontWeight(.bold)
                    .padding(.vertical, 8))
                i += 1
            } else if trimmedLine.hasPrefix("## ") {
                // H2 heading
                let text = String(trimmedLine.dropFirst(3))
                elements.append(Text(text)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.vertical, 6))
                i += 1
            } else if trimmedLine.hasPrefix("### ") {
                // H3 heading
                let text = String(trimmedLine.dropFirst(4))
                elements.append(Text(text)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.vertical, 4))
                i += 1
            } else if trimmedLine.hasPrefix("#### ") {
                // H4 heading
                let text = String(trimmedLine.dropFirst(5))
                elements.append(Text(text)
                    .font(.title4)
                    .fontWeight(.bold)
                    .padding(.vertical, 4))
                i += 1
            } else if trimmedLine.hasPrefix("![") {
                // Image syntax: ![alt text](image_url)
                if let imageElement = parseImageMarkdown(trimmedLine) {
                    elements.append(imageElement)
                }
                i += 1
            } else if trimmedLine.hasPrefix("- ") {
                // Bullet point
                let text = String(trimmedLine.dropFirst(2))
                elements.append(Text("• \(parseInlineMarkdown(text))")
                    .font(.body)
                    .padding(.leading, 20)
                    .padding(.vertical, 2))
                i += 1
            } else {
                // Regular paragraph
                elements.append(Text(parseInlineMarkdown(trimmedLine))
                    .font(.body)
                    .padding(.vertical, 4))
                i += 1
            }
        }
        
        return elements
    }
    
    private func parseImageMarkdown(_ text: String) -> (any HTML)? {
        // Parse image syntax: ![alt text](image_url)
        let pattern = #"!\[([^\]]*)\]\(([^)]+)\)"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count)) else {
            return nil
        }
        
        let altTextRange = Range(match.range(at: 1), in: text)
        let imageURLRange = Range(match.range(at: 2), in: text)
        
        guard let altTextRange = altTextRange,
              let imageURLRange = imageURLRange else {
            return nil
        }
        
        let altText = String(text[altTextRange])
        let imageURL = String(text[imageURLRange])
        
        return Section {
            Image(imageURL, description: altText.isEmpty ? "Image" : altText)
                .resizable()
                .cornerRadius(8)
        }
        .horizontalAlignment(.center)
        .padding(.vertical, 12)
    }
    
    private func parseInlineMarkdown(_ text: String) -> String {
        var result = text
        
        // Parse hashtags #tag (must be done before other parsing to avoid conflicts)
        result = parseHashtags(result)
        
        // Parse bold text **text** or __text__
        result = result.replacingOccurrences(of: #"\*\*(.*?)\*\*"#, with: "<strong>$1</strong>", options: .regularExpression)
        result = result.replacingOccurrences(of: #"__(.*?)__"#, with: "<strong>$1</strong>", options: .regularExpression)
        
        // Parse italic text *text* or _text_
        result = result.replacingOccurrences(of: #"\*(.*?)\*"#, with: "<em>$1</em>", options: .regularExpression)
        result = result.replacingOccurrences(of: #"_(.*?)_"#, with: "<em>$1</em>", options: .regularExpression)
        
        // Parse links [text](url)
        result = result.replacingOccurrences(of: #"\[([^\]]+)\]\(([^)]+)\)"#, with: "<a href=\"$2\">$1</a>", options: .regularExpression)
        
        return result
    }
    
    /// Parse hashtags in text and convert them to clickable links
    private func parseHashtags(_ text: String) -> String {
        // Pattern to match hashtags: # followed by word characters, hyphens, or underscores
        // Simple pattern that works reliably
        let hashtagPattern = #"#([a-zA-Z0-9_-]+)"#
        
        guard let regex = try? NSRegularExpression(pattern: hashtagPattern, options: []) else {
            return text
        }
        
        let range = NSRange(location: 0, length: text.count)
        let matches = regex.matches(in: text, options: [], range: range)
        
        var result = text
        // Process matches in reverse order to avoid index shifting
        for match in matches.reversed() {
            if let hashtagRange = Range(match.range(at: 1), in: text) {
                let hashtag = String(text[hashtagRange])
                let tagPath = "/365-days-ios-accessibility/tag/\(hashtag.lowercased().replacingOccurrences(of: " ", with: "-"))"
                let linkHTML = "<a href=\"\(tagPath)\" class=\"hashtag-link\">#\(hashtag)</a>"
                
                if let fullRange = Range(match.range, in: text) {
                    result.replaceSubrange(fullRange, with: linkHTML)
                }
            }
        }
        
        return result
    }
}
