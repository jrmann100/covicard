import ModelsR4
import SwiftUI
import UIKit

@main
struct covicardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentV()
        }
    }
}

struct ContentV: View {
    @State var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    @State var barcode: String?
    @State var showScanner = true

    var healthCard: Binding<HealthCard?> { Binding(
        get: { self.barcode == nil ? nil : HealthCard(barcode!) },
        set: { if $0 == nil { self.barcode = nil } }
    )
    }

    var body: some View {
        ZStack {
            if barcode == nil {
                ScannerV(barcode: $barcode).edgesIgnoringSafeArea(.all)
            }
            Image(systemName: "barcode.viewfinder")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.2)
                .frame(width: 100, height: 100)
        }.sheet(item: healthCard) {
            CardV(healthCard: $0)
        }.animation(.easeInOut(duration: 0.5))
    }
}
