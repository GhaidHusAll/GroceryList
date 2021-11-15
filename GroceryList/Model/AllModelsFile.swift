//
//  File.swift
//  GroceryList
//
//  Created by administrator on 10/11/2021.
//

import Foundation

struct User {
    let userName: String
    let emailAddress: String
    let isOnline: Bool
    let imageProfile: String?
}
struct Item {
    let id: String
    let name: String
    let isDone: Bool
    let User: String
    let urlImage: String?
}
