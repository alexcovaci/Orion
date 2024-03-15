import Foundation


struct ExtensionManifestModel: Codable {
    let author: String?
    let browserAction: BrowserActionModel?
    let defaultLocale: String?
    let description: String?
    let homepageUrl: String?
    let icons: IconsModel?
    let manifestVersion: Int?
    let name: String?
    let version: String?
    
    enum CodingKeys: String, CodingKey {
        case author,
             browserAction = "browser_action",
             defaultLocale = "default_locale",
             description,
             homepageUrl = "homepage_url",
             icons,
             manifestVersion = "manifest_version",
             name,
             version
    }
    
    var id: String {
        "\(author ?? "")\(name ?? "")"
    }
}

struct BrowserActionModel: Codable {
    let browserStyle: Bool?
    let defaultIcon: IconsModel?
    let defaultPopup: String?
    let defaultTitle: String?
    
    enum CodingKeys: String, CodingKey {
        case browserStyle = "browser_style",
             defaultIcon = "default_icon",
             defaultPopup = "default_popup",
             defaultTitle = "default_title"
    }
}

struct IconsModel: Codable {
    let sixteen: String?
    let twentyFour: String?
    let thirtyTwo: String?
    let fortyEight: String?
    
    enum CodingKeys: String, CodingKey {
        case sixteen = "16",
             twentyFour = "24",
             thirtyTwo = "32",
             fortyEight = "48"
    }
    
    var largestImage: String? {
        if let fortyEight = fortyEight, !fortyEight.isEmpty {
            return fortyEight
        } else if let thirtyTwo = thirtyTwo, !thirtyTwo.isEmpty {
            return thirtyTwo
        } else if let twentyFour = twentyFour, !twentyFour.isEmpty {
            return twentyFour
        } else if let sixteen = sixteen, !sixteen.isEmpty {
            return sixteen
        }
        
        return nil
    }
}
