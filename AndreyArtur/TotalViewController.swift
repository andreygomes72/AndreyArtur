//
//  TotalViewController.swift
//  AndreyArtur
//
//  Created by Andrey Gomes on 02/09/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

class TotalViewController: UIViewController {

    @IBOutlet weak var lblDollarsTotal: UILabel!
    @IBOutlet weak var lblReaisTotal: UILabel!
    
    var fetchedResultController: NSFetchedResultsController<Product>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProducts()
    }
    
    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
            calculateTotal()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func calculateTotal() {
        if let objects = fetchedResultController.fetchedObjects {
            var dollarTotal = 0.0;
            let rate = UserDefaults.standard.double(forKey: "rate")
            let iof = UserDefaults.standard.double(forKey: "iof")
            for product in objects {
                var productTotal = product.price
                if let state = product.state, state.tax != 0 {
                    productTotal *= ((state.tax / 100) + 1)
                }
                if product.card && iof != 0 {
                    productTotal *= ((iof / 100) + 1)
                }
                dollarTotal += productTotal
            }
            lblReaisTotal.text = String(format: "%.2f", (dollarTotal * rate))
            lblDollarsTotal.text = String(format: "%.2f", dollarTotal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TotalViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        calculateTotal()
    }
}
