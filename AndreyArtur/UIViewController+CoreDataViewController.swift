//
//  UIViewController+CoreDataViewController.swift
//  AndreyArtur
//
//  Created by Andrey Gomes on 07/09/18.
//  Copyright © 2018 FIAP. All rights reserved.
//


import CoreData
import UIKit

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }

}
