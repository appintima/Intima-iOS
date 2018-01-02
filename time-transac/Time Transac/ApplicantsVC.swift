//
//  ApplicantsVC.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2018-01-02.
//  Copyright © 2018 Gbenga Ayobami. All rights reserved.
//

import UIKit

class ApplicantsVC: UITableViewController {
    
    var applicantsDict: [String:String]!
    var applicantsEHashArr:[String]!
    
    let service = ServiceCalls()

    override func viewDidLoad() {
        super.viewDidLoad()
        applicantsEHashArr = Array(applicantsDict.keys)
        print(applicantsEHashArr)
        print(applicantsDict)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return applicantsEHashArr.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = self.applicantsDict[self.applicantsEHashArr[indexPath.row]]
        return cell
    }
   

}
