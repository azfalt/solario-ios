//
//  SolarioWidget.swift
//  SolarioWidget
//
//  Created by Aleksandr Pavlov on 10.12.21.
//  Copyright © 2021 Hermann Wagenleitner. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {

    private let defaultModelsFactory = BarChartModelsFactory()

    private var timlineDataInteractor: DataInteractorProtocol {
        let reportFactory = WidgetReportFactory()
        let userDefaults = UserDefaults(suiteName: "com.azfalt.solario.widget.defaults")!
        let rawStorage = RawDataStorage(userDefaults: userDefaults)
        let loader = DataLoader(rawStorage: rawStorage)
        let processor = DataProcessor()
        return DataInteractor(reportFactory: reportFactory,
                              loader: loader,
                              processor: processor,
                              rawStorage: rawStorage)
    }

    func placeholder(in context: Context) -> SimpleEntry {
        let interactor = PlaceholderDummyInteractor()
        return dummyEntry(for: context, interactor: interactor)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let interactor = SnapshotDummyInteractor()
        let entry = dummyEntry(for: context, interactor: interactor)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let date = Date()
        let limit = itemsLimit(for: context.displaySize)
        models(for: date, interactor: timlineDataInteractor, modelsFactory: defaultModelsFactory, limit: limit) { models in
            let entry = SimpleEntry(date: date, items: models)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }

    private func models(for reportDate: Date,
                        interactor: DataInteractorProtocol,
                        modelsFactory: BarChartModelsFactoryProtocol,
                        limit: Int,
                        completion: @escaping ([BarChartItemModel]) -> Void) {

        interactor.loadData { success in

            var models: [BarChartItemModel] = []

            if success {

                var date = Constants.calendar.begin(for: reportDate)
                let minItemsForSeparator = 5
                let oneDay: TimeInterval = 3600 * 24
                var itemsCount = 0
                var allowSeparator = false

                repeat {

                    let dayItems = interactor.items(forDate: date)
                    guard dayItems.count > 0 else {
                        break
                    }

                    var actualDayItems: [DataItem] = []
                    for item in dayItems {
                        if item.dateInterval.start >= reportDate || (item.dateInterval.start < reportDate && item.dateInterval.end > reportDate) {
                            actualDayItems.append(item)
                            itemsCount += 1
                        }
                        if itemsCount >= limit {
                            break
                        }
                    }

                    let dayModels = modelsFactory.models(with: actualDayItems, allowSeparator: allowSeparator)
                    models.append(contentsOf: dayModels)

                    allowSeparator = limit >= minItemsForSeparator
                    date.addTimeInterval(oneDay)

                } while models.count < limit
            }

            completion(models)
        }
    }

    private func dummyEntry(for context: Context, interactor: DataInteractorProtocol) -> SimpleEntry {
        let now = Date()
        let reportDate = Constants.calendar.begin(for: now)
        let limit = itemsLimit(for: context.displaySize)
        let items = Array(interactor.items(forDate: reportDate).prefix(limit))
        let models = defaultModelsFactory.models(with: items, allowSeparator: false)
        return SimpleEntry(date: now, items: models)
    }

    private func itemsLimit(for widgetSize: CGSize) -> Int {
        let singleItemWidth = 40.0
        return Int(widgetSize.width / singleItemWidth)
    }
}


struct SimpleEntry: TimelineEntry {

    let date: Date

    let items: [BarChartItemModel]
}


struct WidgetPadding: ViewModifier {

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content.padding(0)
        } else {
            content.padding()
        }
    }
}


struct WidgetEntryView : View {

    var entry: Provider.Entry

    func widgetBackground() -> some View {
        if #available(iOS 17.0, *) {
            return AnyView(self.containerBackground(Color(.systemBackground), for: .widget))
        } else {
            return AnyView(self.background(Color(.systemBackground)))
        }
    }

    var body: some View {
        BarChartView(items: entry.items)
            .modifier(WidgetPadding())
    }
}


@main
struct SolarioWidget: Widget {

    let kind: String = "com.azfalt.solario.widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
                .widgetBackground()
        }
        .configurationDisplayName("_forecast".localized)
        .description("Kp-index")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
