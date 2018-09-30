//
//  ProductViewController.swift
//  AndreyArtur
//
//  Created by Andrey Gomes on 02/09/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

class ProductViewController: UIViewController {

    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var ivProduct: UIImageView!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var swCard: UISwitch!
    @IBOutlet weak var btnSave: UIButton!
    
    var fetchedResultController:  NSFetchedResultsController<State>!
    var pickerView: UIPickerView!
    var currentState: State!
    var product: Product!
    var smallImage: UIImage!
    var editingProduct: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelState))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        toolbar.items = [btCancel, btSpace, btDone]
        
        tfState.inputView = pickerView
        tfState.inputAccessoryView = toolbar
        
        editingProduct = false
        if product != nil {
            editingProduct = true
            btnSave.setTitle("Atualizar", for: .normal)
            tfName.text = product.name
            if let state = product.state {
                tfState.text = state.name
                currentState = state
            }
            tfPrice.text = String(format: "%.2f", product.price)
            swCard.isOn = product.card
            if let image = product.image as? UIImage {
                ivProduct.image = image
            }
        }
        loadStates();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadStates()
    }
    
    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
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
    
    @objc func cancelState() {
        tfState.resignFirstResponder()
    }
    
    @objc func done() {
        currentState = fetchedResultController.object(at: IndexPath(row: pickerView.selectedRow(inComponent: 0), section: 0))
        tfState.text = currentState.name
        cancelState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func save(_ sender: UIButton) {
        product = product ?? Product(context: context)
        var errorMessage: String = ""
        
        if let name = tfName.text, name.count > 0 {
            product.name = name
        }
        else {
            errorMessage += "Nome do produto está com conteúdo inválido!\n"
        }
        
        if let value = tfPrice.text, let dValue = Double(value), dValue >= 0 {
            product.price = dValue
        }
        else {
            errorMessage += "Preço está com valor inválido!\n"
        }
        
        product.card = swCard.isOn
        
        if currentState != nil {
            product.state = currentState
        }
        else {
            errorMessage += "Nome do estado está com conteúdo inválido!\n"
        }
        
        if smallImage != nil {
            product.image = smallImage
        } else {
            if editingProduct {
                product.image = ivProduct.image
            } else {
               errorMessage += "Imagem do produto é obrigatória!"
            }
        }
        
        if errorMessage.count > 1 {
            let alert = UIAlertController(title: "Atenção", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            context.undo()
            return
        }
        
        do {
            try context.save()
            dismiss(animated: true, completion: nil)
            navigationController?.popViewController(animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setNewImage(sourceType: UIImagePickerControllerSourceType)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func selectProductImage(_ sender: UIButton) {
        let alert = UIAlertController(title: "Selecionar imagem", message: "Selecione a origem da imagem", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.setNewImage(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.setNewImage(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

}

extension ProductViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        pickerView.reloadComponent(0)
    }
}

extension ProductViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let path = IndexPath(row: row, section: 0)
        let state:State = fetchedResultController.object(at: path)
        if let name = state.name {
            return name
        }
        return ""
    }
}

extension ProductViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let count = fetchedResultController.fetchedObjects?.count {
            return count
        } else {
            return 0
        }
    }
}

extension ProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?){
        let smallSize = CGSize(width: 335, height: 160)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        ivProduct.image = smallImage
        dismiss(animated: true, completion: nil)
    }
}
