import SwiftUI
#if canImport(SafariServices)
import SafariServices
#endif

@available(iOS 15, tvOS 15, macOS 12, watchOS 8, *)
@MainActor
public extension OpenURLAction.Result {
    static func safari(_ url: URL) -> Self {
#if os(macOS)
        NSWorkspace.shared.open(url)
#elseif os(iOS)
        let scene = UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
        let window = scene?.windows.first { $0.isKeyWindow }

        guard let root = window?.rootViewController else {
            UIApplication.shared.open(url)
            return .handled
        }

        let controller = SFSafariViewController(url: url)
        if window?.traitCollection.horizontalSizeClass == .regular {
            controller.modalPresentationStyle = .pageSheet
        }
        root.present(controller, animated: true)
#elseif os(tvOS) || os(visionOS)
        UIApplication.shared.open(url)
#else
        WKExtension.shared().openSystemURL(url)
#endif
        return .handled
    }

    #if os(iOS)
    static func safari(_ url: URL, configure: (inout SafariConfiguration) -> Void) -> Self {
        let scene = UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
        let window = scene?.windows.first { $0.isKeyWindow }

        guard let root = window?.rootViewController else {
            UIApplication.shared.open(url)
            return .handled
        }

        var config = SafariConfiguration()
        configure(&config)

        let configuration = SFSafariViewController.Configuration()
        configuration.barCollapsingEnabled = config.barCollapsingEnabled
        configuration.entersReaderIfAvailable = config.prefersReader

        let controller = SFSafariViewController(url: url, configuration: configuration)
        controller.preferredControlTintColor = UIColor(config.tintColor)
        controller.dismissButtonStyle = config.dismissStyle.buttonStyle

        switch config.presentationStyle {
        case .automatic:
            if window?.traitCollection.horizontalSizeClass == .regular {
                controller.modalPresentationStyle = .pageSheet
            }
        case .fullScreenCover:
            controller.modalPresentationStyle = .fullScreen
        case .sheet:
            controller.modalPresentationStyle = .pageSheet
        }

        root.present(controller, animated: true)
        return .handled
    }

    struct SafariConfiguration {
        public enum DismissStyle {
            case done
            case close
            case cancel

            internal var buttonStyle: SFSafariViewController.DismissButtonStyle {
                switch self {
                case .cancel: return .cancel
                case .close: return .close
                case .done: return.done
                }
            }
        }

        public enum PresentationStyle {
            case automatic
            case sheet
            case fullScreenCover
        }

        public var prefersReader: Bool = false
        public var barCollapsingEnabled: Bool = true
        public var dismissStyle: DismissStyle = .done
        public var tintColor: Color = .accentColor
        public var presentationStyle: PresentationStyle = .automatic
    }
#endif
}
