//
//  VenueDetail.swift
//  OrderFood
//
//  Created by MehulS on 05/05/18.
//  Copyright © 2018 MeHuLa. All rights reserved.
//

import UIKit

class VenueDetail: SuperViewController {
    
    @IBOutlet weak var imageViewVenue: UIImageView!
    @IBOutlet weak var lblVenueName: UILabel!
    @IBOutlet weak var lblVenueAddress: UILabel!
    
    @IBOutlet weak var lblAvgTimeToDeliver: UILabel!
    @IBOutlet weak var lblMinOrder: UILabel!
    //@IBOutlet weak var lblAvgTimeToDeliver: UILabel!
    
    @IBOutlet weak var lblScreenID: UILabel!
    @IBOutlet weak var lblSeatID: UILabel!
    
    @IBOutlet weak var lblMinOrderStatic: UILabel!
    
    var venue: VenueInfo!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Get Venue Information
        self.getVenueInformation()
        
        //Get Cart, if available
        //self.getCart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Hide Navigation Bar
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Show Navigation Bar
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Set Venue Information
    func setVenueInformation() -> Void {
        //Set Image
        if venue.imageUrl.contains("https") {
            let url = URL(string: venue.imageUrl)
            self.imageViewVenue.sd_setImage(with: url, placeholderImage: UIImage(named: "NoImage"))
        }else {
            let url = URL(string: "https:" + venue.imageUrl)
            self.imageViewVenue.sd_setImage(with: url, placeholderImage: UIImage(named: "NoImage"))
        }
        
        lblVenueName.text = venue.name
        lblVenueAddress.text = venue.address
        
        lblAvgTimeToDeliver.text = "\(venue.avgMinsToDeliver) Min"
        lblMinOrder.text = "$\(venue.minOrder)"
        
        lblScreenID.text = "Screen - \(venue.seatId)"
        lblSeatID.text = venue.seatName
        
        lblMinOrderStatic.text = "Minimum order for this seat is $\(venue.minOrder)"
    }
 
    
    //MARK: - My Orders
    @IBAction func btnMyOrdersClicked(_ sender: Any) {
        let viewCTR = Constants.StoryBoardFile.MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.StoryBoardIdentifier.MY_ORDERS) as! MyOrders
        self.navigationController?.pushViewController(viewCTR, animated: true)
    }
    
    
    //MARK: - View Online Menu
    @IBAction func btnViewMenuClicked(_ sender: Any) {
        let viewCTR = Constants.StoryBoardFile.MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.StoryBoardIdentifier.RESTAURANTS) as! Restaurants
        
        //Pass Data
        viewCTR.strTitle = venue.name
        viewCTR.strVenueID = "\(venue.venueId)"
        
        AppUtils.APPDELEGATE().CartDeliveryModel.levelId    = venue.levelId
        AppUtils.APPDELEGATE().CartDeliveryModel.rowId      = venue.rowId
        AppUtils.APPDELEGATE().CartDeliveryModel.seatId     = venue.seatId
        AppUtils.APPDELEGATE().CartDeliveryModel.sectionId  = venue.sectionId
        AppUtils.APPDELEGATE().CartDeliveryModel.theaterId  = venue.theaterId
        
        self.navigationController?.pushViewController(viewCTR, animated: true)
    }
}

//MARK: - Web Services
extension VenueDetail {
    
    //MARK: - Get Venue Information
    func getVenueInformation() -> Void {
        VenueInfo.getVenueInfo(strQRCode: AppUtils.APPDELEGATE().strQRCodeValue, showLoader: true) { (isSuccess, response, error) in
            if isSuccess == true {
                //Get Data
                self.venue = response?.formattedData as! VenueInfo
                print("Cart from Web = \(self.venue)")
                
                //Set Data
                DispatchQueue.main.async {
                    self.setVenueInformation()
                }
                
            }else {
                //Prompt alert
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Invalid QRCode", message: "It seems like you have scanned wrong QRCode. Please scan right code.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default , handler:{ (UIAlertAction)in
                        //Pop
                        _ = self.navigationController?.popViewController(animated: true)
                    }))
                    
                    self.present(alert, animated: true, completion: {})
                }
            }
        }
    }
    
    
    //MARK: - Get All Categories
    func getCart() -> Void {
        
        CartModel.getCart(showLoader: true) { (isSuccess, response, error) in
            
            if isSuccess == true {
                //Get Data
                let array = response?.formattedData as! CartModel
                print("Cart from Web = \(array)")
                
                //First clear cart
                AppUtils.APPDELEGATE().arrayCart.removeAll()
                
                //Get Cart value into local object of Cart
                for item in array.cartItems! {
                    let cart = Cart()
                    
                    cart.itemID = item.itemId
                    cart.itemName = item.itemName
                    cart.numberOfItem = item.qty
                    cart.price = item.itemPrice
                    cart.isItemModified = false
                    
                    AppUtils.APPDELEGATE().arrayCart.append(cart)
                }
                
            }else {
            }
        }
    }
}
