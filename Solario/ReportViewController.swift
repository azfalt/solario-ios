//
//  ReportViewController.swift
//  Solario
//
//  Created by Herman Wagenleitner on 02/08/2017.
//  Copyright © 2017 Herman Wagenleitner. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController, UITableViewDataSource {

  public var report: Report!

  private lazy var tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)

  private var refreshControl = UIRefreshControl()

  private var groups: [String] = []

  private var itemsByGroup: [String: [DataItem]] = [:]

  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
    groupItems()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    scrollToNearestDate()
  }

  private func scrollToNearestDate() {
    if let indexPath = nearestIndexPath {
      tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
  }

  @objc private func loadReport(completion: (() -> Void)?) {
    report.load(completion: { [weak self] in
      DispatchQueue.main.async {
        self?.groupItems()
        self?.tableView.reloadData()
        self?.refreshControl.endRefreshing()
        completion?()
      }
    })
  }

  private func groupItems() {
    guard let items = report.items else {
      return
    }
    var groups: [String] = []
    var itemsByGroup: [String: [DataItem]] = [:]
    for item in items {
      if let group = createGroup(fromItem: item) {
        if !groups.contains(group) {
          groups.append(group)
        }
        if itemsByGroup[group] == nil {
          itemsByGroup[group] = []
        }
        itemsByGroup[group]?.append(item)
      }
    }
    self.itemsByGroup = itemsByGroup
    self.groups = groups
  }

  private func createGroup(fromItem item: DataItem) -> String? {
    if let date = item.dateComponents.date {
      return groupDateFormatter.string(from: date)
    }
    return nil
  }

  private var nearestGroup: String? {
    guard let items = report.items else {
      return nil
    }
    var nearestGroup: String?
    var smallestInterval: TimeInterval = TimeInterval.greatestFiniteMagnitude
    let now = Date()
    for item in items {
      if let date = item.dateComponents.date {
        let interval = abs(now.timeIntervalSince(date))
        if interval < smallestInterval {
          smallestInterval = interval
          nearestGroup = createGroup(fromItem: item)
        }
      }
    }
    return nearestGroup
  }

  private var nearestIndexPath: IndexPath? {
    var nearestSection: Int?
    if let nearestGroup = nearestGroup {
      nearestSection = groups.index(of: nearestGroup)
    }
    if let section = nearestSection {
      return IndexPath(row: 0, section: section)
    }
    return nil
  }

  private func configure() {
    title = report.title
    configureNavigationButtons()
    configurePrompt()
    configureTableView()
    configureRefreshControl()
  }

  private func configurePrompt() {
    guard let issueDate = report.issueDate else {
      return
    }
    let dateString = issueDateFormatter.string(from: issueDate)
    navigationItem.prompt = String(format: "_issued_with_placeholder".localized, "\(dateString)")
  }

  private func configureTableView() {
    view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    tableView.dataSource = self
    tableView.register(ReportItemTableViewCell.self, forCellReuseIdentifier: String(describing: ReportItemTableViewCell.self))
  }

  private func configureRefreshControl() {
    refreshControl.addTarget(self, action: #selector(loadReport), for: .valueChanged)
    tableView.addSubview(refreshControl)
  }

  private func configureNavigationButtons() {
    let rawButton = UIBarButtonItem(title: "Raw", style: .plain, target: self, action: #selector(showRaw))
    navigationItem.rightBarButtonItem = rawButton
  }

  @objc private func showRaw() {
    let vc = RawViewController()
    vc.report = report
    navigationController?.pushViewController(vc, animated: true)
  }

  // MARK: - UITableViewDataSource

  func numberOfSections(in tableView: UITableView) -> Int {
    return groups.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let group = groups[section]
    return itemsByGroup[group]?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportItemTableViewCell.self), for: indexPath) as! ReportItemTableViewCell
    let group = groups[indexPath.section]
    if let item = itemsByGroup[group]?[indexPath.row] {
      cell.configure(item: item)
    }
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return groups[section]
  }

  private lazy var issueDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .short
    df.timeStyle = .short
    return df
  }()

  private lazy var groupDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .full
    df.timeStyle = .none
    return df
  }()
}
