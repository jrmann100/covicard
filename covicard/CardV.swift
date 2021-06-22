import ModelsR4
import SwiftUI

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter
}()

private struct VaxV: View {
    let vax: Immunization
    var dateString: String {
        switch vax.occurrence {
        case .dateTime(let dateTime):
            return dateFormatter.string(from: try! dateTime.value!.asNSDate())
        case .string(let string):
            return string.value!.string
        }
    }
    
    var details: String {
        vax.performer!.first!.actor.display!.value!.string
    }
    
    var lot: String {
        vax.lotNumber!.value!.string
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(details).font(.system(size: 20, weight: .regular, design: .monospaced)).lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
            HStack {
                Spacer()
                Image(systemName: "bandage.fill").resizable().aspectRatio(contentMode: .fit).frame(height: 70).foregroundColor(Color("blue"))
                Spacer()
                VStack(alignment: .leading) {
                    KVItemV(key: "LOT", value: lot)
                    KVItemV(key: "DATE", value: dateString)
                }
                Spacer()
            }
        }
    }
}

private struct PatientV: View {
    let patient: Patient
    var first: String {
        patient.name!.first!.given!.map { $0.value!.string }.joined(separator: " ")
    }
    
    var last: String {
        patient.name!.first!.family!.value!.string
    }
    
    var dobString: String {
        dateFormatter.string(from: try! patient.birthDate!.value!.asNSDate())
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach([["LN", last], ["FN", first], ["DOB", dobString]], id: \.self) { item in
                KVItemV(key: item[0], value: item[1])
            }
        }
    }
}

struct CardV: View {
    let healthCard: HealthCard
    
    var issued: Date {
        Date(timeIntervalSince1970: TimeInterval(healthCard.nbf))
    }
    
    var patient: Patient {
        healthCard.vc.credentialSubject.fhirBundle.entry!.first(where: { $0.resource!.resourceType == "Patient" })!.resource!.get(if: Patient.self)!
    }
    
    var vaxes: [Immunization] {
        healthCard.vc.credentialSubject.fhirBundle.entry!.filter { $0.resource!.resourceType == "Immunization" && $0.resource!.get(if: Immunization.self)!.status == .completed }.map { $0.resource!.get(if: Immunization.self)! }
    }
    
    var issuer: String {
        healthCard.iss == "https://myvaccinerecord.cdph.ca.gov/creds" ? "California" : healthCard.iss
    }
    
    var body: some View {
        CardDataV(vaxes: vaxes, patient: patient, issuer: issuer, issued: issued)
    }
}

struct GenericView: UIViewRepresentable {
    typealias UIViewType = UIView
    func makeUIView(context: UIViewRepresentableContext<GenericView>) -> UIView {
        let view = UIView()
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<GenericView>) {}
}

private struct KVItemV: View {
    let key: String
    let value: String
    var body: some View {
        HStack {
            Text(key).foregroundColor(Color("blue")).font(.system(size: 20, weight: .semibold))
            Text(value).font(.system(size: 23, weight: .semibold))
        }
    }
}

private struct CardDataV: View {
    let vaxes: [Immunization]
    let patient: Patient
    let issuer: String
    let issued: Date
    
    var body: some View {
        GeometryReader { metrics in
            VStack(alignment: .leading, spacing: 10) {
                Text(issuer).font(.system(size: 45, weight: .bold, design: .default)).foregroundColor(Color("blue"))
                HStack {
                    Spacer()
                    GenericView().frame(width: metrics.size.width * 0.8, height: 5).background(Color("green")).cornerRadius(5)
                }
                HStack {
                    Spacer()
                    GenericView().frame(width: metrics.size.width * 0.7, height: 5).background(Color("green")).cornerRadius(5)
                }
                Text("VACCINATION CARD").font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(Color("green"))
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "person.crop.circle").resizable().foregroundColor(Color("green")).aspectRatio(contentMode: .fit).frame(height: 100)
                    Spacer()
                    PatientV(patient: patient)
                    Spacer()
                }
                Spacer()
                VStack(alignment: .leading) {
                    ForEach(vaxes, id: \.self.lotNumber!.value!.string) { vax in
                        VaxV(vax: vax)
                        Spacer()
                    }
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("ISS").foregroundColor(Color("blue")).font(.system(size: 17, weight: .semibold))
                    Text(dateFormatter.string(from: issued)).font(.system(size: 18, weight: .semibold))
                }
            }.padding()
        }
    }
}

struct CardV_Previews: PreviewProvider {
    static let healthCard = HealthCard("shc:/YOUR-SHC-HERE")
    static var previews: some View {
        CardV(healthCard: healthCard)
    }
}
