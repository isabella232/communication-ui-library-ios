// ----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// ----------------------------------------------------------------
import Foundation
import UIKit
import AzureCommunicationUI
import AzureCommunicationCommon

struct TeamsBrandConfig: ThemeConfiguration {
    func primaryColor() -> UIColor? {
        return UIColor(named: "TeamsColor")
    }
}

struct Theming: ThemeConfiguration {
//    var primaryColor: UIColor {
//        return UIColor.red
//    }
}

struct LocalConfig: LocalConfiguration {
    func localPersona(_ composite: ICallComposite) {
        let urlRequest = URL(string:
"https://img.favpng.com/0/15/12/computer-icons-avatar-male-user-profile-png-favpng-ycgruUsQBHhtGyGKfw7fWCtgN.jpg")!
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                let avatar = UIImage(data: data)
                let persona = PersonaData(displayName: "", avatar: avatar)
                composite.setLocalParticipantPersona(for: persona)
            }
        }.resume()
    }
}

class AvatarConfig: ParticipantConfiguration {
    func avatar(_ identifier: CommunicationIdentifier, onImageCompleted: @escaping FetchImageAction) {
/*        switch identifier {
        case is CommunicationUserIdentifier:
            // request an avatar for communication user
        case is UnknownIdentifier:
            // request an avatar for unknown user
        case is PhoneNumberIdentifier:
            // request an avatar for phone number user
        case is MicrosoftTeamsUserIdentifier:
            // request an avatar for teams user
        default:
            // return a fallback avatar
        }
*/
        let urlRequest = URL(string:
"https://yt3.ggpht.com/ytc/AKedOLQf5MBcFSDzo2FeZIXSqafCvdRMGjW2C-0j8RpD=s900-c-k-c0x00ffffff-no-rj")!
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                onImageCompleted(UIImage(data: data))
            }
        }.resume()
    }
}
