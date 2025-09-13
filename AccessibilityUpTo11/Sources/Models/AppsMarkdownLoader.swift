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
            
            let features = (contentData.features ?? []).compactMap { featureDict -> FeatureItem? in
                guard let title = featureDict["title"],
                      let description = featureDict["description"] else {
                    return nil
                }
                return FeatureItem(
                    title: title,
                    description: description,
                    imagePath: featureDict["imagePath"],
                    imageDescription: featureDict["imageDescription"]
                )
            }
            
            return AppItem(
                title: contentData.title,
                subtitle: contentData.subtitle ?? "",
                description: contentData.description,
                nameOrigin: contentData.nameOrigin ?? "",
                imagePath: contentData.imagePath ?? "",
                imageDescription: contentData.imageDescription ?? "",
                actions: actions,
                features: features,
                supportText: contentData.supportText ?? "Need help or have questions about \(contentData.title)? We're here to help!",
                contactEmail: contentData.contactEmail ?? "dadederk@icloud.com"
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
                
                if key == "actions" || key == "features" {
                    // Parse arrays separately
                    continue
                } else if value.starts(with: "\"") && value.hasSuffix("\"") {
                    metadata[key] = String(value.dropFirst().dropLast())
                } else if value == "" || value == "\"\"" {
                    metadata[key] = ""
                } else {
                    metadata[key] = value
                }
            }
        }
        
        // Parse actions and features separately
        let actionsSection = extractArrayFromFrontmatter(frontmatter, key: "actions")
        let featuresSection = extractArrayFromFrontmatter(frontmatter, key: "features")
        
        return AppsData.AppContentItem(
            title: metadata["title"] as? String ?? "",
            subtitle: metadata["subtitle"] as? String,
            description: content,
            nameOrigin: metadata["nameOrigin"] as? String,
            imagePath: metadata["imagePath"] as? String,
            imageDescription: metadata["imageDescription"] as? String,
            actions: actionsSection,
            features: featuresSection,
            supportText: metadata["supportText"] as? String,
            contactEmail: metadata["contactEmail"] as? String,
            date: Date() // Default date for now
        )
    }
    
    private static func extractArrayFromFrontmatter(_ frontmatter: String, key: String) -> [[String: String]]? {
        let lines = frontmatter.components(separatedBy: .newlines)
        var items: [[String: String]] = []
        var isInArray = false
        var currentItem: [String: String] = [:]
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine == "\(key):" {
                isInArray = true
                continue
            }
            
            if isInArray {
                if trimmedLine.starts(with: "- ") {
                    // Save previous item if it exists
                    if !currentItem.isEmpty {
                        items.append(currentItem)
                        currentItem = [:]
                    }
                    
                    // Parse the first property of the new item
                    let itemLine = String(trimmedLine.dropFirst(2))
                    if let colonIndex = itemLine.firstIndex(of: ":") {
                        let itemKey = String(itemLine[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                        let itemValue = String(itemLine[itemLine.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                        currentItem[itemKey] = itemValue
                    }
                } else if trimmedLine.contains(":") && !trimmedLine.isEmpty {
                    // Continue parsing item properties
                    if let colonIndex = trimmedLine.firstIndex(of: ":") {
                        let itemKey = String(trimmedLine[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                        let itemValue = String(trimmedLine[trimmedLine.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                        currentItem[itemKey] = itemValue
                    }
                } else if trimmedLine.isEmpty || (!trimmedLine.starts(with: " ") && trimmedLine.contains(":")) {
                    // End of array section
                    break
                }
            }
        }
        
        // Add the last item
        if !currentItem.isEmpty {
            items.append(currentItem)
        }
        
        return items.isEmpty ? nil : items
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
