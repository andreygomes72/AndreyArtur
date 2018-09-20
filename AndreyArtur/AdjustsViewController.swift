//
//  AdjustsViewController.swift
//  AndreyArtur
//
//  Created by Andrey Gomes on 02/09/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

enum CategoryType {
    case add, edit
}

class AdjustsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //var states: [State] = []
    var state: State!
    //var product: Product!
    var label: UILabel!
    var alert: UIAlertController!
    var fetchedResultController: NSFetchedResultsController<State>!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfRate: UITextField!
    @IBOutlet weak var tfIOF: UITextField!
    
    @IBAction func rateChanged(_ sender: UITextField) {
        if let value = tfRate.text, let dValue = Double(value), dValue > 0 {
            UserDefaults.standard.set(dValue, forKey: "rate")
        }
    }
    
    @IBAction func iofChanged(_ sender: UITextField) {
        if let value = tfIOF.text, let dValue = Double(value), dValue >= 0 {
            UserDefaults.standard.set(dValue, forKey: "iof")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = self.fetchedResultController.object(at: indexPath)
        tableView.setEditing(false, animated: true)
        self.showAlert(type: .edit, state: state)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let state = self.fetchedResultController.object(at: indexPath)
            self.context.delete(state)
            do {
                try self.context.save()
                self.loadStates()
                self.tableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stateCell", for: indexPath)
        
        let state = self.fetchedResultController.object(at: indexPath)
        
        if let name = state.name {
            cell.textLabel?.text = name
        }
        
        cell.detailTextLabel?.text = String(format: "%.2F", state.tax)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.fetchedResultController.fetchedObjects?.count {
            tableView.backgroundView = (count == 0) ? label : nil
            return count
        } else {
            tableView.backgroundView = label
            return 0
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
        label.text = "Lista de estados vazia."
        label.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tfRate.text = String(format : "%.2f" ,UserDefaults.standard.double(forKey: "rate"))
        tfIOF.text = String(format: "%.2f", UserDefaults.standard.double(forKey: "iof"))
        loadStates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func addState(_ sender: UIButton) {
        showAlert(type: .add, state: nil)
    }
    
    func loadStates() {
        let fetchedRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchedRequest.sortDescriptors = [sortDescriptor]
        self.fetchedResultController = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try self.fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    @objc func stateTextChanged(sender: UITextField)
    {
        var isOK = true
        
        if let fields = alert.textFields {
            for field in fields {
                if let placeHolder = field.placeholder {
                    if placeHolder.range(of: "Nome") != nil {
                        if let text = field.text, text.count > 1 {
                            isOK = isOK && true
                        } else {
                            isOK = false
                        }
                    } else if placeHolder.range(of: "Imposto") != nil {
                        if let text = field.text, let dValue = Double(text), dValue >= 0.0 {
                            isOK = isOK && true
                        } else {
                            isOK = false
                        }
                    }
                }
            }
        }
        
        if let okButton = alert.actions.first {
            okButton.isEnabled = isOK
        }
    }
    
    
    func showAlert(type: CategoryType, state: State?) {
        
        let title = state == nil ? "Cadastar" : "Atualizar"
        
        alert = UIAlertController(title: title, message: "Preencha o nome do estado e a taxa", preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Nome do estado"
            textField.addTarget(self, action: #selector(self.stateTextChanged), for: .editingChanged)
            if let name = state?.name {
                textField.text = name
            }
        }
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Imposto"
            textField.addTarget(self, action: #selector(self.stateTextChanged), for: .editingChanged)
            textField.keyboardType = .decimalPad
            if let tax = state?.tax {
                textField.text = String(format: "%.2f", tax)
            }
        }
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            let state = self.state ?? State(context: self.context)
            var errorMessage = ""
            if let name = self.alert.textFields?.first?.text, name.count > 0 {
                state.name = name
            }
            else {
                errorMessage += "Campo de nome está vazio\n"
            }
            
            if let strTax = self.alert.textFields?.last?.text, let tax = Double(strTax) {
                state.tax = tax
            }
            else {
                errorMessage += "Campo de taxa está vazio"
            }
            
            if errorMessage.count > 1 {
                print(errorMessage)
                self.context.delete(state)
                self.state = nil
            }
            
            do {
                try self.context.save()
                self.loadStates()
                self.tableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        }))
        if let firstAction = alert.actions.first {
            firstAction.isEnabled = false
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
 

}
