import Foundation
import Ignite

/// Parse markdown text to HTML for simple inline formatting
private func parseMarkdownToHTML(_ text: String) -> String {
    var result = text
    
    // Parse links [text](url)
    result = result.replacingOccurrences(of: #"\[([^\]]+)\]\(([^)]+)\)"#, with: "<a href=\"$2\">$1</a>", options: .regularExpression)
    
    // Parse bold text **text** or __text__
    result = result.replacingOccurrences(of: #"\*\*(.*?)\*\*"#, with: "<strong>$1</strong>", options: .regularExpression)
    result = result.replacingOccurrences(of: #"__(.*?)__"#, with: "<strong>$1</strong>", options: .regularExpression)
    
    // Parse italic text *text* or _text_
    result = result.replacingOccurrences(of: #"\*(.*?)\*"#, with: "<em>$1</em>", options: .regularExpression)
    result = result.replacingOccurrences(of: #"_(.*?)_"#, with: "<em>$1</em>", options: .regularExpression)
    
    return result
}

/// A reusable component for displaying a resource section with title and subsections
struct ResourceSection: HTML {
    let section: ResourceSectionData
    
    @MainActor var body: some HTML {
        Section {
            // Section heading - proper H2
            Text(section.title)
                .font(.title2)
                .fontWeight(.bold)
                .horizontalAlignment(.leading)
                .padding(.bottom)
            
            ForEach(section.subsections) { subsection in
                ResourceSubsection(subsection: subsection)
            }
        }
        .padding(.bottom)
    }
}

/// A reusable component for displaying a resource subsection with title and items
struct ResourceSubsection: HTML {
    let subsection: ResourceSubsectionData
    
    @MainActor var body: some HTML {
        VStack(alignment: .leading, spacing: 12) {
            // Subsection heading - proper H3
            Text(subsection.title)
                .font(.title3)
                .fontWeight(.semibold)
                .horizontalAlignment(.leading)
                .padding(.bottom, 4)
            
            // Resources list
            List(subsection.items) { item in
                Text(parseMarkdownToHTML(item.markdownText))
                    .font(.body)
            }
        }
        .padding(.bottom)
    }
}
