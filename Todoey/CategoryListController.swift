import UIKit
import RealmSwift
import ChameleonFramework

class CategoryListController: SwipeTableController {
    
    // MARK: - Variables -
    
    let realm = try! Realm()
    
    // Results is an auto-updating container type in Realm returned from object queries
    var categories: Results<Category>?
        
    // MARK: - LifeCycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // to remove the line separtors between the rows
        tableView.separatorStyle = .none
            
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        navBarAppearance.backgroundColor = FlatSkyBlue()
        
        navBar.standardAppearance = navBarAppearance
        navBar.scrollEdgeAppearance = navBarAppearance
    }
    
    // MARK: - IBActions -
    
    /// add a new category
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add A New Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { (field) in
            textField = field
            field.placeholder = "create new category..."
        }
        
        alert.view.tintColor = .label
        
        /// save the new category to the realm database
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let newCategoryTitle = textField.text, !newCategoryTitle.isEmpty {
                let newCategory = Category()
                newCategory.name = newCategoryTitle
                /// make a random color using chameleon library, it allows us to get the string value of the color
                newCategory.color = UIColor.randomFlat().hexValue()
                /**
                 * we don't need to append to the categories array cause
                   it's of type Results and that's an auto updating container
                   and monitors for the changes
                 */
                self.save(category: newCategory)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        alert.setValue(
            NSAttributedString(
                string: alert.title!,
                attributes: [
                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
                ]
            ),
            forKey: "attributedTitle"
        )

        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Helper Functions -
    
    /// save categories to realm database
    private func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context, \(error)")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func loadCategories() {
        // objects() returns all objects of the given type stored in the Realm
        categories = realm.objects(Category.self)
        
        self.tableView.reloadData()
    }
    
    /// this method gets fired when the delete action swipe happens and that logic is inside the super class
    override func updateModel(at indexPath: IndexPath) {
        
        super.updateModel(at: indexPath)
        
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                // delete from realm is enough cause the array we use is a realm container
                try self.realm.write {
                    // delete the items of the category first then delete the category
                    self.realm.delete(categoryForDeletion.items)
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    
    // MARK: - Segues -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destinationVC = segue.destination as! TodoListController
            if let indexPath = tableView.indexPathForSelectedRow {
                // pass the selectedCategory to the TodoListController to display the items of that categorey
                destinationVC.selectedCategory = categories?[indexPath.row]
            }
        }
    }
    
}

// MARK: - TableView Datasource Methods -

extension CategoryListController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /**
         * access the cell from the SwipeTableController super class
         * this calls the cellForRowAt() that's in the super class
         * now this cell is of type SwipeTableViewCell and its delegate is set to self in the super class
         */
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            
            cell.textLabel?.text = category.name
            
            /// create the color using a string cause the color property inside the category is a string
            cell.backgroundColor = UIColor(hexString: category.color)
        }
        
        return cell
    }
    
}

// MARK: - TableView Delegate Methods -

extension CategoryListController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
