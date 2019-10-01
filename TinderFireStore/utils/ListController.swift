//
//  ListController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 9/30/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit

/**
 Convenient list component where a Header class is not required.
 
 ## Generics ##
 T: the cell type that this list will register and dequeue.
 
 U: the item type that each cell will visually represent.
 */

open class ListController<T: ListCell<U>, U>: ListHeaderController<T, U, UICollectionReusableView> {
}
