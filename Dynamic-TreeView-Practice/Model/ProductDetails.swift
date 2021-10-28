//
//  ProductDetails.swift
//  PBTreeVIew
//
//  Created by Mac on 08/09/21.
//  Copyright © 2021 EatZilla. All rights reserved.
//

import Foundation

// MARK: - ProductDetails
struct ProductDetails: Codable {
    let status: Bool?
    let item: [Product]?
}

// MARK: - Item
struct Product: Codable {
    var mainIngredientGroup: [MainIngredientGroup]?
    let offerAmount, isVeg: Int?
    let foodQuantity: [Int]?
    let foodID: Int?
    let nameGreek: String?
    let addOns: [String]?
    let itemTax: Int?
    let itemDescription: String?
    let price: Double?
    let targetAmount, discountType: Int?
    let descriptionGreek: String?
    let image: String?
    let name: String?
    let itemCount: Int?
    let foodOffer: String?

    enum CodingKeys: String, CodingKey {
        case mainIngredientGroup = "main_ingredient_group"
        case offerAmount = "offer_amount"
        case isVeg = "is_veg"
        case foodQuantity = "food_quantity"
        case foodID = "food_id"
        case nameGreek = "name_greek"
        case addOns = "add_ons"
        case itemTax = "item_tax"
        case itemDescription = "description"
        case targetAmount = "target_amount"
        case discountType = "discount_type"
        case price
        case descriptionGreek = "description_greek"
        case image, name
        case itemCount = "item_count"
        case foodOffer = "food_offer"
    }
}

// MARK: - MainIngredientGroup
struct MainIngredientGroup: Codable {
    let name: String?
    let isSelectIngredientCount: Int?
    let groupIngredient: [GroupIngredient]?
    let status, min, id, subChoiceID: Int?
    let price: Double?
    let max: Int?
    let nameGreek, aliasName: String?

    enum CodingKeys: String, CodingKey {
        case name
        case isSelectIngredientCount = "is_select_ingredient_count"
        case groupIngredient = "group_ingredient"
        case status, min, id
        case subChoiceID = "sub_choice_id"
        case max, price
        case nameGreek = "name_greek"
        case aliasName = "alias_name"
    }
}

// MARK: - SubChoiceGroupIngredient
struct SubChoiceGroupIngredient: Codable {
    let id: Int?
    let parentID: String?
    let max, status, subChoiceID: Int?
    let nameGreek: String?
    let price: Double?
    let mainParentID, isSelectIngredientCount: Int?
    let groupIngredient: [GroupIngredient]?
    let min, isHavingIngredient: Int?
    let aliasName, name: String?

    enum CodingKeys: String, CodingKey {
        case id
        case parentID = "parent_id"
        case max, status
        case subChoiceID = "sub_choice_id"
        case nameGreek = "name_greek"
        case mainParentID = "main_parent_id"
        case price
        case isSelectIngredientCount = "is_select_ingredient_count"
        case groupIngredient = "group_ingredient"
        case min
        case isHavingIngredient = "is_having_ingredient"
        case aliasName = "alias_name"
        case name
    }
}

// MARK: - GroupIngredient
struct GroupIngredient: Codable {
    let subChoiceID: Int?
    let subChoiceGroupIngredient: [SubChoiceGroupIngredient]?
    let parentID: String?
    let price: Double?
    let isHavingSubchoice, id: Int?
    var isSelected: Int?
    let nameGreek: String?
    let mainParentID: Int?
    let name: String?
    let status: Int?
    let isHavingIngredient: Bool?

    enum CodingKeys: String, CodingKey {
        case subChoiceID = "sub_choice_id"
        case subChoiceGroupIngredient = "sub_choice_group_ingredient"
        case parentID = "parent_id"
        case isHavingSubchoice = "is_having_subchoice"
        case price, id
        case isSelected = "is_selected"
        case nameGreek = "name_greek"
        case mainParentID = "main_parent_id"
        case name, status
        case isHavingIngredient = "is_having_ingredient"
    }
}

// MARK:- Custom Ingredient Details
struct IngredientDetails {
    let id: Int
    let name: String
    let price: String
    let parentIDs: String
    let min: Int
    let max: Int
    let isSelected: Bool?
    let childrenCount: Int
    
}

// Only for ingredeint cells
enum CellType {
    case RadioButton
    case CheckBox
}
