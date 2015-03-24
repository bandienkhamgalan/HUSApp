//
//  Dropbox.swift
//  HUSApp
//
//  Created by Yong Lin Ong on 13/3/15.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import Foundation

class Dropbox {
    
	var dbFileSystem: DBFilesystem?
	{
		if DBFilesystem.sharedFilesystem() == nil
		{
			DBFilesystem.setSharedFilesystem(DBFilesystem(account: DBAccountManager.sharedManager().linkedAccount))
		}
		return DBFilesystem.sharedFilesystem()
	}
	
	var serialThread: dispatch_queue_t
	
	init()
	{
		serialThread = dispatch_queue_create("LungOpsDropbox", nil)
	}
    
    // Move to new folder and delete old folder if Patient's name change
    func updateFolderinDropbox(oldPatientID:String, newPatientID:String)
	{
        if oldPatientID != newPatientID
		{
            var oldPath:DBPath = DBPath.root().childPath("/" + oldPatientID)
            var newPath:DBPath = DBPath.root().childPath("/" + newPatientID)
			dispatch_async(serialThread)
			{
				self.dbFileSystem?.movePath(oldPath, toPath: newPath, error: nil)
				self.dbFileSystem?.deletePath(oldPath, error: nil)
			}
        }
    }
    
    func createFolder(patientID:String)
	{
        var path:String = "/" + patientID
        var dbpath:DBPath = DBPath.root().childPath(path)
		dispatch_async(serialThread)
		{
			self.dbFileSystem?.createFolder(dbpath, error: nil)
			return
		}
    }
    
    func deleteFolder(patientID:String){
        var path:String = "/" + patientID
        var dbpath:DBPath = DBPath.root().childPath(path)
		
		dispatch_async(serialThread)
		{
			if self.dbFileSystem?.fileInfoForPath(dbpath, error: nil) != nil
			{
				self.dbFileSystem?.deletePath(dbpath, error: nil)
			}
		}
    }
    
    // Create or Delete .xls files
    func exportToDropbox(operation:Operation, patient:Patient, create:Bool)
	{
		dispatch_async(serialThread)
		{
			self.deleteFile(patient.patientID, fileName: operation.dateString())
			if create
			{
				self.createFile(patient.patientID, fileName: operation.dateString(), patient: patient, operation: operation)
			}
		}
    }

    func deleteFile(patientID:String, fileName:String)
	{
        var path:String =  "/" + patientID + "/" + fileName + ".xls"
        var dbpath:DBPath = DBPath.root().childPath(path)
		dispatch_async(serialThread)
		{
			if self.dbFileSystem?.fileInfoForPath(dbpath, error: nil) != nil {
				self.dbFileSystem?.deletePath(dbpath, error: nil)
			}
		}
    }
    
    func createFile(patientID:String, fileName:String, patient:Patient, operation:Operation)
	{
        
        var path:String =  "/" + patientID + "/" + fileName + ".xls"
        var dbpath:DBPath = DBPath.root().childPath(path)
        
        var header = "<?xml version=\"1.0\"?>\n<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\"\nxmlns:o=\"urn:schemas-microsoft-com:office:office\"\nxmlns:x=\"urn:schemas-microsoft-com:office:excel\"\nxmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\"\nxmlns:html=\"http://www.w3.org/TR/REC-html40\">\n<Styles>\n<Style ss:ID=\"center\"><Alignment ss:Horizontal=\"CenterAcrossSelection\"/></Style></Styles>\n<Worksheet ss:Name=\"Sheet1\">\n<Table ss:ExpandedColumnCount=\""
        
        var columncount = "\"ss:ExpandedRowCount=\""
        var rowcount = "\" x:FullColumns=\"1\"x:FullRows=\"1\">\n"
        
        var footer = "</Table>\n</Worksheet>\n</Workbook>"
        
        var rowStart = "<Row>\n"
        var rowEnde = "\n</Row>\n"
        var xlsstring = header + "15" + columncount + "2" + rowcount
        
        xlsstring += rowStart
        xlsstring += createCell("Patient ID", text: true)
        xlsstring += createCell("Age", text: true)
        xlsstring += createCell("Gender", text: true)
        xlsstring += createCell("Date of Operation", text: true)
        xlsstring += createCell("Type of Approach", text: true)
        xlsstring += createCell("Type of Resection", text: true)
        xlsstring += createCell("Duration of Operation", text: true)
        xlsstring += createCell("FEV1", text: true)
        xlsstring += createCell("DLCO", text: true)
        xlsstring += createCell("Blood Loss / mL", text: true)
        xlsstring += createCell("Admission to ICU", text: true)
        xlsstring += createCell("Total Time in Hospital / days", text: true)
        xlsstring += createCell("Complications during Hospital Stay", text: true)
        xlsstring += createCell("Follow-up Date", text: true)
        xlsstring += createCell("Death Date", text: true)
        xlsstring += rowEnde
        
        xlsstring += rowStart
        xlsstring += createCell(patient.patientID, text: true)
        xlsstring += createCell(patient.ageString(), text: false)
        xlsstring += createCell(patient.genderString(), text: true)
        xlsstring += createCell(operation.dateString(), text: true)
        xlsstring += createCell(operation.approachString(), text: true)
        
        var first = true
        var resections = ""
        if (operation.resectionsArray().count > 0){
            for obj in operation.resectionsArray() {
                var resection = obj as String
                if first {
                    resections += resection
                    first = false
                } else {
                    resections += ", "
                    resections += resection
                    
                }
            }
        }
        
        xlsstring += createCell(resections, text: true)
        xlsstring += createCell("\(operation.duration)", text: false)
        xlsstring += createCell("\(operation.fev1)", text: false)
        xlsstring += createCell("\(operation.dlco)", text: false)
        xlsstring += createCell("\(operation.bloodLoss)", text: false)
        if (operation.admittedToICU == 1){
            xlsstring += createCell("Yes", text: true)
        }
        else {
            xlsstring += createCell("No", text: true)
        }
        xlsstring += createCell("\(operation.durationOfStay)", text: false)
        
        first = true
        var complications = ""
        if (operation.complicationsArray().count > 0){
            for obj in operation.complicationsArray() {
                var complication = obj as String
                if first {
                    complications += complication
                    first = false
                } else {
                    complications += ", "
                    complications += complication
                }
            }
        }
        xlsstring += createCell(complications, text: true)
        
        if (operation.alive == 1) {
            xlsstring += createCell(operation.followUpDateString(), text: true)
            xlsstring += createCell("NA", text: true)
        }
        if (operation.alive == 0) {
            xlsstring += createCell("NA", text: true)
            xlsstring += createCell(operation.deathDateString(), text: true)
        }
        
        xlsstring += rowEnde

        xlsstring += footer

		dispatch_async(serialThread)
		{
			var newFile = self.dbFileSystem?.createFile(dbpath, error: nil)
			if newFile != nil
			{
				newFile!.writeString(xlsstring, error: nil)
				newFile!.close()
			}
		}
    }
    
    func createCell(value:String, text:BooleanType) -> String
	{
        
        var stringStart = "<Cell ss:StyleID=\"center\"><Data ss:Type=\"Number\">"
        
        if text {
            stringStart = "<Cell ss:StyleID=\"center\"><Data ss:Type=\"String\">"
        }
       
        var stringEnde = "</Data></Cell>"
        
        var numberStart = "<Cell><Data ss:Type=\"String\">"
        var numberEnde = "</Data></Cell>"
        
        return stringStart + value + stringEnde
    }
    
}