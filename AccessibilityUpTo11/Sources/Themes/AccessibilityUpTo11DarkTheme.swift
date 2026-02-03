import Foundation
import Ignite

struct AccessibilityUpTo11DarkTheme: Theme {
    var colorScheme: ColorScheme = .dark
    
    // Custom colors for dark mode with proper contrast ratios
    var background: Color {
        return Color(hex: "#1A1A1A") // Very dark background for better contrast
    }
    
    var secondaryBackground: Color {
        return Color(hex: "#2D2D2D") // Slightly lighter dark grey for cards/panels
    }

    var tertiaryBackground: Color {
        return Color(hex: "#2B3035")
    }
    
    var accent: Color {
        return Color(hex: "#FAEBD7") // Antique white for buttons/tags
    }
    
    var secondaryAccent: Color {
        return Color(hex: "#1A1A1A") // Very dark brown for button text
    }
    
    var primary: Color {
        return Color(hex: "#FFFFFF") // Pure white for primary text
    }
    
    var secondary: Color {
        return Color(hex: "#E0E0E0") // Light grey for secondary text
    }

    var tertiary: Color {
        return Color(red: 222, green: 226, blue: 230, opacity: 50%)
    }
    
    var link: Color {
        return Color(hex: "#6EA8FE") // Light blue for links
    }
    
    var hoveredLink: Color {
        return Color(hex: "#9EC5FE") // Even lighter blue on hover
    }
    
    var linkDecoration: TextDecoration = .underline
    
    var syntaxHighlighterTheme: HighlighterTheme = .xcodeDark
    
    // Additional colors for better dark mode support
    var cardBackground: Color {
        return Color(hex: "#2D2D2D") // Card backgrounds
    }
    
    var border: Color {
        return Color(hex: "#404040") // Border colors
    }
    
    var mutedText: Color {
        return Color(hex: "#B0B0B0") // Muted text color
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
