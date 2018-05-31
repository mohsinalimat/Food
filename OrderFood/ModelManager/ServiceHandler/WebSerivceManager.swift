//
//  WebSerivceManager.swift
//  controlcast
//
//  Created by iPhone-4 on 16/02/17.
//  Copyright © 2017 Openxcell Game. All rights reserved.
//


import UIKit
import Alamofire
import ObjectMapper
import SwiftyJSON

enum Web_Service : String {
    case key = "key"
    case static_page = "admin/static_page"
    case login = "admin/login"
    case register_with_email = "admin/registration"
    case notificationSettingsChange = "user/changed_notification_status"
    case forgot_password = "admin/forgotPass"
    case change_password = "user/change_password"
    case notification_list = "user/getNotificationList"
    
    case country_list       = "admin/country"
    case state_list         = "admin/city"
    case city_list          = "admin/area"
    case industry_list      = "admin/industries"
    case contact_control_cast = "user/contactControlcast"
    case logout_user        = "user/logout"
    case manage_badge_count = "user/updateBaseCount"
    case unread_notification = "user/getNotificationBase"
    
    
    
    //Trusted & Blocked
    case add_to_block_list = "partner/addToBlock"
    case add_to_trusted_list = "partner/addToTrusted"
    
    case remove_from_blocked_list = "partner/removeBlocked"
    case remove_from_trusted_list = "partner/removeTrusted"
    
    case blocked_users_list = "partner/blockedList"
    case trusted_users_list = "partner/trustedList"
    
    
    case get_screen_data = "admin/getscreendata"
    
    case get_screen_listing = "partner/getScreenList"
    case register_screen    = "partner/addScreen"
    
    case get_ScreenByID_Name = "caster/getScreenDetailByID"
    case get_CastDetailByID  = "caster/getCastDetailsByID"
    
    case edit_profile_url = "user/editUserProfile"
    case viewProfile_By_ID = "user/getUserProfileByID"
    
    case get_Cast_SelectScreenDetail = "user/getCastSelectScreenDetail"
    
    case delete_screen = "partner/deleteScreen"
    case edit_screen   = "partner/editScreen"
    
    case shareCodeMessage   = "user/shareCodeMessage"
    case checkUserVerification   = "user/checkUserVerified"
    
    case screen_login   = "partner/screenLoginDetails"
    case make_video     = "partner/createScreenVideoImageText"
    
    //Cast
    case register_cast       = "caster/addCast"
    case edit_cast           = "caster/editCast"
    case make_video_Cast     = "caster/createVideoImageText"
    case pending_cast        = "caster/pendingCastList"
    case approved_cast       = "caster/approvedCastList"
    case screen_status       = "caster/getCastScreenStatus"
    case submit_feedback     = "caster/sendPatnerPendingMessage"
    case delete_cast         = "caster/deleteCast"
    //case filter_bulk_cast    = "caster/getScreenForBulkCast"
    case filter_bulk_cast    = "caster/getScreenForBulkCastV2"
    case add_credit          = "caster/createCharge"
    case history_caster      = "caster/getCastHistory"
    case screen_availability = "caster/checkscreensavailability"
    
    
    case screen_autocomplete = "user/getScreenListByAutocomplete"
    case referral_code       = "user/promoCodeCredit"
    case wallet_balance      = "user/getUserWallet"
    case get_bank_details    = "user/getBankDetailById"
    case transaction_history = "user/getTransactionHistory"
    case credit_list         = "user/browseplans"
    
    
    case requested_cast      = "partner/getRequestData"
    case approved_cast_partner = "partner/getApproveList"
    case cast_request_detail = "partner/getAllCastDetail"
    case approve_screen      = "partner/approveScreenCast"
    case reject_screen       = "partner/rejectScreenCast"
    case history_partner     = "partner/getCastHistory"
    
    case venue_name          = "partner/venueName"
    case transfer_credit     = "partner/transferCreditToCasterAccount"
    case submit_bank_info    = "partner/editBankDetails"
    case report_cast         = "partner/reportCast"
    case delete_cast_Partner = "partner/deleteCast"

    case version_control     = "version/checkVersion"
}

//Test
//private let mainUrl : String = "http://52.31.119.11/ws/"

//LIVE
private let mainUrl : String = "https://www.controlcastapp.com/user/ws/"

//BETA
//private let mainUrl : String = "https://www.controlcastapp.com/beta/ws/"




class WebSerivceManager:NSObject {
    
    let alamofireManager : Alamofire.SessionManager
    //static var defaultXAPIKey = "9cd65873c55ddc53f4be27d76e35f868232a8f09" //OLD
    static var defaultXAPIKey = "2592ea9f9ecc25bfcc562724dd674bde9c0a1830" //Hitesh
    
    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 6000
        configuration.timeoutIntervalForResource = 6000 // seconds
        alamofireManager = Alamofire.SessionManager(configuration: configuration)
        
    }
    
    //Post method
    class func POSTRequest(url:Web_Service, showLoader : Bool, Parameter:[String : AnyObject]?, success:((Bool,WebServiceReponse?, Error?) -> Void)?)
    {
        if(showLoader) {
            //Run on main thread
            DispatchQueue.main.async {
                AppUtils.showLoader()
            }
        }
        
        print(Parameter as Any)
        print(HeaderClass.objHeaderClass.HeaderDictionary)
        
        //Set Request Time
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60 // seconds
        let alamofireManager = Alamofire.SessionManager(configuration: configuration)
        
        print("URL : \(mainUrl + url.rawValue)")
        
        alamofireManager.request(mainUrl + url.rawValue, method: .post, parameters: Parameter, encoding: JSONEncoding.default, headers: HeaderClass.objHeaderClass.HeaderDictionary).responseJSON { (response:DataResponse<Any>) in
            alamofireManager.session.invalidateAndCancel()
            
            //var dataString = String(data: response.data!, encoding: .utf8)
            //print(dataString)
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil {
                    print("Response : \(response.result.value!)")
                    
                    //If user is not Authorise
                    if let dict = response.result.value as? [String : AnyObject] {
                        if let status = dict["STATUS"] as? Int {
                            print("Status : \(status)")
                            if status == 401 {
                                //Logout
                                let message = "\(dict["MESSAGE"]!)"
                                
                                let viewCTR = AppUtils.APPDELEGATE().window?.rootViewController as? UINavigationController
                                
                                //Not Authorise User
                                let alert = UIAlertController(title: "" as String , message: message, preferredStyle: .alert)
                                
                                let actionCameraImage = UIAlertAction(title: "OK", style: .default) {
                                    UIAlertAction in
                                    
                                    //Logout
                                    _ = viewCTR?.popToRootViewController(animated: true)
                                }
                                // Add the actions
                                alert.addAction(actionCameraImage)
                                viewCTR?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    
                    WebSerivceManager.HandleResponse(apicallMethod: url, apiResponse: response, successHandler: { (isSuccess, BaseModel, error) in
                        if let successBlock = success {
                            successBlock(isSuccess, BaseModel, error)
                        }
                    })
                }
                break
            
            case .failure(_):
                if let errorCode : Int = (response.result.error as? NSError)?.code{
                    
                    print("ErrorCode \(errorCode) \n \(response)")
                    
                    if (response.result.error as? NSError)?.code == -1005 {
                        
                        Alamofire.request(mainUrl + url.rawValue, method: .post, parameters: Parameter, encoding: JSONEncoding.default, headers: HeaderClass.objHeaderClass.HeaderDictionary).responseJSON { (response:DataResponse<Any>) in
                            
                            switch(response.result) {
                            case .success(_):
                                if response.result.value != nil{
                                    print(response.result.value!)
                                    WebSerivceManager.HandleResponse(apicallMethod: url, apiResponse: response, successHandler: { (isSuccess, BaseModel, error) in
                                        if let successBlock = success {
                                            successBlock(isSuccess, BaseModel, error)
                                        }
                                    })
                                }
                                break
                                
                            case .failure(_):
                                print(response.result.error!)
                                //Run on main thread
                                DispatchQueue.main.async {
                                    AppUtils.hideLoader()
                                }
                                break
                            }
                        }
                    }else {
                        //Run on main thread
                        DispatchQueue.main.async {
                            AppUtils.hideLoader()
                        }
                        
                        if let successBlock = success {
                            successBlock(false, nil, response.result.error)
                        }
                    }
                }else{
                    if let successBlock = success {
                        successBlock(false, nil, response.result.error)
                    }
                }
                break
            }
        }
    }
    
    //GET method
    class func GETRequest(url:Web_Service, showLoader : Bool, success:((Bool,WebServiceReponse?, Error?) -> Void)?)
    {
        if(showLoader) {
            AppUtils.showLoader()
        }
        print(HeaderClass.objHeaderClass.HeaderDictionary!)
        
        Alamofire.request(mainUrl + url.rawValue, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: HeaderClass.objHeaderClass.HeaderDictionary).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    print(response.result.value!)
                    WebSerivceManager.HandleResponse(apicallMethod: url, apiResponse: response, successHandler: { (isSuccess, BaseModel, error) in
                        if let successBlock = success {
                            successBlock(isSuccess, BaseModel, error)
                        }
                    })
                }
                break
                
            case .failure(_):
                AppUtils.hideLoader()
                if let successBlock = success {
                    successBlock(false, nil, response.result.error)
                }
                print(response.result.error!)
                break
                
            }
        }
    }
    
    //POST Multipart
    class func POSTMultipartRequest(url : Web_Service, parameterDitionary: [String : String]? , parameterwithImage : [String : String]?, success:((Bool,WebServiceReponse?, Error?) -> Void)?) {
        
        AppUtils.showLoader()
        print(HeaderClass.objHeaderClass.HeaderDictionary!)
        print("Parameter\(parameterDitionary!)")
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            for (key, value) in parameterDitionary! {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
            //image append
            for (key, value) in parameterwithImage! {
                multipartFormData.append(NSURL(string:(value)) as URL!, withName: key)
            }
            
        }, to: mainUrl + url.rawValue, headers: HeaderClass.objHeaderClass.HeaderDictionary)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    //self.delegate?.showSuccessAlert()
                    print(response.request!)  // original URL request
                    print(response.response!) // URL response
                    print(response.data!)     // server data
                    print(response.result)   // result of response serialization
                    
                    WebSerivceManager.HandleResponse(apicallMethod: url, apiResponse: response, successHandler: { (isSuccess, BaseModel, error) in
                        if let successBlock = success {
                            successBlock(isSuccess, BaseModel, error)
                        }
                    })
                }
                
            case .failure(let error):
                AppUtils.hideLoader()
                print(result)
                if let successBlock = success {
                    successBlock(false, nil, error)
                }
                break
            }
        }
    }
    
    //Success Response Handle
    class func HandleResponse (apicallMethod: Web_Service, apiResponse : DataResponse<Any>, successHandler: ((Bool,WebServiceReponse?, Error?)->Void)) {
        
        AppUtils.hideLoader()
        if let JSON = apiResponse.result.value {
            //print("JSON: \(JSON)")
            
            let mapper = Mapper<WebServiceReponse>()
            let dataObject : WebServiceReponse = mapper.map(JSON: JSON as! [String : Any])!
            
            //successHandler(true, dataObject, nil)
            //If block added by MeHuLa on 18 May 2017
            if dataObject.success == true {
                successHandler(true, dataObject, nil)
            }else {
                successHandler(false, dataObject, nil)
            }
        }else {
            successHandler(false, nil, apiResponse.result.error)
        }
    }
    
    
    
    
    
    //MARK: - Google Autocomplete Adderss
    func getGooglePlace(showLoader: Bool, isForCityOnly: Bool, strSearchText:String, success:@escaping (Array<Any>) -> Void, failed:@escaping (String) -> Void) {
        
        //        https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=YOUR_API_KEY
        
        
        let urlwithPercentEscapes = strSearchText.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        //              https://maps.googleapis.com/maps/api/place/queryautocomplete/json?key=YOUR_API_KEY&language=fr&input=pizza+near%20par
        
        //Run on main thread
        DispatchQueue.main.async {
            AppUtils.showLoader()
        }
        
        var url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(urlwithPercentEscapes!)&key=\(Constants.kGoogle_Places_API)"
        
        //If creteria depends on CITY
        if isForCityOnly == true {
            url = url + "&types=(cities)"
        }
        
        print("----------------------\n\n\n\nURL: \(url)")
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            //Run on main thread
            DispatchQueue.main.async {
                AppUtils.hideLoader()
            }
            
            switch(response.result) {
                
            case .success(_):
                print("Response: \(response.result.value as Any!)")
                
                var dict = JSON(response.result.value ?? "").dictionaryValue
                
                if(dict["status"] == "OK") {
                    success((dict["predictions"]?.array)!)
                }else {
                    failed("The network connection was lost please try again.")
                }
                
                break
                
            case .failure(_):
                print("Response: \(response.result.error as Any!)")
                failed("The network connection was lost please try again.")
                break
                
            }
        }
    }
    
    
    //MARK: - Get LAt Long from Address
    func getLotLongFromAddress(showLoader: Bool, strPlace:String, success:@escaping (Array<Any>) -> Void, failed:@escaping (String) -> Void) {
        
        let urlwithPercentEscapes = strPlace.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        //Run on main thread
        DispatchQueue.main.async {
            AppUtils.showLoader()
        }
        
        let url = "https://maps.googleapis.com/maps/api/geocode/json?address=\(urlwithPercentEscapes!)&key=\(Constants.kGoogle_Places_API)"
        
        print("----------------------\n\n\n\nURL: \(url)")
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            //Run on main thread
            DispatchQueue.main.async {
                AppUtils.hideLoader()
            }
            
            switch(response.result) {
                
            case .success(_):
                print("Response: \(response.result.value as Any!)")
                
                var dict = JSON(response.result.value ?? "").dictionaryValue
                if(dict["status"] == "OK") {
                    success((dict["results"]?.array)!)
                }else {
                    success([[]])
                }
                break
                
            case .failure(_):
                print("Response: \(response.result.error as Any!)")
                failed("The network connection was lost please try again.")
                break
                
            }
        }
    }
    
    
    //MARK: - Get Address from Lat Long
    func getAddressFromLotLong(showLoader: Bool, strLatitude: String, strLongitude: String, success:@escaping (Array<Any>) -> Void, failed:@escaping (String) -> Void) {
        
        let strLocation = "\(strLatitude),\(strLongitude)"
        
        //Run on main thread
        DispatchQueue.main.async {
            AppUtils.showLoader()
        }
        
        let url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(strLocation)&sensor=true&key=\(Constants.kGoogle_Places_API)"
        
        print("----------------------\n\n\n\nURL: \(url)")
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            //Run on main thread
            DispatchQueue.main.async {
                AppUtils.hideLoader()
            }
            
            switch(response.result) {
                
            case .success(_):
                print("Response: \(response.result.value as Any!)")
                
                var dict = JSON(response.result.value ?? "").dictionaryValue
                if(dict["status"] == "OK") {
                    success((dict["results"]?.array)!)
                }else {
                    success([[]])
                }
                break
                
            case .failure(_):
                print("Response: \(response.result.error as Any!)")
                failed("The network connection was lost please try again.")
                break
                
            }
        }
    }
}

extension String {
    func EncodingText() -> NSData {
        return self.data(using: String.Encoding.utf8, allowLossyConversion: false)! as NSData
    }
}