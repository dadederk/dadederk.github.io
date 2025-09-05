import Foundation
import Ignite

struct AccessibilityUpTo11Theme: Theme {
    var colorScheme: ColorScheme = .light
    
    // Custom colors for old paper/beige aesthetic in light mode
    var background: Color {
        return Color(hex: "#FEFBF3") // Very light beige background
    }
    
    var secondaryBackground: Color {
        return Color(hex: "#FAEBD7") // Antique white for headers/footers
    }
    
    var accent: Color {
        return Color(hex: "#1A1A1A") // Very dark brown for buttons/tags
    }
    
    var secondaryAccent: Color {
        return Color(hex: "#FAEBD7") // Antique white for button text
    }
    
    var primary: Color {
        return Color(hex: "#000000") // Pure black for static text
    }
    
    var secondary: Color {
        return Color(hex: "#444444") // Dark grey for secondary text
    }
    
    var link: Color {
        return Color(hex: "#2C2C2C") // Very dark grey for links
    }
    
    var hoveredLink: Color {
        return Color(hex: "#404040") // Slightly lighter dark grey on hover
    }
    
    var linkDecoration: TextDecoration = .underline
    
    var syntaxHighlighterTheme: HighlighterTheme = .xcodeLight
    
    // Additional colors for consistency with dark theme
    var cardBackground: Color {
        return Color(hex: "#FFFFFF") // Card backgrounds
    }
    
    var borderColor: Color {
        return Color(hex: "#D0D0D0") // Border colors
    }
    
    var mutedText: Color {
        return Color(hex: "#666666") // Muted text color
    }
    
    var success: Color {
        return Color(hex: "#28A745") // Success green
    }
    
    var warning: Color {
        return Color(hex: "#FFC107") // Warning yellow
    }
    
    var error: Color {
        return Color(hex: "#DC3545") // Error red
    }
}
