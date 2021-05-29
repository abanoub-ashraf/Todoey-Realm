import UIKit
import RealmSwift
import ChameleonFramework

/**
 * UITableViewController means: no need to create tableview outlet
   or set the datasource or the delegate, it took care of those things for us
 */
class TodoListController: SwipeTableController {
    
    // MARK: - IBOutlets -
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Variables -
    
    let realm = try! Realm()
    
    // a list of the items of the selected category
    var todoItems: Results<Item>?
    
    // this got set from the prepare for segue functions inside the categories controller
    var selectedCategory: Category? {
        // when this variables did get set execute this block of code
        didSet {
            // load the items of the current selected category
            loadItems()
        }
    }
    
    // MARK: - LifeCycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureStatusBar()
    }
    
    // MARK: - IBActions -
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new todo item..."
            textField = alertTextField
        }
        
        alert.view.tintColor = .label
        
        // what will happen once the user clicks the add item button on the alert
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            /// save the new item to the current selected category
            if
                let currentCategory = self.selectedCategory,
                let newItemTitle = textField.text,
                !newItemTitle.isEmpty {
                do {
                    // save the new item
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = newItemTitle
                        newItem.dateCreated = Date()
                        // append it to the items list of the current category
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new item, \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Helper Functions -
    
    /// do i need to handle the case of running my app on an older versions here or no?
    private func configureStatusBar() {
        if let colorHex = selectedCategory?.color {
            
            navigationItem.title = selectedCategory!.name
            
            /**
             * if we put this code in viewDidLoad() it will crash cause this is nil
               cause this controller is not certainly added to the navigation stack yet
               so this is the better place
             */
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation controller does not exist.")
            }
            
            let navBarAppearance = UINavigationBarAppearance()
            
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            navBarAppearance.backgroundColor = UIColor(hexString: colorHex)
            
            navBar.standardAppearance = navBarAppearance
            navBar.scrollEdgeAppearance = navBarAppearance
            
            navBar.tintColor = .label
            
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
            
            if let navBarColor = UIColor(hexString: colorHex) {
                searchBar.barTintColor = navBarColor
            }
        }
    }
    
    // load the items of the selected category
    private func loadItems() {
        // .items is available because the relationship we established inside the category and item db classes
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    /// this method gets fired when the delete action swipe happens and that logic is inside the super class
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }

}

// MARK: - UITableViewDelegate -

extension TodoListController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // change the done property of the item, toggle it from true to false and vise versa
        if let item = todoItems?[indexPath.row] {
            do {
                // save the chagnes in the database
                try realm.write {
//                    realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - UITableViewDataSource -

extension TodoListController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
                
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            // this darken the color as we go down to the bottom rows in the table view
            if let color = UIColor(hexString: selectedCategory!.color)?
                .darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                // this change the color when the back ground color of the cell gets too dark
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            /// ternary operator ==> value = condition ? valueIfTrue : valueIfFalse
            // if the done property is true put a mark, the property will get set from didSelectRowAt() above
            cell.accessoryType = item.done == true ? .checkmark : .none
            //cell.accessoryView = item.done == true ? UIImageView(image: UIImage(named: "check")) : .none
        } else {
            cell.textLabel?.text = "No Items Added yet"
        }
        
        return cell
    }
    
}

// MARK: - UISearchBarDelegate -

extension TodoListController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?
            // this query is the predicate we gonna use to search the database using the title key
            .filter("title CONTAINS[cd] %@", searchBar.text!)
            // sort the results we gonna get using the title key
            .sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // this means if the cancel button inside the search bar is clicked and cleared the text inside
        if searchBar.text?.count == 0 {
            // load all the items of the current selected category again
            loadItems()
            // this change in the ui must happen in the main thread
            DispatchQueue.main.async {
                // dismiss the keyboard by making the search bar not the first responder
                searchBar.resignFirstResponder()
            }
        }
    }

}
