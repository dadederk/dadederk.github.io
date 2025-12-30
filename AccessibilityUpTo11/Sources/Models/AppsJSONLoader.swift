import Foundation
import Ignite

// MARK: - Apps JSON Content Loader

struct AppsJSONLoader {
    
    static func loadAppsContent() -> AppsData {
        let apps = loadApps()
        return AppsData(apps: apps)
    }
    
    private static func loadApps() -> [AppItem] {
        guard let appsURL = getAppsURL() else { return [] }
        
        do {
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(at: appsURL, includingPropertiesForKeys: nil)
            
            var apps: [AppItem] = []
            
            for file in files where file.pathExtension == "json" {
                do {
                    let data = try Data(contentsOf: file)
                    let decoder = JSONDecoder()
                    let appData = try decoder.decode(AppItemJSON.self, from: data)
                    apps.append(appData.toAppItem())
                } catch {
                    print("Error loading app content from \(file): \(error)")
                }
            }
            
            return apps.sorted { $0.title < $1.title }
        } catch {
            print("Error loading apps content from \(appsURL): \(error)")
            return []
        }
    }
    
    private static func getAppsURL() -> URL? {
        let currentPath = FileManager.default.currentDirectoryPath
        
        let possiblePaths = [
            "\(currentPath)/AppsData",
            "\(currentPath)/AccessibilityUpTo11/AppsData",
            "AppsData",
            "AccessibilityUpTo11/AppsData"
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

// MARK: - JSON Decoding Models

private struct AppItemJSON: Codable {
    let title: String
    let subtitle: String
    let description: String
    let nameOrigin: String
    let imagePath: String
    let imageDescription: String
    let platforms: [String]
    let actions: [ActionItem]
    let featureGroups: [FeatureGroupJSON]
    let features: [FeatureItemJSON]? // Optional for backward compatibility
    let accessibility: String?
    let whySection: String?
    let supportText: String?
    let contactEmail: String?
    
    func toAppItem() -> AppItem {
        // Convert feature groups
        let groups = featureGroups.map { group in
            FeatureGroup(
                title: group.title,
                features: group.features.map { feature in
                    FeatureItem(
                        title: feature.title,
                        description: feature.description,
                        imagePath: feature.imagePath,
                        imageDescription: feature.imageDescription
                    )
                }
            )
        }
        
        // Convert flat features if available (for backward compatibility)
        let flatFeatures = (features ?? []).map { feature in
            FeatureItem(
                title: feature.title,
                description: feature.description,
                imagePath: feature.imagePath,
                imageDescription: feature.imageDescription
            )
        }
        
        return AppItem(
            title: title,
            subtitle: subtitle,
            description: description,
            nameOrigin: nameOrigin,
            imagePath: imagePath,
            imageDescription: imageDescription,
            platforms: platforms,
            actions: actions,
            featureGroups: groups,
            features: flatFeatures,
            accessibility: accessibility,
            whySection: whySection,
            supportText: supportText ?? "Need help or have questions about \(title)? We're here to help!",
            contactEmail: contactEmail ?? "dadederk@icloud.com"
        )
    }
}

private struct FeatureGroupJSON: Codable {
    let title: String
    let features: [FeatureItemJSON]
}

private struct FeatureItemJSON: Codable {
    let title: String
    let description: String
    let imagePath: String?
    let imageDescription: String?
}

