//
//  ViewController.swift
//  OrderFood
//
//  Created by MehulS on 04/05/18.
//  Copyright © 2018 MeHuLa. All rights reserved.
//

import UIKit
import Parchment

class Home: SuperViewController {

    @IBOutlet weak var lblShowVegDishesStatic: UILabel!
    @IBOutlet weak var switchVegNonVeg: UISwitch!
    @IBOutlet weak var viewCart: UIView!
    @IBOutlet weak var lblCartInfo: UILabel!
    
    var strTitle : String = "Home"
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //Navigation Title
        self.navigationItem.title = self.strTitle
        
        //Hide Other Controls
        self.lblShowVegDishesStatic.isHidden = true
        self.switchVegNonVeg.isHidden = true
        
        //Firstly hide cart view
        self.showCartView()
        
        //Get All Categories
        self.getAllCategories()
        
        //Add Observer to Show/Hide Cart View
        NotificationCenter.default.addObserver(self, selector: #selector(Home.manageCartView), name: NSNotification.Name(rawValue: "ManageCartView"), object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Veg / Non-Veg
    @IBAction func switchVegNonValueChanged(_ sender: Any) {
        if self.switchVegNonVeg.isOn == true {
            self.switchVegNonVeg.isOn = true
            AppUtils.APPDELEGATE().isNeedToShowVegItemsOnly = true
        }else {
            self.switchVegNonVeg.isOn = false
            AppUtils.APPDELEGATE().isNeedToShowVegItemsOnly = false
        }
        
        //Post Observer for Filter Items on Veg / Non-Veg
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FilterItemsForVeg"), object: nil)
    }
    
    
    
    //MARK: - Set Up Page View Controller
    func setUpPageViewControllers() -> Void {
        //Show Other Controls
        self.lblShowVegDishesStatic.isHidden = false
        self.switchVegNonVeg.isHidden = false
        
        //Right Bar Button
        let rightBarWhistle = UIBarButtonItem(image: UIImage(named: "Whistle")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(whistleClicked))
        
        let rightBarSearch = UIBarButtonItem(image: UIImage(named: "Search")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(searchClicked))
        
        self.navigationItem.rightBarButtonItems = [rightBarWhistle, rightBarSearch]
        
        //Category wise controller
        let count = AppUtils.APPDELEGATE().arrayCategory.count - 1
        let viewControllers = (0...count).map { CategoryViewController(index: $0) }
        
        /*var arrayViewCTR = [CategoryViewController]()
         for index in 0...10 {
         let viewCTR = CategoryViewController(index: index)
         arrayViewCTR.append(viewCTR)
         }*/
        
        let pagingViewController = FixedPagingViewController(viewControllers: viewControllers)
        
        // Make sure you add the PagingViewController as a child view
        // controller and constrain it to the edges of the view.
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
        
        
        //Bring controls to front
        self.view.bringSubview(toFront: switchVegNonVeg)
        self.view.bringSubview(toFront: viewCart)
    }
    
    
    //MARK: - Observer
    func manageCartView(_ notification: Notification) -> Void {
        self.showCartView()
    }
    
    func showCartView() -> Void {
        if AppUtils.APPDELEGATE().arrayCart.count > 0 {
            //Show Cart View
            self.viewCart.isHidden = false
            
            //Get Total number of Item and Price
            var total = 0.00
            var totalItem = 0
            for item in AppUtils.APPDELEGATE().arrayCart {
                totalItem = totalItem + item.numberOfItem!
                
                let numberOfItemDouble = Double(item.numberOfItem!)
                total = total + (numberOfItemDouble * item.price!)
                
                //Tax
                if let tax = item.tax {
                    total = total + (numberOfItemDouble * tax)
                }
            }
            
            //Set Data
            self.lblCartInfo.text = "\(totalItem) ITEMS : $ \(total)"
            
        }else {
            //Hide Cart View
            self.viewCart.isHidden = true
        }
    }


    //MARK: - Search
    func searchClicked() -> Void {
        let viewCTR = Constants.StoryBoardFile.MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.StoryBoardIdentifier.SEARCH) as! Search
        self.navigationController?.pushViewController(viewCTR, animated: true)
    }
    
    //MARK: - Whistle
    func whistleClicked() -> Void {
        AppUtils.showAlertWithTitle(title: "", message: "Do you want to call waiter?", viewController: self)
    }
    
    //MARK: - View Cart
    @IBAction func btnViewCartClicked(_ sender: Any) {
        
        //If any item added or deleted to cart, update through web service
        if AppUtils.APPDELEGATE().isAnyChangeInCart == true {
            //Call Web Service to Update Cart
            self.updateCart()
        }else {
            self.navigateToViewCart()
        }
    }
    
    func navigateToViewCart() -> Void {
        let viewCTR = Constants.StoryBoardFile.MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.StoryBoardIdentifier.MY_CART) as! MyCart
        self.navigationController?.pushViewController(viewCTR, animated: true)
    }
}


//MARK: - Web Services
extension Home {
    //MARK: - Get All Categories
    func getAllCategories() -> Void {
        
        let strVenueID = "\(AppUtils.APPDELEGATE().CartDeliveryModel.venueId)"
        
        Category.getcategories(strVenueID: strVenueID, showLoader: true) { (isSuccess, response, error) in
            
            if error == nil {
                //Get Data
                AppUtils.APPDELEGATE().arrayCategory = response?.formattedData as! [Category]
                print("Category Count = \(AppUtils.APPDELEGATE().arrayCategory.count)")
                
                if AppUtils.APPDELEGATE().arrayCategory.count > 0 {
                    
                    //Get Page View Controller
                    self.setUpPageViewControllers()
                }
            }else {
            }
        }
    }
    
    //MARK: - Update Cart
    func updateCart() -> Void {
        
        //Initialise Array
        let arrayModifiedCart = NSMutableArray()
        
        var uuid = AppUtils.APPDELEGATE().guid
        if uuid == "" {
            uuid = ""
        }
        
        //Get Modified Array
        for cart in AppUtils.APPDELEGATE().arrayCart {
            //If item modified then only update through web service
            if cart.isItemModified == true {
                var dictTemp = [String : AnyObject]()
                
                dictTemp["GuId"]        = uuid as AnyObject
                dictTemp["discountId"]  = 0 as AnyObject
                dictTemp["ItemID"]      = cart.itemID as AnyObject
                dictTemp["itemName"]    = cart.itemName as AnyObject
                dictTemp["itemPrice"]   = cart.price as AnyObject
                dictTemp["Qty"]         = cart.numberOfItem as AnyObject
                dictTemp["tax"]         = 0 as AnyObject
                
                arrayModifiedCart.add(dictTemp)
                
                //Update Global Cart Modified value, so next time if there is no change, it will not call web service
                cart.isItemModified = false
            }
        }
        
        //If there is nothing to update in ARRAY, no need to call WS
        if arrayModifiedCart.count <= 0 {
            //Update Flag
            AppUtils.APPDELEGATE().isAnyChangeInCart = false
            
            //Navigate to next screen
            self.navigateToViewCart()
            
        }else {
            
            CartModel.createCart(arrayItems: arrayModifiedCart, showLoader: true) { (isSuccess, response, error) in
                
                if isSuccess == true {
                    //Success, there is no data getting in response
                    
                    //Get GUID
                    if let strGuid = response?.data as? String {
                        //Temp GUID stored
                        UserDefaults.standard.set(strGuid, forKey: "guid")
                        UserDefaults.standard.synchronize()
                        
                        //Store GUID
                        AppUtils.APPDELEGATE().guid = strGuid
                    }
                    
                    //Update Flag
                    AppUtils.APPDELEGATE().isAnyChangeInCart = false
                    
                    //Navigate to next screen
                    self.navigateToViewCart()
                    
                }else {
                }
            }
        }
    }
}

