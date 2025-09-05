import Foundation
import Ignite

// MARK: - Apps Markdown Content Loader

struct AppsMarkdownLoader {
    
    static func loadAppsContent() -> AppsData {
        let apps = loadApps()
        return AppsData(apps: apps)
    }
    
    private static func loadApps() -> [AppItem] {
        guard let appsURL = getAppsURL() else { return [] }
        return loadContent(from: appsURL).compactMap { contentData -> AppItem? in
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
            
            return AppItem(
                title: contentData.title,
                subtitle: contentData.subtitle ?? "",
                description: contentData.description,
                nameOrigin: contentData.nameOrigin ?? "",
                imagePath: contentData.imagePath ?? "",
                imageDescription: contentData.imageDescription ?? "",
                actions: actions
            )
        }
    }
    
    private static func loadContent(from appsURL: URL) -> [AppsData.AppContentItem] {
        do {
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(at: appsURL, includingPropertiesForKeys: nil)
            
            var contentItems: [AppsData.AppContentItem] = []
            
            for file in files where file.pathExtension == "md" {
                do {
                    let markdown = try String(contentsOf: file)
                    if let contentItem = parseMarkdownContent(markdown) {
                        contentItems.append(contentItem)
                    }
                } catch {
                    print("Error loading app content from \(file): \(error)")
                }
            }
            
            return contentItems.sorted { $0.date > $1.date }
        } catch {
            print("Error loading apps content from \(appsURL): \(error)")
            return []
        }
    }
    
    private static func parseMarkdownContent(_ markdown: String) -> AppsData.AppContentItem? {
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
        
        return AppsData.AppContentItem(
            title: metadata["title"] as? String ?? "",
            subtitle: metadata["subtitle"] as? String,
            description: content,
            nameOrigin: metadata["nameOrigin"] as? String,
            imagePath: metadata["imagePath"] as? String,
            imageDescription: metadata["imageDescription"] as? String,
            actions: actionsSection,
            date: Date() // Default date for now
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
    
    private static func getAppsURL() -> URL? {
        // Try to get the current working directory and build the path
        let currentPath = FileManager.default.currentDirectoryPath
        
        // Try different possible paths
        let possiblePaths = [
            "\(currentPath)/AppsData",  // When running from AccessibilityUpTo11 directory
            "\(currentPath)/AccessibilityUpTo11/AppsData",  // When running from Ignite directory
            "AppsData",  // Relative path from AccessibilityUpTo11
            "AccessibilityUpTo11/AppsData"  // Relative path from Ignite
        ]
        
        var isDirectory: ObjCBool = false
        
        for path in possiblePaths {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                return url
            }
        }
        
        print("Warning: Could not find AppsData directory. Tried paths: \(possiblePaths)")
        return nil
    }
}
