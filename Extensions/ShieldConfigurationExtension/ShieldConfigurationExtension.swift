import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    private let quotes = [
        "Productivity is being able to do things that you were never able to do before.",
        "Discipline equals freedom.",
        "The obstacle in the path becomes the path.",
        "Suffer the pain of discipline, or suffer the pain of regret.",
        "You cannot escape the work. You can only delay it."
    ]
    
    private let authors = [
        "~Franz Kafka~",
        "~Jocko Willink~",
        "~Marcus Aurelius~",
        "~Jim Rohn~",
        "~Hardwayyy~"
    ]
    
    private let mascots = [
        "shield-1",
        "shield-2",
        "shield-3",
        "shield-4",
        "shield-5"
    ]
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield as needed for applications.
        configuration()
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        configuration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        configuration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        configuration()
    }
    
    private func configuration() -> ShieldConfiguration {
        let index = Int.random(in: 0..<quotes.count)
        let quote = quotes[index]
        let author = authors[index]
        
        let mascotName = mascots.randomElement() ?? "shield-1"
        let image = UIImage(named: mascotName) ?? UIImage(systemName: "brain.head.profile")
        
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            backgroundColor: UIColor.systemBackground.withAlphaComponent(0.3),
            icon: image,
            title: ShieldConfiguration.Label(text: quote, color: .label),
            subtitle: ShieldConfiguration.Label(text: author, color: .secondaryLabel),
            
            primaryButtonLabel: ShieldConfiguration.Label(text: "Earn Access", color: .white),
            primaryButtonBackgroundColor: UIColor.systemBlue,
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Cancel", color: .systemRed)
        )
    }}
