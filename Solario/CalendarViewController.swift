//
//  CalendarViewController.swift
//  Solario
//
//  Created by Hermann W. on 01.11.19.
//  Copyright © 2019 Hermann Wagenleitner. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {

    private enum CalendarMode {

        case week

        case month
    }

    var reportsInteractor: ReportsInteractor!

    private lazy var calendarView: JTACMonthView = JTACMonthView()

    private var calendarMode: CalendarMode = .month

    private lazy var selectedDayLabel: UILabel = UILabel()

    private lazy var tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)

    private let cellId = "dayCell"

    private let headerId = "monthHeaderView"

    private var monthFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMMM YYYY"
        return df
    }

    private var selectedDayFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .none
        return df
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        selectCurrentDate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        calendarView.viewWillTransition(to: size, with: coordinator, anchorDate: nil)
    }

    private func selectCurrentDate() {
        let now = Date()
        calendarView.selectDates([now])
        calendarView.scrollToDate(now, animateScroll: false)
    }

    private func configure() {
        title = "Solario"
        view.backgroundColor = UIColor.systemBackground
        configureCalendarView()
        configureSelectedDayLabel()
        configureTableView()
        configureReportsButton()
        updateRefreshButtonState()
        subsribeToReportsNotifications()
    }

    @objc private func showReports() {
        let vc = ReportListViewController()
        vc.reportsInteractor = reportsInteractor
        navigationController?.pushViewController(vc, animated: true)
    }

    private func configureCalendarView() {
        view.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        let heightMultiplier: CGFloat = calendarMode == .month ? 1 : 0.4
        calendarView.heightAnchor.constraint(equalTo: calendarView.widthAnchor, multiplier: heightMultiplier).isActive = true
        calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        calendarView.allowsMultipleSelection = false
        calendarView.showsHorizontalScrollIndicator = false
        calendarView.showsVerticalScrollIndicator = false
        calendarView.sectionInset.bottom = 10
        calendarView.sectionInset.top = 10
        calendarView.sectionInset.left = 10
        calendarView.sectionInset.right = 10
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        calendarView.backgroundColor = UIColor.systemBackground
        calendarView.register(DayCell.self, forCellWithReuseIdentifier: cellId)
        calendarView.register(MonthHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
    }

    private func configureSelectedDayLabel() {
        view.addSubview(selectedDayLabel)
        selectedDayLabel.translatesAutoresizingMaskIntoConstraints = false
        selectedDayLabel.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 7).isActive = true
        selectedDayLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        selectedDayLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        selectedDayLabel.textAlignment = .center
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: selectedDayLabel.bottomAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.dataSource = self
        tableView.register(ReportItemTableViewCell.self, forCellReuseIdentifier: String(describing: ReportItemTableViewCell.self))
    }

    private func configureReportsButton() {
        let image = UIImage(systemName: "list.dash")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showReports))
    }

    @objc private func updateRefreshButtonState() {
        DispatchQueue.main.async {
            if self.reportsInteractor.isAnyReportLoading {
                let indicator = UIActivityIndicatorView(style: .medium)
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: indicator)
                indicator.startAnimating()
            } else {
                let image = UIImage(systemName: "arrow.clockwise")
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.reloadData))
            }
        }
    }

    private func subsribeToReportsNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshData),
                                               name: ReportsInteractor.Notifications.AllReportsDidFinishLoading,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateRefreshButtonState),
                                               name: ReportsInteractor.Notifications.ReportWillStartLoading,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateRefreshButtonState),
                                               name: ReportsInteractor.Notifications.AllReportsDidFinishLoading,
                                               object: nil)
    }

    @objc private func reloadData() {
        reportsInteractor.loadReports()
    }

    @objc private func refreshData() {
        DispatchQueue.main.async {
            self.calendarView.reloadData()
            self.tableView.reloadData()
        }
    }
}

extension CalendarViewController: JTACMonthViewDataSource, JTACMonthViewDelegate {

    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configure(cell: cell, state: cellState, date: date)
    }

    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: cellId, for: indexPath) as! DayCell
        configure(cell: cell, state: cellState, date: date)
        return cell
    }

    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        if calendarMode == .month {
            return ConfigurationParameters(startDate: reportsInteractor.defaultEarliestReportDate,
                                           endDate: reportsInteractor.defaultLatestReportDate,
                                           numberOfRows: 6,
                                           generateInDates: .forAllMonths,
                                           generateOutDates: .tillEndOfGrid,
                                           hasStrictBoundaries: true)
        } else {
            return ConfigurationParameters(startDate: reportsInteractor.defaultEarliestReportDate,
                                           endDate: reportsInteractor.defaultLatestReportDate,
                                           numberOfRows: 1,
                                           generateInDates: .forAllMonths,
                                           generateOutDates: .tillEndOfRow,
                                           hasStrictBoundaries: false)
        }
    }

    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        configure(cell: cell, state: cellState, date: date)
        if (calendarMode == .month && cellState.dateBelongsTo != .thisMonth) {
            calendarView.scrollToDate(date)
        }
        selectedDayLabel.text = selectedDayFormatter.string(from: date)
        tableView.reloadData()
    }

    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        configure(cell: cell, state: cellState, date: date)
    }

    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: headerId, for: indexPath) as! MonthHeaderView
        header.monthLabel.text = monthFormatter.string(from: range.start)
        return header
    }

    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 70)
    }

    private func configure(cell: JTACDayCell?, state: CellState, date: Date) {
        /// check the cell, because somtimes it fails unexpectedly
        if let dayCell = cell as? DayCell {
            dayCell.configure(state: state, value: reportsInteractor.maxValue(forDate: date))
        }
    }
}

extension CalendarViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = itemsForSelectedDay() {
            return items.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportItemTableViewCell.self), for: indexPath) as! ReportItemTableViewCell
        if let items = itemsForSelectedDay() {
            let item = items[indexPath.row]
            cell.configure(item: item)
        }
        return cell
    }

    private func itemsForSelectedDay() -> [DataItem]? {
        if let date = calendarView.selectedDates.last {
            return reportsInteractor.mergedItems(forDate: date)
        }
        return nil
    }
}
