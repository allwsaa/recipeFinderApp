//
//  RecipeEntity+CoreDataProperties.swift
//  
//
//  Created by ntvlbl on 13.12.2024.
//
//

import Foundation
import CoreData


extension RecipeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeEntity> {
        return NSFetchRequest<RecipeEntity>(entityName: "RecipeEntity")
    }

    @NSManaged public var calories: Int32
    @NSManaged public var id: Int64
    @NSManaged public var image: String?
    @NSManaged public var readyInMinutes: Int32
    @NSManaged public var title: String?

}
