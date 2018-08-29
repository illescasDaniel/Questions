//
//  SearchTableViewController.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 18/08/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchControllerDelegate {
	
	var items: [SetOfTopics.Mode: [TopicEntry]] = [:]
	var parentVC: UIViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
	
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let mode = SetOfTopics.Mode(rawValue: section) {
			return self.items[mode]?.count ?? 0
		}
		return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = UITableViewCell()

		if let mode = SetOfTopics.Mode(rawValue: indexPath.section), let topics = self.items[mode] {
			cell.textLabel?.text = topics[indexPath.row].displayedName.localized
		}
		
        return cell
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case SetOfTopics.Mode.app.rawValue: return Localized.Topics_AllTopics_Type_App
		case SetOfTopics.Mode.saved.rawValue: return Localized.Topics_AllTopics_Type_Saved
		case SetOfTopics.Mode.community.rawValue: return Localized.Topics_AllTopics_Type_Community
		default: return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		var outputIndexPath = indexPath
		
		switch indexPath.section {
		case SetOfTopics.Mode.app.rawValue: outputIndexPath.row = SetOfTopics.shared.topics.index(of: self.items[.app]![indexPath.row])!
		case SetOfTopics.Mode.saved.rawValue: outputIndexPath.row = SetOfTopics.shared.savedTopics.index(of: self.items[.saved]![indexPath.row])!
		case SetOfTopics.Mode.community.rawValue: outputIndexPath.row = SetOfTopics.shared.communityTopics.index(of: self.items[.community]![indexPath.row])!
		default: break
		}
		
		if indexPath.section == SetOfTopics.Mode.community.rawValue, let tableVC = self.parentVC as? UITableViewController {
			tableVC.tableView(tableVC.tableView, didSelectRowAt: IndexPath(row: outputIndexPath.row, section: 0))
			return
		}
		
		self.parentVC?.performSegue(withIdentifier: "selectTopic", sender: outputIndexPath)
	}
}
