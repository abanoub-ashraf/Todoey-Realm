import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    
    /**
     * List is the container type in Realm used to define to-many relationships
     * this is the forward relationship: one category has many items
     * items here is also the name of this forward relationship
     */
    let items = List<Item>()
}
