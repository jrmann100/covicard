import Foundation
import JOSESwift
import class ModelsR4.Bundle

class HealthCard: Codable, Identifiable {
    let iss: String
    let nbf: Int
    let vc: Vc
    var id: Int { nbf }

    struct HealthCardS: Codable, Identifiable {
        let iss: String
        let nbf: Int
        let vc: Vc
        var id: Int { nbf }
    }

    struct Vc: Codable {
        let type: [String]
        let credentialSubject: CredentialSubject
    }

    struct CredentialSubject: Codable {
        let fhirVersion: String
        let fhirBundle: ModelsR4.Bundle
    }

    init(_ shc: String) {
        let shcBytesRegEx = try! NSRegularExpression(pattern: "(..?)")
        let shcBytesRegExMatches = shcBytesRegEx.matches(in: shc, range: NSRange(location: 5, length: shc.utf16.count - 5))
        let shcBytesAsStrings = shcBytesRegExMatches.map { shc[Range($0.range(at: 0), in: shc)!] }

        let shcBytesAsChars = shcBytesAsStrings.map {
            Character(UnicodeScalar(Int($0)! + 45)!)
        }

        let shcAsBase64 = String(shcBytesAsChars)

        //    let header = JWSHeader.init(algorithm: .ES256)
        let jws = try! JWS(compactSerialization: shcAsBase64)
        // jws.isValid(for: Verifier.init(verifyingAlgorithm: , key: <#T##KeyType#>))
        let payloadCompressed = jws.payload.data()
        let payloadData: Data = try! (payloadCompressed as NSData).decompressed(using: .zlib) as Data
        let healthCard = try! JSONDecoder().decode(HealthCardS.self, from: payloadData)
        self.iss = healthCard.iss
        self.nbf = healthCard.nbf
        self.vc = healthCard.vc
    }
}
