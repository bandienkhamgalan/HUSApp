//
//  Dropbox.swift
//  HUSApp
//
//  Created by Yong Lin Ong on 13/3/15.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import Foundation

class Dropbox {
    
    var dbFileSystem:DBFilesystem?
    
    init(){
        var dbFileSystem = DBFilesystem.sharedFilesystem()
        if (dbFileSystem == nil){
            DBFilesystem.setSharedFilesystem(DBFilesystem(account: DBAccountManager.sharedManager().linkedAccount))
        }
        self.dbFileSystem  = DBFilesystem.sharedFilesystem()
    }
    
    // Move to new folder and delete old folder if Patient's name change
    func updateFolderinDropbox(oldPatientID:String, newPatientID:String){
        if oldPatientID != newPatientID {
            var oldPath:DBPath = DBPath.root().childPath("/" + oldPatientID)
            var newPath:DBPath = DBPath.root().childPath("/" + newPatientID)
            self.dbFileSystem?.movePath(oldPath, toPath: newPath, error: nil)
            self.dbFileSystem?.deletePath(oldPath, error: nil)
        } 
    }
    
    func createFolder(patientName:String){
        var path:String = "/" + patientName
        var dbpath:DBPath = DBPath.root().childPath(path)
        self.dbFileSystem!.createFolder(dbpath, error: nil)
    }
    
    func deleteFolder(patientName:String){
        var path:String = "/" + patientName
        var dbpath:DBPath = DBPath.root().childPath(path)
        self.dbFileSystem?.deletePath(dbpath, error: nil)
    }
    
    // Create or Delete .xls files
    func exportToDropbox(operation:Operation, patient:Patient, create:Bool){
        deleteFile(patient.patientID, fileName: operation.dateString())
        if create {
            createFile(patient.patientID, fileName: operation.dateString(), patient: patient, operation: operation)
        }
    }

    func deleteFile(patientName:String, fileName:String){
        var path:String =  "/" + patientName + "/" + fileName + ".xls"
        var dbpath:DBPath = DBPath.root().childPath(path)
        if self.dbFileSystem?.fileInfoForPath(dbpath, error: nil) != nil {
            self.dbFileSystem?.deletePath(dbpath, error: nil)
        }
    }
    
    func createFile(patientName:String, fileName:String, patient:Patient, operation:Operation){
        
        var path:String =  "/" + patientName + "/" + fileName + ".xls"
        var dbpath:DBPath = DBPath.root().childPath(path)
        
        var header = "<?xml version=\"1.0\"?>\n<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\"\nxmlns:o=\"urn:schemas-microsoft-com:office:office\"\nxmlns:x=\"urn:schemas-microsoft-com:office:excel\"\nxmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\"\nxmlns:html=\"http://www.w3.org/TR/REC-html40\">\n<Styles>\n<Style ss:ID=\"left\"><Alignment ss:Horizontal=\"Left\"/></Style></Styles>\n<Worksheet ss:Name=\"Sheet1\">\n<Table ss:ExpandedColumnCount=\""
        
        var columncount = "\"ss:ExpandedRowCount=\""
        var rowcount = "\" x:FullColumns=\"1\"x:FullRows=\"1\">\n"
        
        var footer = "</Table>\n</Worksheet>\n</Workbook>"
        
        var totalRow = 12 + operation.resectionsArray().count + operation.complicationsArray().count
        var xlsstring = header + "2" + columncount + "\(totalRow)" + rowcount
        
        xlsstring += createRow("Patient ID", value: patient.patientID, text: true)
        xlsstring += createRow("Age", value: patient.ageString(), text: false)
        
        xlsstring += createRow("Date of Operation", value: operation.dateString(), text: true)
        xlsstring += createRow("Type of Approach", value: operation.approachString(), text: true)
        
        var first = true
        if (operation.resectionsArray().count > 0){
            for obj in operation.resectionsArray() {
                var resection = obj as String
                if first {
                    xlsstring += createRow("Type of Resection", value: resection, text: true)
                    first = false
                } else {
                    xlsstring += createRow("", value: resection, text: true)
                    
                }
            }
        }
        
        xlsstring += createRow("Duration of Operation", value: operation.durationString(), text: true)
        xlsstring += createRow("FEV1", value: "\(operation.fev1)", text: false)
        xlsstring += createRow("DLCO", value: "\(operation.dlco)", text: false)
        xlsstring += createRow("Blood Loss / mL", value: "\(operation.bloodLoss)", text: false)
        
        if (operation.admittedToICU == 1){
            xlsstring += createRow("Admission to ICU", value: "Yes", text: true)
        }
        else {
            xlsstring += createRow("Admission to ICU", value: "No", text: true)
        }
        xlsstring += createRow("Total Time in Hospital / days", value: "\(operation.durationOfStay)", text: false)
        
        first = true
        if (operation.complicationsArray().count > 0){
            for obj in operation.complicationsArray() {
                var complications = obj as String
                if first {
                    xlsstring += createRow("Complications during Hospital Stay", value: complications, text: true)
                    first = false
                } else {
                    xlsstring += createRow("", value: complications, text: true)
                }
            }
        }
        if (operation.alive == 1) {
            xlsstring += createRow("Follow-up Date", value: operation.followUpDateString(), text: true)
            xlsstring += createRow("Death Date", value: "NA", text: true)
        }
        if (operation.alive == 0) {
            xlsstring += createRow("Follow-up Date", value: "NA", text: true)
            xlsstring += createRow("Death Date", value: operation.dateString(), text: true)
        }
        
        xlsstring += footer

        if self.dbFileSystem != nil{
            var newFile = self.dbFileSystem!.createFile(dbpath, error: nil)
            if newFile != nil {
                newFile.writeString(xlsstring, error: nil)
                newFile.close()
            }
        }
        
        
    }
    
    func createRow(label:String, value:String, text:BooleanType) -> String{
        
        var rowStart = "<Row>\n"
        var rowEnde = "\n</Row>\n"
        var stringStart = "<Cell ss:StyleID=\"left\"><Data ss:Type=\"Number\">"
        
        if text {
            stringStart = "<Cell><Data ss:Type=\"String\">"
        }
       
        var stringEnde = "</Data></Cell>"
        
        var numberStart = "<Cell><Data ss:Type=\"String\">"
        var numberEnde = "</Data></Cell>"
        
        return rowStart + numberStart + label + numberEnde + stringStart + value + stringEnde + rowEnde
    }
    
}