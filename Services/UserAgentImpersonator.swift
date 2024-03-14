import Foundation


class UserAgentImpersonator {
    private static let impersonations = [
        ImpersonatorModel(
            hostname: "addons.mozilla.org",
            userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:122.0) Gecko/20100101 Firefox/122.0"
        )
    ]
    
    
    static func userAgentForHostname(_ hostname: String?) -> ImpersonatorModel? {
        return impersonations.first(where: { $0.hostname == hostname})
    }
}
