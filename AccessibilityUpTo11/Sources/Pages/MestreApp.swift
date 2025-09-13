import Foundation
import SwiftUI
import Ignite

// MestreApp now uses the generic AppPage template
struct MestreApp: StaticPage {
    private let appPage = AppPage(appIdentifier: "mestre", appTitle: "Mestre", appPath: "/apps/mestre")
    
    var title: String { appPage.title }
    var path: String { appPage.path }
    
    @MainActor var body: some HTML {
        appPage.body
    }
}
