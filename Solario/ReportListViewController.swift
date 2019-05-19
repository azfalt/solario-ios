//
//  ReportListViewController.swift
//  Solario
//
//  Created by Herman Wagenleitner on 05/03/2017.
//  Copyright © 2017 Herman Wagenleitner. All rights reserved.
//

import UIKit

class ReportListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private enum SectionType {
        case current, reports
    }

    public var reportsInteractor: ReportsInteractor!

    private let sections: [SectionType] = [.current, .reports]

    private lazy var tableView: UITableView = UITableView(frame: CGRect.zero, style: .grouped)

    private var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func configure() {
        title = "Solario"
        configureTableView()
        configureRefreshControl()
        subsribeToReportsNotifications()
    }

    private func subsribeToReportsNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateLoadingState),
                                               name: ReportsInteractor.Notifications.ReportWillStartLoading,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateLoadingState),
                                               name: ReportsInteractor.Notifications.ReportDidFinishLoading,
                                               object: nil)
    }

    @objc dynamic private func loadReports() {
        refreshControl.beginRefreshing()
        reportsInteractor.loadReports()
    }

    @objc dynamic func updateLoadingState() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.reportsInteractor.isAnyReportLoading == false && self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(loadReports), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .current:
            return 1
        case .reports:
            return reportsInteractor.reports.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .current:
            return cellForCurrentValue()
        case .reports:
            return cellForReport(row: indexPath.row)
        }
    }

    private func cellForCurrentValue() -> UITableViewCell {
        let cell = ReportItemTableViewCell()
        cell.configure(item: reportsInteractor.currentMonthReport.items?.last)
        return cell
    }

    private func cellForReport(row: Int) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ReportCell")
        let report = reportsInteractor.reports[row]
        cell.textLabel?.textColor = Appearance.textColor
        cell.textLabel?.text = report.title
        cell.detailTextLabel?.textColor = Appearance.secondaryTextColor
        cell.detailTextLabel?.text = statusString(forReport: report)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    private func statusString(forReport report: Report) -> String? {
        var string: String?
        if let loadDate = report.loadDate {
            string = loadDateFormatter.string(from: loadDate)
        }
        if report.isLoading {
            string = (string ?? "") + " " + "_report_status_loading".localized
        }
        return string?.trimmingCharacters(in: .whitespaces)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section] {
        case .current:
            return "_current_section_title".localized
        case .reports:
            return "_reports_section_title".localized
        }
    }

    private lazy var loadDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .reports:
            let report = reportsInteractor.reports[indexPath.row]
            showReport(report)
        default:
            break
        }
    }

    private func showReport(_ report: Report) {
        let vc = ReportViewController()
        vc.report = report
        navigationController?.pushViewController(vc, animated: true)
    }
}
