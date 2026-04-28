import WidgetKit
import SwiftUI

// Struct to define the data passed to the widget
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FuelEntry {
        FuelEntry(date: Date(), benzin: "40.50", motorin: "41.20", lpg: "21.60", ilAdi: "İstanbul", benzinYon: 0, motorinYon: 0, lpgYon: 0, guncelleme: "Son: 12:00")
    }

    func getSnapshot(in context: Context, completion: @escaping (FuelEntry) -> ()) {
        let entry = FuelEntry(date: Date(), benzin: "40.50", motorin: "41.20", lpg: "21.60", ilAdi: "Türkiye", benzinYon: 0, motorinYon: 0, lpgYon: 0, guncelleme: "Son: 12:00")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // App group identifier matching your Xcode capabilities setup
        let userDefaults = UserDefaults(suiteName: "group.com.iscgames.fueltr.widget") // CHANGEME

        let benzin = userDefaults?.string(forKey: "benzin_fiyat") ?? "---"
        let motorin = userDefaults?.string(forKey: "motorin_fiyat") ?? "---"
        let lpg = userDefaults?.string(forKey: "lpg_fiyat") ?? "---"
        let ilAdi = userDefaults?.string(forKey: "il_adi") ?? "Türkiye"
        let guncelleme = userDefaults?.string(forKey: "guncelleme") ?? "--:--"
        let benzinYon = userDefaults?.integer(forKey: "benzin_yon") ?? 0
        let motorinYon = userDefaults?.integer(forKey: "motorin_yon") ?? 0
        let lpgYon = userDefaults?.integer(forKey: "lpg_yon") ?? 0

        let entry = FuelEntry(date: Date(), benzin: benzin, motorin: motorin, lpg: lpg, ilAdi: ilAdi, benzinYon: benzinYon, motorinYon: motorinYon, lpgYon: lpgYon, guncelleme: guncelleme)

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct FuelEntry: TimelineEntry {
    let date: Date
    let benzin: String
    let motorin: String
    let lpg: String
    let ilAdi: String
    let benzinYon: Int
    let motorinYon: Int
    let lpgYon: Int
    let guncelleme: String
}

struct FuelWidgetEntryView : View {
    var entry: Provider.Entry
    
    // Environment checking for Dark Mode
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Text(entry.ilAdi)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer()
                Text(entry.guncelleme)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Benzin Row
            FuelRow(
                dotColor: Color.orange,
                title: "Benzin",
                price: entry.benzin,
                trend: entry.benzinYon
            )
            
            // Motorin Row
            FuelRow(
                dotColor: Color.blue,
                title: "Motorin",
                price: entry.motorin,
                trend: entry.motorinYon
            )
            
            // LPG Row
            FuelRow(
                dotColor: Color.purple,
                title: "LPG",
                price: entry.lpg,
                trend: entry.lpgYon
            )
        }
        .padding()
    }
}

// Subview for each fuel row
struct FuelRow: View {
    let dotColor: Color
    let title: String
    let price: String
    let trend: Int
    
    var body: some View {
        HStack {
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text("\(price) ₺")
                .font(.system(size: 16, weight: .bold))
            
            TrendIcon(trend: trend)
        }
    }
}

// Subview for up/down arrows
struct TrendIcon: View {
    let trend: Int
    
    var body: some View {
        if trend == 1 {
            Image(systemName: "arrow.up")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.red)
        } else if trend == -1 {
            Image(systemName: "arrow.down")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.green)
        } else {
            Image(systemName: "minus")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
        }
    }
}

@main
struct FuelWidget: Widget {
    let kind: String = "FuelWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FuelWidgetEntryView(entry: entry)
                // Ensures proper background style for iOS 17 container backgrounds
                .containerBackground(for: .widget) {
                    Color(UIColor.systemBackground)
                }
        }
        .configurationDisplayName("Yakıt Fiyatları")
        .description("Güncel akaryakıt fiyatlarını takip edin.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}