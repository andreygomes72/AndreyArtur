//
//  ShopListTableViewController.swift
//  AndreyArtur
//
//  Created by Andrey Gomes on 02/09/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

class ShopListTableViewController: UITableViewController {
    
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
    var fetchedResultController: NSFetchedResultsController<Product>!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 103
        label.text = "Sua lista está vazia!"
        label.textAlignment = .center
        
        loadProducts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProductViewController, let indexPath = tableView.indexPathForSelectedRow {
            vc.product = fetchedResultController.object(at: indexPath)
        }
    }
    
    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
      
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = fetchedResultController.fetchedObjects?.count {
            tableView.backgroundView = (count == 0) ? label : nil
            return count
        } else {
            tableView.backgroundView = label
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ShopListTableViewCell
        
        let product = fetchedResultController.object(at: indexPath)
        
        cell.lblProduct.text = product.name
        cell.lblPrice.text = "\(String(format: "%.2f", product.price))"
        
        if let image = product.image as? UIImage {
            cell.ivProduct.image = image
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = fetchedResultController.object(at: indexPath)
            context.delete(product)
            do {
                try context.save()
                loadProducts()
            } catch {
                print(error.localizedDescription)
            }
        } else if editingStyle == .insert {
        }
    }
}

extension ShopListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}


