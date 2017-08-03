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

  private let sections: [SectionType] = [.current, .reports]

  private lazy var tableView: UITableView = UITableView(frame: CGRect.zero, style: .grouped)

  private var refreshControl = UIRefreshControl()

  private let lastMonthReport = LastMonthReport()

  private let currentMonthReport = CurrentMonthReport()

  private let threeDayForecastReport = ThreeDayForecastReport()

  private let twentySevenDayForecastReport = TwentySevenDayForecastReport()

  private lazy var reports: [Report] = [
    self.lastMonthReport,
    self.currentMonthReport,
    self.threeDayForecastReport,
    self.twentySevenDayForecastReport
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
    loadReports()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }

  private func configure() {
    title = "Solario"
    configureTableView()
    configureRefreshControl()
  }

  @objc private func loadReports() {
    refreshControl.beginRefreshing()
    for report in reports {
      report.load(completion: { [weak self] in
        DispatchQueue.main.async {
          self?.tableView.reloadData()
          if self?.isAnyReportLoading == false {
            self?.refreshControl.endRefreshing()
          }
        }
      })
    }
  }

  private var isAnyReportLoading: Bool {
    for report in reports {
      if report.isLoading {
        return true
      }
    }
    return false
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
      return reports.count
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
    cell.configure(item: currentMonthReport.items?.last)
    return cell
  }

  private func cellForReport(row: Int) -> UITableViewCell {
    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ReportCell")
    let report = reports[row]
    cell.textLabel?.text = report.title
    if let loadDate = report.loadDate {
      let dateString = loadDateFormatter.string(from: loadDate)
      cell.detailTextLabel?.text = dateString
      cell.detailTextLabel?.textColor = UIColor.lightGray
    } else {
      cell.detailTextLabel?.text = nil
    }
    cell.accessoryType = .disclosureIndicator
    return cell
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

  // MARK - UITableViewDelegate

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch sections[indexPath.section] {
    case .reports:
      let report = reports[indexPath.row]
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
