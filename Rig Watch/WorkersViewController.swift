//
//  ViewController.swift
//  Miner Office
//
//  Created by Nikita Marinosyan on 08.01.2018.
//  Copyright © 2018 Nikita Marinosyan. All rights reserved.
//

import UIKit

class WorkersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ExpandableHeaderViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var selectedWorker: Worker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        for pool in pools {
            if pool.addresses != nil {
                for address in pool.addresses {
                    ApiService.getWorkersByPoolAndAddress(pool: pool, minerAddress: address, onError: popupAlert) {addr, workersJson in
                        DispatchQueue.main.async {
                            self.activityIndicator.center = self.view.center
                            self.activityIndicator.hidesWhenStopped = true
                            self.view.addSubview(self.activityIndicator)
                            self.activityIndicator.startAnimating()
                            UIApplication.shared.beginIgnoringInteractionEvents()
                            
                            pool.updateWorkers(address: addr, workers: workersJson)
                            self.tableView?.reloadData()
                            
                            self.activityIndicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                        }
                    }
                }
            }
        }
    }
    
    func popupAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddViewController {
            destination.tableView = self.tableView
            return
        }
        
        if let destination = segue.destination as? WorkerDetailViewController {
            destination.worker = selectedWorker
        }
    }
    
    // TableView
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // Popup alert sheet
            let alert = UIAlertController(title: "Remove all workers in the pool?", message: "", preferredStyle: .actionSheet)
            let deleteAllAction = UIAlertAction(title: "Delete all workers in pool", style: .default) { (alert: UIAlertAction!) -> Void in
                pools[indexPath.section].workers.removeAll()
                pools[indexPath.section].addresses.removeAll()
                tableView.reloadData()
            }
            let deleteOnlyOne = UIAlertAction(title: "Delete only selected worker", style: .default) { (alert: UIAlertAction!) -> Void in
                pools[indexPath.section].workers.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            }
            alert.addAction(deleteOnlyOne)
            alert.addAction(deleteAllAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].pool.workers.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if sections[indexPath.section].expanded {
            return 44
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderView()
        header.custonInit(poolName: sections[section].pool.name, section: section, delegate: self)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell")!
        cell.textLabel?.text = sections[indexPath.section].pool.workers[indexPath.row].name
        
        let current = Utils.getCurrentTimestamp()
        let lastSeen = Int64(sections[indexPath.section].pool.workers[indexPath.row].lastSeen)!
        let minutesInterval = Int((Double(current - lastSeen) / 60).rounded())
        if minutesInterval == 1 {
            cell.detailTextLabel?.text = "Last seen \(minutesInterval) minute ago"
        } else {
            cell.detailTextLabel?.text = "Last seen \(minutesInterval) minutes ago"
        }
        
        if minutesInterval > 14 {
            cell.backgroundColor = Utils.hexStringToUIColor(hex: "#f79279")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedWorker = pools[indexPath.section].workers[indexPath.row]

        performSegue(withIdentifier: "showWorkerDetails", sender: self)
    }
    
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        sections[section].expanded = !sections[section].expanded
        
        tableView.beginUpdates()
        for i in 0 ..< sections[section].pool.workers.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates()
    }
    
}

