//
//  ViewController.swift
//  Animal Identifier
//
//  Created by Gaurav Gaikwad on 7/24/19.
//  Copyright © 2019 anuja. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    
    
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var ImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        // Do any additional setup after loading the view.
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let userpickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
         guard  let CIImage = CIImage(image: userpickedImage) else
         {
            fatalError()
            }
            detect(image: CIImage)
            
                ImageView.image = userpickedImage
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage){
        
        guard  let model = try? VNCoreMLModel(for: PetImageClassifier().model) else{
            fatalError()
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results?.first as? VNClassificationObservation else{
                
                fatalError()
            }
            results.identifier
            self.navigationItem.title = results.identifier.capitalized
            self.whatAnimal(AnimalName: results.identifier)
            
            
            print(results)
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do{
        try! handler.perform([request])
        
        
        
    }
        catch{
            print("error")
        }
    
    }
    func  whatAnimal(AnimalName: String) {
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : AnimalName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "500"
        ]
        
        Alamofire.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess{
                print("detail about the animal")
                
            }else{
                print("error")
                let AnimalJSON : JSON = JSON(response.result.value)
                
                let pageid = AnimalJSON["query"]["pageid"][0].stringValue
                let AnimalDescription = AnimalJSON["query"]["pages"]["pageids"]["extract"][0].stringValue
                let AnimalImage = AnimalJSON["query"]["pages"]["pageid"]["thumbnail"]["source"].stringValue
                self.ImageView?.sd_setImage(with: URL(string: AnimalImage))
                
                
            }
        }
        
        
        
        
    }
    
    
    
    @IBAction func camerabuttontaapped(_ sender: UIBarButtonItem) {
        
        
    }
    

}


