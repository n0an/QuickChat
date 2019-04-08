//
//  Constants.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 08/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase


var firebase = FIRDatabase.database().reference()
let userDefaults = UserDefaults.standard

//IDS and Keys
public let kONESIGNALAPPID = "25da1a96-0b0a-45b3-b612-e2673aa3011b"
public let kSINCHKEY = "31839caa-60c3-4387-9a3f-b88b47c1242c"
public let kSINCHSECRET = "rE4trPWmd0i8Vb1CZD5N1A=="

//FUser
public let kOBJECTID = "objectId"
public let kUSER = "User"
public let kCREATEDAT = "createdAt"
public let kUPDATEDAT = "updatedAt"
public let kEMAIL = "email"
public let kFACEBOOK = "facebook"
public let kLOGINMETHOD = "loginMethod"
public let kPUSHID = "pushId"
public let kFIRSTNAME = "firstname"
public let kLASTNAME = "lastname"
public let kFULLNAME = "fullname"
public let kAVATAR = "avatar"
public let kCURRENTUSER = "currentUser"

//typeing
public let kTYPINGPATH = "Typing"

//
public let kAVATARSTATE = "avatarState"
public let kFILEREFERENCE = "gs://quickchat20.appspot.com"
public let kFIRSTRUN = "firstRun"
public let kNUMBEROFMESSAGES = 40
public let kMAXDURATION = 5.0
public let kAUDIOMAXDURATION = 10.0
public let kSUCCESS = 2

//recent
public let kRECENT = "Recent"
public let kCHATROOMID = "chatRoomID"
public let kUSERID = "userId"
public let kDATE = "date"
public let kPRIVATE = "private"
public let kGROUP = "group"
public let kGROUPID = "groupId"
public let kRECENTID = "recentId"
public let kMEMBERS = "members"
public let kDISCRIPTION = "discription"
public let kLASTMESSAGE = "lastMessage"
public let kCOUNTER = "counter"
public let kTYPE = "type"
public let kWITHUSERUSERNAME = "withUserUserName"
public let kWITHUSERUSERID = "withUserUserID"
public let kOWNERID = "ownerID"
public let kSTATUS = "status"
public let kMESSAGE = "Message"
public let kMESSAGEID = "messageId"
public let kNAME = "name"
public let kSENDERID = "senderId"
public let kSENDERNAME = "senderName"
public let kTHUMBNAIL = "thumbnail"

//Friends
public let kFRIEND = "friends"
public let kFRIENDID = "friendId"

//message types
public let kPICTURE = "picture"
public let kTEXT = "text"
public let kVIDEO = "video"
public let kAUDIO = "audio"
public let kLOCATION = "location"

//coordinates
public let kLATITUDE = "latitude"
public let kLONGITUDE = "longitude"


//message status
public let kDELIVERED = "Delivered"
public let kREAD = "Read"

//push
public let kDEVICEID = "deviceId"



//backgroung color
public let kRED = "red"
public let kGREEN = "green"
public let kBLUE = "blue"


