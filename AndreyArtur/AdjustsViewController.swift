//
//  AdjustsViewController.swift
//  AndreyArtur
//
//  Created by Andrey Gomes on 02/09/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

class AdjustsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var states: [State] = []
    var product: Product!
    
    @IBOutlet weak var tableView: UITableView!
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stateCell", for: indexPath)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return states.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func addState(_ sender: UIButton) {
        showAlert(state: nil)
    }
    
    func showAlert(state: State?) {
        
        let title = state == nil ? "Cadastar Estado" : "Atualizar Estado"
        
        let alert = UIAlertController(title: title, message: "Preencha o nome do estado e a taxa", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            //let stateName = alert.textFields![0].text!
            //let sn = state ?? State(context: self.context)
            //sn.name = stateName
            //try! self.context.save()
            //self.loadCategories()
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Nome do estado"
            textField.text = state?.name
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Imposto"
            textField.text = String(format: "%.2f", state?.tax ?? "")
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
