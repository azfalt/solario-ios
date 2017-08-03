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

  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
  }

  @objc private func loadReport() {
    report.load(completion: { [weak self] in
      DispatchQueue.main.async {
        self?.tableView.reloadData()
        self?.refreshControl.endRefreshing()
      }
    })
  }

  private func configure() {
    title = report.title
    configureNavigationButtons()
    configureTableView()
    configureRefreshControl()
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

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return report.items?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportItemTableViewCell.self), for: indexPath) as! ReportItemTableViewCell
    let item = report.items![indexPath.row]
    cell.configure(item: item)
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let issueDate = report.issueDate {
      let dateString = issueDateFormatter.string(from: issueDate)
      return String(format: "_issued_with_placeholder".localized, "\(dateString)")
    }
    return nil
  }

  private lazy var issueDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .short
    df.timeStyle = .short
    return df
  }()
}
