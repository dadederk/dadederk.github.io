import Foundation
import Ignite

// MARK: - Markdown Content Loader

struct MarkdownContentLoader {
    
    static func loadMoreContent() -> MoreContentData {
        let publications = loadPublications()
        let talks = loadTalks()
        let podcasts = loadPodcasts()
        
        return MoreContentData(
            publications: publications,
            talks: talks,
            podcasts: podcasts
        )
    }
    
    static func loadAllContentItems() -> [MoreContentData.ContentItem] {
        guard let contentURL = getContentURL() else { return [] }
        let publications = loadContent(from: contentURL, type: "publication")
        let talks = loadContent(from: contentURL, type: "talk")
        let podcasts = loadContent(from: contentURL, type: "podcast")
        
        return (publications + talks + podcasts).sorted { $0.date > $1.date }
    }
    
    private static func loadPublications() -> [PublicationItem] {
        guard let contentURL = getContentURL() else { return [] }
        return loadContent(from: contentURL, type: "publication").compactMap { contentData -> PublicationItem? in
            guard let actionsData = contentData.actions else {
                return nil
            }
            
            let actions = actionsData.compactMap { actionDict -> ActionItem? in
                guard let title = actionDict["title"],
                      let target = actionDict["target"],
                      let style = actionDict["style"] else {
                    return nil
                }
                return ActionItem(title: title, target: target, style: style)
            }
            
            return PublicationItem(
                title: contentData.title,
                subtitle: contentData.subtitle,
                description: contentData.description,
                publisher: contentData.publisher ?? "",
                imagePath: contentData.imagePath ?? "",
                imageDescription: contentData.imageDescription ?? "",
                actions: actions
            )
        }
    }
    
    private static func loadTalks() -> [TalkItem] {
        guard let contentURL = getContentURL() else { return [] }
        return loadContent(from: contentURL, type: "talk").compactMap { contentData -> TalkItem? in
            guard let actionsData = contentData.actions else {
                return nil
            }
            
            let actions = actionsData.compactMap { actionDict -> ActionItem? in
                guard let title = actionDict["title"],
                      let target = actionDict["target"],
                      let style = actionDict["style"] else {
                    return nil
                }
                return ActionItem(title: title, target: target, style: style)
            }
            
            return TalkItem(
                title: contentData.title,
                subtitle: contentData.subtitle ?? "",
                description: contentData.description,
                imagePath: contentData.imagePath,
                imageDescription: contentData.imageDescription,
                actions: actions
            )
        }
    }
    
    private static func loadPodcasts() -> [PodcastItem] {
        guard let contentURL = getContentURL() else { return [] }
        return loadContent(from: contentURL, type: "podcast").compactMap { contentData -> PodcastItem? in
            guard let actionsData = contentData.actions else {
                return nil
            }
            
            let actions = actionsData.compactMap { actionDict -> ActionItem? in
                guard let title = actionDict["title"],
                      let target = actionDict["target"],
                      let style = actionDict["style"] else {
                    return nil
                }
                return ActionItem(title: title, target: target, style: style)
            }
            
            return PodcastItem(
                title: contentData.title,
                subtitle: contentData.subtitle ?? "",
                description: contentData.description,
                imagePath: contentData.imagePath,
                imageDescription: contentData.imageDescription,
                actions: actions
            )
        }
    }
    
    private static func loadContent(from contentURL: URL, type: String) -> [MoreContentData.ContentItem] {
        do {
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(at: contentURL, includingPropertiesForKeys: nil)
            
            var contentItems: [MoreContentData.ContentItem] = []
            
            for file in files where file.pathExtension == "md" {
                do {
                    let markdown = try String(contentsOf: file)
                    if let contentItem = parseMarkdownContent(markdown, expectedType: type) {
                        contentItems.append(contentItem)
                    }
                } catch {
                    print("Error loading content from \(file): \(error)")
                }
            }
            
            return contentItems.sorted { $0.date > $1.date }
        } catch {
            print("Error loading content from \(contentURL): \(error)")
            return []
        }
    }
    
    private static func parseMarkdownContent(_ markdown: String, expectedType: String) -> MoreContentData.ContentItem? {
        // Simple YAML frontmatter parser
        let components = markdown.components(separatedBy: "---")
        guard components.count >= 3 else { return nil }
        
        let frontmatter = components[1]
        let content = components.dropFirst(2).joined(separator: "---").trimmingCharacters(in: .whitespacesAndNewlines)
        
        var metadata: [String: Any] = [:]
        
        for line in frontmatter.components(separatedBy: .newlines) {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.isEmpty || trimmedLine.starts(with: "#") { continue }
            
            if let colonIndex = trimmedLine.firstIndex(of: ":") {
                let key = String(trimmedLine[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                let value = String(trimmedLine[trimmedLine.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                
                if key == "actions" {
                    // Parse actions array
                    continue // We'll handle this separately
                } else if value.starts(with: "\"") && value.hasSuffix("\"") {
                    metadata[key] = String(value.dropFirst().dropLast())
                } else if value == "" || value == "\"\"" {
                    metadata[key] = ""
                } else {
                    metadata[key] = value
                }
            }
        }
        
        // Parse actions separately
        let actionsSection = extractActionsFromFrontmatter(frontmatter)
        
        guard let type = metadata["type"] as? String, type == expectedType else { return nil }
        
        // Parse date
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        let date = (metadata["date"] as? String).flatMap { dateFormatter.date(from: $0) } ?? Date()
        
        return MoreContentData.ContentItem(
            title: metadata["title"] as? String ?? "",
            subtitle: metadata["subtitle"] as? String,
            description: content,
            publisher: metadata["publisher"] as? String,
            imagePath: metadata["imagePath"] as? String,
            imageDescription: metadata["imageDescription"] as? String,
            actions: actionsSection,
            date: date
        )
    }
    
    private static func extractActionsFromFrontmatter(_ frontmatter: String) -> [[String: String]]? {
        let lines = frontmatter.components(separatedBy: .newlines)
        var actions: [[String: String]] = []
        var isInActions = false
        var currentAction: [String: String] = [:]
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine == "actions:" {
                isInActions = true
                continue
            }
            
            if isInActions {
                if trimmedLine.starts(with: "- ") {
                    // Save previous action if it exists
                    if !currentAction.isEmpty {
                        actions.append(currentAction)
                        currentAction = [:]
                    }
                    
                    // Parse the first property of the new action
                    let actionLine = String(trimmedLine.dropFirst(2))
                    if let colonIndex = actionLine.firstIndex(of: ":") {
                        let key = String(actionLine[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                        let value = String(actionLine[actionLine.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                        currentAction[key] = value
                    }
                } else if trimmedLine.contains(":") && !trimmedLine.isEmpty {
                    // Continue parsing action properties
                    if let colonIndex = trimmedLine.firstIndex(of: ":") {
                        let key = String(trimmedLine[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                        let value = String(trimmedLine[trimmedLine.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                        currentAction[key] = value
                    }
                } else if trimmedLine.isEmpty || (!trimmedLine.starts(with: " ") && trimmedLine.contains(":")) {
                    // End of actions section
                    break
                }
            }
        }
        
        // Add the last action
        if !currentAction.isEmpty {
            actions.append(currentAction)
        }
        
        return actions.isEmpty ? nil : actions
    }
    
    private static func getContentURL() -> URL? {
        // Try to get the current working directory and build the path
        let currentPath = FileManager.default.currentDirectoryPath
        
        // Try different possible paths
        let possiblePaths = [
            "\(currentPath)/MoreContentData",  // When running from AccessibilityUpTo11 directory
            "\(currentPath)/AccessibilityUpTo11/MoreContentData",  // When running from Ignite directory
            "MoreContentData",  // Relative path from AccessibilityUpTo11
            "AccessibilityUpTo11/MoreContentData"  // Relative path from Ignite
        ]
        
        var isDirectory: ObjCBool = false
        
        for path in possiblePaths {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                return url
            }
        }
        
        print("Warning: Could not find MoreContentData directory. Tried paths: \(possiblePaths)")
        return nil
    }
}
