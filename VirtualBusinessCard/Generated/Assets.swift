// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Colors {
    internal static let appAccent = ColorAsset(name: "AppAccent")
    internal static let appBackground = ColorAsset(name: "AppBackground")
    internal static let appBackgroundSecondary = ColorAsset(name: "AppBackgroundSecondary")
    internal static let appGray = ColorAsset(name: "AppGray")
    internal static let appShadow = ColorAsset(name: "AppShadow")
    internal static let appTabBar = ColorAsset(name: "AppTabBar")
    internal static let appWhite = ColorAsset(name: "AppWhite")
    internal static let barSeparator = ColorAsset(name: "BarSeparator")
    internal static let defaultText = ColorAsset(name: "DefaultText")
    internal static let googleBlue = ColorAsset(name: "GoogleBlue")
    internal static let microsoftBlue = ColorAsset(name: "MicrosoftBlue")
    internal static let roundedTableViewCellBackground = ColorAsset(name: "RoundedTableViewCellBackground")
    internal static let scrollableSegmentedControlSelectionBackground = ColorAsset(name: "ScrollableSegmentedControlSelectionBackground")
    internal static let scrollableSegmentedControlSelectionText = ColorAsset(name: "ScrollableSegmentedControlSelectionText")
    internal static let secondaryText = ColorAsset(name: "SecondaryText")
    internal static let selectedCellBackgroundLight = ColorAsset(name: "SelectedCellBackgroundLight")
    internal static let selectedCellBackgroundStrong = ColorAsset(name: "SelectedCellBackgroundStrong")
  }
  internal enum Images {
    internal static let appLogo = ImageAsset(name: "AppLogo")
    internal enum BundledTexture {
      internal static let texture1 = ImageAsset(name: "BundledTexture/Texture1")
      internal static let texture2 = ImageAsset(name: "BundledTexture/Texture2")
      internal static let texture3 = ImageAsset(name: "BundledTexture/Texture3")
      internal static let texture4 = ImageAsset(name: "BundledTexture/Texture4")
    }
    internal static let businessCard = ImageAsset(name: "BusinessCard")
    internal static let exampleBC = ImageAsset(name: "ExampleBC")
    internal static let exampleBCBack = ImageAsset(name: "ExampleBCBack")
    internal enum Icon {
      internal static let collection = ImageAsset(name: "Icon/Collection")
      internal static let personalCards = ImageAsset(name: "Icon/PersonalCards")
      internal static let settings = ImageAsset(name: "Icon/Settings")
    }
    internal static let appleLogo = ImageAsset(name: "AppleLogo")
    internal static let googleLogo = ImageAsset(name: "GoogleLogo")
    internal static let microsoftLogo = ImageAsset(name: "MicrosoftLogo")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    Bundle(for: BundleToken.self)
  }()
}
// swiftlint:enable convenience_type
