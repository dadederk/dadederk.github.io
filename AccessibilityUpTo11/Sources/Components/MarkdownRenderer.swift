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
        .style(.maxWidth, "800px")
        .style(.margin, "0 auto")
        .style(.padding, "20px")
    }
    
    private func parseMarkdown(_ content: String) -> [any HTML] {
        let lines = content.components(separatedBy: .newlines)
        var elements: [any HTML] = []
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty {
                // Empty line - add spacing
                elements.append(Text("").style(.height, "16px"))
            } else if trimmedLine.hasPrefix("# ") {
                // H1 heading
                let text = String(trimmedLine.dropFirst(2))
                elements.append(Text(text)
                    .font(.title1)
                    .fontWeight(.bold)
                    .padding(.vertical, 8))
            } else if trimmedLine.hasPrefix("## ") {
                // H2 heading
                let text = String(trimmedLine.dropFirst(3))
                elements.append(Text(text)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.vertical, 6))
            } else if trimmedLine.hasPrefix("### ") {
                // H3 heading
                let text = String(trimmedLine.dropFirst(4))
                elements.append(Text(text)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.vertical, 4))
            } else if trimmedLine.hasPrefix("#### ") {
                // H4 heading
                let text = String(trimmedLine.dropFirst(5))
                elements.append(Text(text)
                    .font(.title4)
                    .fontWeight(.bold)
                    .padding(.vertical, 4))
            } else if trimmedLine.hasPrefix("- ") {
                // Bullet point
                let text = String(trimmedLine.dropFirst(2))
                elements.append(Text("• \(parseInlineMarkdown(text))")
                    .font(.body)
                    .padding(.leading, 20)
                    .padding(.vertical, 2))
            } else {
                // Regular paragraph
                elements.append(Text(parseInlineMarkdown(trimmedLine))
                    .font(.body)
                    .padding(.vertical, 4))
            }
        }
        
        return elements
    }
    
    private func parseInlineMarkdown(_ text: String) -> String {
        var result = text
        
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
}
