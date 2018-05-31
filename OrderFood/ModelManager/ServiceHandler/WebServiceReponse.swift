//
//  WebserviceRootModel.swift
//  controlcast
//
//  Created by Hiren Gujarati on 16/02/17.
//  Copyright © 2017 Openxcell Game. All rights reserved.
//

import UIKit
import ObjectMapper

class WebServiceReponse : Mappable {
    
    internal var status : Int?
    internal var message : String?
    internal var data: AnyObject?
    internal var key : String?
    internal var success : Bool?
    internal var isMore : Bool?
    internal var formattedData: AnyObject?
    internal var iCastID : String?
    internal var total   : String?
    internal var totalApprov   : String = "0"
    internal var totalPending  : String = "0"
   
    
    init() {
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    class var mapperObj : Mapper<WebServiceReponse>  {
        let mapper : Mapper = Mapper<WebServiceReponse>()
        return mapper
    }
    
    func mapping(map: Map) {
        status <- map["STATUS"]
        message <- map["MESSAGE"]
        data <- map["DATA"]
        key <- map["key"]
        
        //iCastID
        iCastID <- map["iCastID"]
        
        //total
        total <- map["total"]
        totalApprov  <- map["totalApprov"]
        totalPending <- map["totalPending"]
        

        do {
            if try map.value("SUCCESS") == 1 {
                success = true
            }else {
                success = false
            }
        }catch {
            success = false
        }
        
        
        do {
            if try map.value("isMore") == 1 {
                isMore = true
            }else {
                isMore = false
            }
        }catch {
            isMore = false
        }
    }
}