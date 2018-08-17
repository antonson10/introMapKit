//
//  AddAnnotationViewController.swift
//  introMapKit
//
//  Created by Ios Dev on 26/07/2018.
//  Copyright © 2018 avchugunov. All rights reserved.
//

import UIKit
import MapKit

class AddAnnotationViewController: UIViewController {
    var coordinate:CLLocationCoordinate2D?
    var newArtwork: Artwork?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "annotationAdded" {
            self.newArtwork = Artwork(title: "Новый артворк!", locationName: "тута", discipline: "где хотел", coordinate: self.coordinate!, description: "супер крутой артворк")
        }
    }
    
    @IBAction func cancelBTNClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
