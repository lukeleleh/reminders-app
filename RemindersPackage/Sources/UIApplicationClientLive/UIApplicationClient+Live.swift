import Combine
import UIKit
import UIApplicationClient

extension UIApplicationClient {
    public static let live = Self(
        open: { url in
            .future { callback in
                UIApplication.shared.open(url, options: [:]) { bool in
                    callback(.success(bool))
                }
            }
        },
        openSettingsURLString: { UIApplication.openSettingsURLString }
    )
}
