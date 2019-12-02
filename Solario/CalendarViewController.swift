//
//  CalendarViewController.swift
//  Solario
//
//  Created by Hermann W. on 01.11.19.
//  Copyright © 2019 Hermann Wagenleitner. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {

    private enum CalendarMode {

        case week

        case month
    }

    var reportsInteractor: ReportsInteractor!

    private lazy var calendarView: FSCalendar = FSCalendar()

    private var calendarViewHeightConstraint: NSLayoutConstraint!

    private var scopeGesture: UIPanGestureRecognizer!

    private var calendarMode: CalendarMode = .month

    private var selectedDate: Date?

    private lazy var selectedDayLabel: UILabel = UILabel()

    private lazy var tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)

    private let cellId = "dayCell"

    private let headerId = "monthHeaderView"

    private var selectedDayFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .none
        return df
    }

    // MARK: - Life Cycle

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

    // MARK: -

    private func selectCurrentDate() {
        let now = Date()
        calendarView.select(now, scrollToDate: true)
        showDetails(for: calendarView.selectedDate)
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
        configureScopeGesture()
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
        let height: CGFloat = view.bounds.size.width
        calendarViewHeightConstraint = calendarView.heightAnchor.constraint(equalToConstant: height)
        calendarViewHeightConstraint.isActive = true
        calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        calendarView.scope = calendarMode == .month ? .month : .week
        var calendar = Calendar.current
        calendar.locale = Locale.autoupdatingCurrent
        calendarView.firstWeekday = UInt(calendar.firstWeekday)
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.allowsMultipleSelection = false
        calendarView.register(CalendarDayCell.self, forCellReuseIdentifier: "cell")
        calendarView.appearance.headerTitleColor = UIColor.label
        calendarView.appearance.weekdayTextColor = UIColor.label
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

    private func configureScopeGesture() {
        let gesture = UIPanGestureRecognizer(target: calendarView, action: #selector(calendarView.handleScopeGesture(_:)))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 2
        gesture.delegate = self
        scopeGesture = gesture
        self.view.addGestureRecognizer(scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: scopeGesture)
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

    private func showDetails(for date: Date?) {
        selectedDate = date
        if let date = date {
            selectedDayLabel.text = selectedDayFormatter.string(from: date)
            tableView.reloadData()
        }
    }
}

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate {

    // MARK: - FSCalendarDataSource

    func minimumDate(for calendar: FSCalendar) -> Date {
        return reportsInteractor.defaultEarliestReportDate
    }

    func maximumDate(for calendar: FSCalendar) -> Date {
        return reportsInteractor.defaultLatestReportDate
    }

    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        return cell
    }

    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: position)
    }

    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let dayCell = (cell as! CalendarDayCell)
        dayCell.configure(position: position, value: reportsInteractor.maxValue(forDate: date))
    }

    // MARK: - FSCalendarDelegate

    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarViewHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        showDetails(for: date)
        calendarView.select(date, scrollToDate: true)
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    }
}

extension CalendarViewController: UITableViewDataSource {

    // MARK: - UITableViewDataSource

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
        if let date = selectedDate {
            let i = reportsInteractor.mergedItems(forDate: date)
            return i
        }
        return nil
    }
}

extension CalendarViewController: UIGestureRecognizerDelegate {

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = tableView.contentOffset.y <= -tableView.contentInset.top
        if shouldBegin {
            let velocity = scopeGesture.velocity(in: view)
            switch calendarView.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            default:
                return false
            }
        }
        return shouldBegin
    }
}
