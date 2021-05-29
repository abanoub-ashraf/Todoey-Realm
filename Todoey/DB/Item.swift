import Foundation
import RealmSwift

/// Object is a class used to define Realm model objects
class Item: Object {
    
    /**
     * these two modifiers allow realm to monitor the changes of the values
       of these variables and update them dynamically in the realm database
     */
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    /**
     * the inverse relationship: many items belong to one category
     * property is the forward relationship name we defined in the Category Class
     */
    var parentCateogory = LinkingObjects(
        fromType: Category.self,
        property: "items"
    )
}
