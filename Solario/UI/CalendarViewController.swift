//
//  CalendarViewController.swift
//  Solario
//
//  Created by Hermann W. on 01.11.19.
//  Copyright © 2019 Hermann Wagenleitner. All rights reserved.
//

import UIKit
import SwiftUI

class CalendarViewController: UIViewController, DependencyProtocol {

    private var calendarContainerView: UIView!

    private var viewSize: CGSize = CGSize(width: 0, height: 0)

    private var calendarView: FSCalendar!

    private var calendarViewHeightConstraint: NSLayoutConstraint!

    private var scopeGesture: UIPanGestureRecognizer!

    private static let calendarScopeDefaultsKey = "calendarScope"

    private var lastUsedPortraitCalendarScope: FSCalendarScope {
        set(scope) {
            UserDefaults.standard.set(scope.rawValue, forKey: Self.calendarScopeDefaultsKey)
        }
        get {
            let value = UserDefaults.standard.integer(forKey: Self.calendarScopeDefaultsKey)
            return FSCalendarScope(rawValue: UInt(value)) ?? .month
        }
    }

    private var calendarScope: FSCalendarScope {
        return isMonthScopeAllowed ? lastUsedPortraitCalendarScope : .week
    }

    private var selectedDate: Date?

    private var lastUsedCalendarPage: Date?

    private lazy var selectedDayLabel: UILabel = UILabel()

    private lazy var emptyPlaceholderLabel: UILabel = UILabel()

    private lazy var tableView: UITableView = UITableView(frame: .zero, style: .plain)

    private static let calendarCellId: String = "cell"

    private var selectedDayFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .none
        return df
    }

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .secondaryLabel
        return indicator
    }()

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
        redrawCalendarView()
    }

    deinit {
        removeObservers()
    }

    // MARK: -

    private func redrawCalendarView() {
        DispatchQueue.main.async {
            let page = self.calendarView.currentPage
            self.configureCalendarView()
            if let date = self.selectedDate {
                self.calendarView.select(date, scrollToDate: false)
            }
            self.configureScopeGesture()
            self.updateCalendarScopeState()
            self.calendarView.setCurrentPage(page, animated: false)
        }
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
        let cal = Constants.calendar
        let minDate = cal.startOfDay(for: minimumDate(for: calendarView))
        let maxDate = cal.endOfDay(for: maximumDate(for: calendarView))
        guard now >= minDate && now <= maxDate else {
            return
        }
        let components = cal.dateComponents([.year, .month, .day], from: now)
        if let today = cal.date(from: components) {
            select(date: today)
        }
        lastUsedCalendarPage = calendarView.currentPage
    }

    private func configure() {
        configureTitle()
        configureAppearance()
        updateViewSize()
        configureNavigationBar()
        configureCalendarView()
        configureSelectedDayLabel()
        configureTableView()
        configureInfoButton()
        addObservers()
        configureScopeGesture()
        updateCalendarScopeState()
    }

    @objc private func showInfo() {
        let vc = InfoViewController()
        vc.modalPresentationStyle = .formSheet
        navigationController?.present(vc, animated: true)
    }

    private var calendarViewHeight: CGFloat {
        let viewWidth = min(viewSize.width, viewSize.height)
        let viewHeight = max(viewSize.width, viewSize.height)
        let ratio: CGFloat = 0.55
        let maxHeight = ceil(viewHeight * ratio)
        return min(maxHeight, viewWidth)
    }

    private func configureTitle() {
        title = Constants.appName
        let font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .bold)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font]
    }

    private func configureAppearance() {
        view.backgroundColor = .systemBackground
    }

    private func configureNavigationBar() {
        guard let nc = navigationController else {
            return
        }
        nc.navigationBar.setBackgroundImage(UIImage(), for: .default)
        nc.navigationBar.shadowImage = UIImage()
        nc.navigationBar.isTranslucent = true
        nc.view.backgroundColor = .clear
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
        var cal = Constants.calendar
        cal.locale = .autoupdatingCurrent
        calendarView.firstWeekday = UInt(cal.firstWeekday)
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.allowsMultipleSelection = false
        calendarView.register(CalendarDayCell.self, forCellReuseIdentifier: Self.calendarCellId)
        calendarView.appearance.headerDateFormat = "LLLL yyyy"
        calendarView.appearance.headerTitleColor = .label
        calendarView.appearance.weekdayTextColor = .label
        calendarView.appearance.headerTitleFont = .preferredFont(forTextStyle: .body)
        calendarView.appearance.caseOptions = [.headerUsesUpperCase, .weekdayUsesUpperCase]
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
        selectedDayLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        selectedDayLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        selectedDayLabel.heightAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.125).isActive = true
        selectedDayLabel.font = .preferredFont(forTextStyle: .body)
        selectedDayLabel.textAlignment = .center
        selectedDayLabel.baselineAdjustment = .alignCenters
        selectedDayLabel.adjustsFontForContentSizeCategory = true
        selectedDayLabel.adjustsFontSizeToFitWidth = true
    }

    private func updateNoItemsState() {
        if itemsForSelectedDay()?.count ?? 0 == 0 {
            configureEmptyPlaceholderIfNeed()
            emptyPlaceholderLabel.isHidden = false
            tableView.isHidden = true
        } else {
            emptyPlaceholderLabel.isHidden = true
            tableView.isHidden = false
        }
    }

    private func configureEmptyPlaceholderIfNeed() {
        guard emptyPlaceholderLabel.superview == nil else {
            return
        }
        view.addSubview(emptyPlaceholderLabel)
        emptyPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyPlaceholderLabel.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        emptyPlaceholderLabel.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        emptyPlaceholderLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        emptyPlaceholderLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        emptyPlaceholderLabel.font = .preferredFont(forTextStyle: .body)
        emptyPlaceholderLabel.textAlignment = .center
        emptyPlaceholderLabel.baselineAdjustment = .alignCenters
        emptyPlaceholderLabel.adjustsFontForContentSizeCategory = true
        emptyPlaceholderLabel.adjustsFontSizeToFitWidth = true
        emptyPlaceholderLabel.text = Constants.noData
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: selectedDayLabel.bottomAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.dataSource = self
        tableView.register(DataItemTableViewCell.self, forCellReuseIdentifier: String(describing: DataItemTableViewCell.self))
    }

    private func configureInfoButton() {
        let image = UIImage(systemName: "info.circle")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showInfo))
        self.navigationItem.rightBarButtonItem?.tintColor = .label
    }

    private func setActivityIndicatorEnabled(_ enabled: Bool) {
        DispatchQueue.main.async {
            if enabled {
                if self.navigationItem.leftBarButtonItem == nil {
                    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
                }
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateSizeCategory),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
        timeService.day.addObserver(self) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.redrawCalendarView()
            self.selectCurrentDate()
        }
        dataInteractor.isProcessing.addObserver(self) { [weak self] isProcessing in
            guard let self = self else {
                return
            }
            if !isProcessing {
                self.refreshData()
            }
            self.setActivityIndicatorEnabled(isProcessing)
        }
    }

    @objc private func updateSizeCategory() {
        redrawCalendarView()
        configureTitle()
    }

    private func removeObservers() {
        timeService.day.removeObserver(self)
    }

    private func configureScopeGesture() {
        scopeGesture = UIPanGestureRecognizer(target: self, action: #selector(handleScopeGesture(_:)))
        scopeGesture.minimumNumberOfTouches = 1
        scopeGesture.maximumNumberOfTouches = 2
        scopeGesture.delegate = self
        view.addGestureRecognizer(scopeGesture)
        tableView.panGestureRecognizer.require(toFail: scopeGesture)
    }

    @objc func handleScopeGesture(_ gesture: UIPanGestureRecognizer) {
        var translation = gesture.translation(in: view)
        if (calendarView.scope == .month && translation.y > 0) ||
            (calendarView.scope == .week && translation.y < 0) {
            translation.y = 0
            gesture.setTranslation(translation, in: view)
        }
        calendarView.handleScopeGesture(gesture)
    }

    private func refreshData() {
        DispatchQueue.main.async {
            self.calendarView.reloadData()
            self.tableView.reloadData()
            self.updateNoItemsState()
        }
    }

    private func showDetails(for date: Date?) {
        if let date = date {
            selectedDayLabel.text = selectedDayFormatter.string(from: date).capitalizedFirstLetter
            tableView.reloadData()
            updateNoItemsState()
        }
    }

    private func itemsForSelectedDay() -> [DataItem]? {
        if let date = selectedDate {
            return dataInteractor.items(forDate: date)
        }
        return nil
    }

    private func select(date: Date) {
        selectedDate = date
        showDetails(for: date)
        calendarView.select(date, scrollToDate: true)
    }
}

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate {

    // MARK: - FSCalendarDataSource

    func minimumDate(for calendar: FSCalendar) -> Date {
        return dataInteractor.dateInterval?.start ?? Date()
    }

    func maximumDate(for calendar: FSCalendar) -> Date {
        return dataInteractor.dateInterval?.end ?? Date()
    }

    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        return calendar.dequeueReusableCell(withIdentifier: Self.calendarCellId, for: date, at: position)
    }

    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: position)
    }

    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let dayCell = (cell as! CalendarDayCell)
        dayCell.configure(position: position, value: dataInteractor.maxValue(forDate: date))
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
        select(date: date)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DataItemTableViewCell.self), for: indexPath) as! DataItemTableViewCell
        if 
            let items = itemsForSelectedDay(),
            indexPath.row < items.count
        {
            let item = items[indexPath.row]
            cell.configure(item: item)
        } else {
            cell.configure(item: nil)
        }
        return cell
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
