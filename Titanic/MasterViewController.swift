//
//  MasterViewController.swift
//  Titanic
//
//  Created by Drew Keller AND TRAVIS on 12/1/15.
//  Copyright © 2015 Drew Keller AND ALSO TRAVIS. All rights reserved.
//

import UIKit

// create the RegEx infix operator
infix operator =~ {associativity left precedence 130}

// define the RegEx operator:
// syntax:  "Word" =~ "^[A-Z]\w+" // -> true
func =~ (left: String, right: String) -> Bool {
    return Regex(right).test(left);
}

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()
    var passengers : [Passenger]!;
    
    var loadedMView : Int = 0;
    
    
    let stvc = SearchTableViewController()
    
    // data file
    let path = NSBundle.mainBundle().pathForResource("data", ofType: "xml")
    
    // default values
    var newMaxAge : Double = 100.0;
    var newMinAge : Double = 0.0;
    var nameSearch : String = ".*";
    var newGender : String = "all";
    
    func updateMinAge( d : Double ) {
        newMinAge = d;
    }
    func updateMaxAge( d : Double ) {
        newMaxAge = d;
    }
    func updateNameSearch( s : String ) {
        nameSearch = s;
    }
    func updateGender( s : String ) {
        newGender = s;
    }
    
    @IBAction func bottomSearch(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        // Read data from XML URL
        let url = NSURL(fileURLWithPath: path!);
        
        let parser : XMLParser = XMLParser();
        parser.parseFileWithURL(url);
        passengers = parser.getPassengers();
        print("data file not found.");
        
        passengers = sortPassengers(searchPassengersByRegex(searchPassengersByGender(searchPassengersByAgeRange(passengers, age1: newMaxAge, age2: newMinAge), gender: newGender), nameRegex: nameSearch ));
        
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "goSearch:"), animated: true)
        
    }
    
    
    func searchPassengersByRegex(array: [Passenger], nameRegex: String) -> [Passenger]{
        if (nameRegex == "") {
            return array;
        }
        let result = array.filter({
            $0.name =~ nameRegex
        })
        return result;
    }
    
    func searchPassengersByAgeRange(array: [Passenger], age1: Double, age2: Double) -> [Passenger]{
        var minAge, maxAge : Double;
        print("INSIDE SEARCH PASSENGER BY AGE RANGE")
        print(age1)
        print(age2)
        if age1 > age2 {
            maxAge = age1
            minAge = age2
        } else {
            maxAge = age2
            minAge = age1
        }
        let result = array.filter({
            ($0.age >= minAge) && ($0.age <= maxAge);
        })
        return result;
    }
    func searchPassengersByGender(array: [Passenger], gender: String) -> [Passenger] {
        if (gender == "all") {
            return array;
        }
        let result = array.filter({
            $0.sex == gender
        })
        return result
    }
    
    // alphabetize passengers
    func sortPassengers(passengers: [Passenger] = []) -> [Passenger] {
        return passengers.sort({
            $0.name < $1.name
        });
    }
    
    @IBAction func goSearch(sender: AnyObject) {
        
        let stvc : SearchTableViewController = self.storyboard?.instantiateViewControllerWithIdentifier( "stvc" ) as! SearchTableViewController;
        
        stvc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical;
        
        self.presentViewController(stvc, animated: true, completion: nil);
    }
    
    
    override func viewWillAppear(animated: Bool) {
        //self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        //super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewObject(sender: AnyObject) {
        objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                //let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                //controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                controller.setRow(indexPath.row);
                controller.assignPassengers(passengers);
                
            }
        }
        
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passengers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        //let object = objects[indexPath.row] as! NSDate
        //cell.textLabel!.text = object.description
        cell.textLabel!.text = passengers[indexPath.row].name;
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
}

