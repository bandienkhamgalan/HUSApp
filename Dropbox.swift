//
//  Dropbox.swift
//  HUSApp
//
//  Created by Yong Lin Ong on 13/3/15.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import Foundation

class Dropbox {
    
    var dbFileSystem:DBFilesystem
    
    init(){
        var dbFileSystem = DBFilesystem.sharedFilesystem()
        if (dbFileSystem == nil){
            DBFilesystem.setSharedFilesystem(DBFilesystem(account: DBAccountManager.sharedManager().linkedAccount))
        }
        self.dbFileSystem  = DBFilesystem.sharedFilesystem()
    }
    
    // Move to new folder and delete old folder if Patient's name change
    func updateFolderinDropbox(oldPatientName:String, newPatientName:String){
        if oldPatientName != newPatientName {
            var oldPath:DBPath = DBPath.root().childPath("/" + oldPatientName)
            var newPath:DBPath = DBPath.root().childPath("/" + newPatientName)
            self.dbFileSystem.movePath(oldPath, toPath: newPath, error: nil)
            self.dbFileSystem.deletePath(oldPath, error: nil)
        } 
    }
    
    func createFolder(patientName:String){
        var path:String = "/" + patientName
        var dbpath:DBPath = DBPath.root().childPath(path)
        self.dbFileSystem.createFolder(dbpath, error: nil)
    }
    
    func deleteFolder(patientName:String){
        var path:String = "/" + patientName
        var dbpath:DBPath = DBPath.root().childPath(path)
        self.dbFileSystem.deletePath(dbpath, error: nil)
    }
    
    // Create or Delete .xls files
    func exportToDropbox(operation:Operation, patient:Patient, create:Bool){
        deleteFile(patient.name, fileName: operation.dateString())
        if create {
            createFile(patient.name, fileName: operation.dateString(), patient: patient, operation: operation)
        }
    }

    func deleteFile(patientName:String, fileName:String){
        var path:String =  "/" + patientName + "/" + fileName + ".xls"
        var dbpath:DBPath = DBPath.root().childPath(path)
        if self.dbFileSystem.fileInfoForPath(dbpath, error: nil) != nil {
            self.dbFileSystem.deletePath(dbpath, error: nil)
        }
    }
    
    func createFile(patientName:String, fileName:String, patient:Patient, operation:Operation){
        
        var path:String =  "/" + patientName + "/" + fileName + ".xls"
        var dbpath:DBPath = DBPath.root().childPath(path)
        
        var header = "<?xml version=\"1.0\"?>\n<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\"\nxmlns:o=\"urn:schemas-microsoft-com:office:office\"\nxmlns:x=\"urn:schemas-microsoft-com:office:excel\"\nxmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\"\nxmlns:html=\"http://www.w3.org/TR/REC-html40\">\n<Worksheet ss:Name=\"Sheet1\">\n<Table ss:ExpandedColumnCount=\""
        
        var columncount = "\"ss:ExpandedRowCount=\""
        var rowcount = "\" x:FullColumns=\"1\"x:FullRows=\"1\">\n"
        
        var footer = "</Table>\n</Worksheet>\n</Workbook>"
        
        var totalRow = 11 + operation.resectionsArray().count + operation.complicationsArray().count
        var xlsstring = header + "2" + columncount + "\(totalRow)" + rowcount
        
        xlsstring += createRow("Name", value:patient.name)
        xlsstring += createRow("Patient ID", value: patient.patientID)
        xlsstring += createRow("Age", value: patient.ageString())
        
        xlsstring += createRow("Date of Operation", value: operation.dateString())
        xlsstring += createRow("Type of Approach", value: operation.approachString())
        
        var first = true
        if (operation.resectionsArray().count > 0){
            for obj in operation.resectionsArray() {
                var resection = obj as String
                if first {
                    xlsstring += createRow("Type of Resection", value: resection)
                    first = false
                } else {
                    xlsstring += createRow("", value: resection)
                    
                }
            }
        }
        
        xlsstring += createRow("Duration of Operation", value: operation.durationString())
        xlsstring += createRow("Blood Loss / mL", value: "\(operation.bloodLoss)")
        
        if (operation.admittedToICU == 1){
            xlsstring += createRow("Admission to ICU", value: "Yes")
        }
        else {
            xlsstring += createRow("Admission to ICU", value: "No")
        }
        xlsstring += createRow("Total Time in Hospital / days", value: "\(operation.durationOfStay)")
        
        first = true
        if (operation.complicationsArray().count > 0){
            for obj in operation.complicationsArray() {
                var complications = obj as String
                if first {
                    xlsstring += createRow("Complications during Hospital Stay", value: complications)
                    first = false
                } else {
                    xlsstring += createRow("", value: complications)
                }
            }
        }
        if (operation.alive == 1) {
            xlsstring += createRow("Follow-up Date", value: operation.followUpDateString())
            xlsstring += createRow("Death Date", value: "NA")
        }
        if (operation.alive == 0) {
            xlsstring += createRow("Follow-up Date", value: "NA")
            xlsstring += createRow("Death Date", value: operation.dateString())
        }
        
        xlsstring += footer
        
        var newFile = self.dbFileSystem.createFile(dbpath, error: nil)
        if newFile != nil {
            newFile.writeString(xlsstring, error: nil)
            newFile.close()
        }
        
    }
    
    func createRow(label:String, value:String) -> String{
        
        var rowStart = "<Row>\n"
        var rowEnde = "\n</Row>\n"
        
        var stringStart = "<Cell><Data ss:Type=\"String\">"
        var stringEnde = "</Data></Cell>"
        
        var numberStart = "<Cell><Data ss:Type=\"String\">"
        var numberEnde = "</Data></Cell>"
        
        return rowStart + numberStart + label + numberEnde + stringStart + value + stringEnde + rowEnde
    }
    
}