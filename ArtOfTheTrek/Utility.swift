//
//  Utility.swift
//  ArtOfTheTrek
//
//  Created by Rajinder on 15/03/20.
//  Copyright © 2020 appzpixel. All rights reserved.
//

import Foundation
import UIKit

class Utility {

    
    static func showAlert(_ message: String, _ fromController: UIViewController?) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        fromController?.present(alertController, animated: true, completion: nil)
    }
}
