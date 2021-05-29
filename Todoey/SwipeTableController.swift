import UIKit
import SwipeCellKit

class SwipeTableController: UITableViewController, SwipeTableViewCellDelegate {
        
    // MARK: - LifeCycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Helper Functions -
    
    /**
     * this method will get the indePath when the delete action happens
       then will get executed when it's overriden by inside any of the child classes
     */
    func updateModel(at indexPath: IndexPath) {
        // update the data model
    }
    
    // MARK: - SwipeTableViewCellDelegate -
    
    // the actions that gonna happe when we swipe the cell
    // Asks the delegate for the actions to display in response to a swipe in the specified row
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        // swipe the cell starting from the right side of the cell
        guard orientation == .right else { return nil }
        
        // the delete action
        /**
         * when this action happens in any of the child classes that inherits from this class,
           this updateModel() will get fired, having the indexPath it got from here
           but it does nothing here inside this super class, so it will do stuff
           whenever it's overriden by any of the child classes
         */
        let deleteAction = SwipeAction(style: .destructive, title: "Remove") { (action, indexPath) in
            self.updateModel(at: indexPath)
        }
        
        // customize the image of the delete action
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    // responsible for things like long swipe to delete the row, etc
    // Asks the delegate for the display options to be used while presenting the action buttons
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        
        var options = SwipeTableOptions()
        // The expansion style is the behavior when the cell is swiped past a defined threshold
        options.expansionStyle = .destructive
        // The transition style is the style of how the action buttons are exposed during the swipe
        options.transitionStyle = .border
        return options
    }
    
    // MARK: - TableViewDatasource -
    
    /**
    * to use SwipeCellKit, import it then:
    * =====================================
    * 1- down cast the table view cell to SwipeTableViewCell.
    * 2- change the identity of the cell in storyboard and the mdoule beneath it.
    * 3- then set the delegate property of our custom cell to self.
    * 4- then comform to the SwipeTableViewCellDelegate protocol and implement its required methods.
    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell",
            for: indexPath
        ) as! SwipeTableViewCell
        
        cell.delegate = self
                
        return cell
    }
    
    // MARK: - TableViewDelegate -
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

}
