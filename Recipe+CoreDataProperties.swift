//
//  Recipe+CoreDataProperties.swift
//  RecipeFinderApp
//
//  Created by ntvlbl on 13.12.2024.
//
//

import Foundation
import CoreData


extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var image: String?
    @NSManaged public var readyInMinutes: Int32
    @NSManaged public var calories: Int32

}

extension Recipe : Identifiable {

}
