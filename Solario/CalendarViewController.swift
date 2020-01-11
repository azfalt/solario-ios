//
//  CalendarViewController.swift
//  Solario
//
//  Created by Hermann W. on 01.11.19.
//  Copyright © 2019 Hermann Wagenleitner. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {

    var reportsInteractor: ReportsInteractor!

    private var calendarContainerView: UIView!

    private var viewSize: CGSize = CGSize(width: 0, height: 0)

    private var calendarView: FSCalendar!

    private var calendarViewHeightConstraint: NSLayoutConstraint!

    private var scopeGesture: UIPanGestureRecognizer!

    private var lastUsedPortraitCalendarScope: FSCalendarScope = .month

    private var calendarScope: FSCalendarScope {
        return isMonthScopeAllowed ? lastUsedPortraitCalendarScope : .week
    }

    private var selectedDate: Date?

    private lazy var selectedDayLabel: UILabel = UILabel()

    private lazy var tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)

    private var calendarCellId: String = "cell"

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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateViewSize(newValue: size) {
            self.redrawCalendarView()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }

    // MARK: -

    private func redrawCalendarView() {
        let page = calendarView.currentPage
        configureCalendarView()
        if let date = selectedDate {
            calendarView.select(date, scrollToDate: false)
        }
        configureScopeGesture()
        updateCalendarScopeState()
        calendarView.setCurrentPage(page, animated: false)
    }

    private func updateViewSize(newValue: CGSize? = nil, successCompletion: (() -> Void)? = nil) {
        guard viewSize != newValue else {
            return
        }
        if let size = newValue {
            viewSize = size
            successCompletion?()
        } else {
            viewSize = view.bounds.size
        }
    }

    private func selectCurrentDate() {
        let now = Date()
        calendarView.select(now, scrollToDate: true)
        showDetails(for: calendarView.selectedDate)
    }

    private func configure() {
        configureTitle()
        configureAppearance()
        updateViewSize()
        configureCalendarView()
        configureSelectedDayLabel()
        configureTableView()
        configureReportsButton()
        updateRefreshButtonState()
        subscribeToReportsNotifications()
        configureScopeGesture()
        updateCalendarScopeState()
    }

    @objc private func showReports() {
        let vc = ReportListViewController()
        vc.reportsInteractor = reportsInteractor
        navigationController?.pushViewController(vc, animated: true)
    }

    private var calendarViewHeight: CGFloat {
        let viewWidth = min(viewSize.width, viewSize.height)
        let viewHeight = max(viewSize.width, viewSize.height)
        let ratio: CGFloat = 0.55
        let maxHeight = ceil(viewHeight * ratio)
        return min(maxHeight, viewWidth)
    }

    private func configureTitle() {
        title = "Solario"
    }

    private func configureAppearance() {
        view.backgroundColor = UIColor.systemBackground
    }

    private func configureCalendarContainerViewIfNeed() {
        guard calendarContainerView == nil else {
            return
        }
        calendarContainerView = UIView()
        view.addSubview(calendarContainerView)
        calendarContainerView.translatesAutoresizingMaskIntoConstraints = false
        calendarContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        calendarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        calendarContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    private func configureCalendarView() {
        configureCalendarContainerViewIfNeed()
        if calendarView != nil {
            calendarView.removeFromSuperview()
        }
        calendarView = FSCalendar()
        calendarContainerView.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor).isActive = true
        calendarView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor).isActive = true
        calendarViewHeightConstraint = calendarView.heightAnchor.constraint(equalToConstant: calendarViewHeight)
        calendarViewHeightConstraint.isActive = true
        calendarView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor).isActive = true
        calendarView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor).isActive = true
        calendarView.scope = calendarScope
        var calendar = Calendar.current
        calendar.locale = Locale.autoupdatingCurrent
        calendarView.firstWeekday = UInt(calendar.firstWeekday)
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.allowsMultipleSelection = false
        calendarView.register(CalendarDayCell.self, forCellReuseIdentifier: calendarCellId)
        calendarView.appearance.headerTitleColor = UIColor.label
        calendarView.appearance.weekdayTextColor = UIColor.label
    }

    private var isMonthScopeAllowed: Bool {
        let ratio = viewSize.height / viewSize.width;
        let minRatio: CGFloat = 0.69
        return ratio >= minRatio
    }

    private func updateCalendarScopeState() {
        scopeGesture.isEnabled = isMonthScopeAllowed
        let scope = calendarScope
        if scope != calendarView.scope {
            calendarView.setScope(scope, animated: true)
        }
    }

    private func configureSelectedDayLabel() {
        view.addSubview(selectedDayLabel)
        selectedDayLabel.translatesAutoresizingMaskIntoConstraints = false
        selectedDayLabel.topAnchor.constraint(equalTo: calendarContainerView.bottomAnchor, constant: 7).isActive = true
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
                indicator.color = UIColor.label
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: indicator)
                indicator.startAnimating()
            } else {
                let image = UIImage(systemName: "arrow.clockwise")
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.reloadData))
            }
        }
    }

    private func subscribeToReportsNotifications() {
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
        return calendar.dequeueReusableCell(withIdentifier: calendarCellId, for: date, at: position)
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
        if isMonthScopeAllowed {
            lastUsedPortraitCalendarScope = calendarView.scope
        }
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
