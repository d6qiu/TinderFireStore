//
//  HeaderController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 9/30/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit

/**
 ListHeaderController helps register, dequeues, and sets up cells with their respective items to render in a standard single section list.
 ## Generics ##
 T: the cell type that this list will register and dequeue.
 
 U: the item type that each cell will visually represent.
 
 H: the header type above the section of cells.
 
 */
open class ListHeaderController<T: ListCell<U>, U, H: UICollectionReusableView>: ListHeaderFooterController<T, U, H, UICollectionReusableView> {
}
