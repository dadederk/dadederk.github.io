import Foundation
import SwiftUI
import Ignite

// XarraApp now uses the generic AppPage template
struct XarraApp: StaticPage {
    private let appPage = AppPage(appIdentifier: "xarra", appTitle: "Xarra", appPath: "/apps/xarra")
    
    var title: String { appPage.title }
    var path: String { appPage.path }
    
    @MainActor var body: some HTML {
        appPage.body
    }
}
