//
//  Dropbox.swift
//  Lung Ops
//
//  Created by Yong Lin Ong on 13/3/15.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import Foundation

class Dropbox
{
	enum OperationUpdateMode
	{
		case Create
		case Update
		case Delete
	}
	
	enum OperationMode
	{
		case IndividualFiles
		case OneDocument
	}
	
	var dbFileSystem: DBFilesystem?
	{
		if DBFilesystem.sharedFilesystem() == nil
		{
			DBFilesystem.setSharedFilesystem(DBFilesystem(account: DBAccountManager.sharedManager().linkedAccount))
		}
		return DBFilesystem.sharedFilesystem()
	}
    
	var operationMode = OperationMode.OneDocument
	
	var serialThread: dispatch_queue_t
	var managedObjectContext: NSManagedObjectContext?
	var XMLExcelHeaderRow = [String]()
	
	@objc func objectChanged(notification: NSNotification)
	{
		if operationMode == .OneDocument
		{
			dispatch_async(serialThread, { self.saveAllOperations() } )
		}
		else if operationMode == .IndividualFiles
		{
			if let insertedObjects = notification.userInfo![NSInsertedObjectsKey as String] as? NSSet
			{
				for object in insertedObjects
				{
					if object.entity == NSEntityDescription.entityForName("Patient", inManagedObjectContext:managedObjectContext!)
					{
						dispatch_async(serialThread, { self.createPatientFolder((object as Patient).patientID) })
					}
					if object.entity == NSEntityDescription.entityForName("Operation", inManagedObjectContext:managedObjectContext!)
					{
						dispatch_async(serialThread, { self.updateOperationFile(object as Operation, mode: .Create) })
					}
				}
			}
			
			if let deletedObjects = notification.userInfo![NSDeletedObjectsKey as String] as? NSSet
			{
				for object in deletedObjects
				{
					if object.entity == NSEntityDescription.entityForName("Patient", inManagedObjectContext:managedObjectContext!)
					{
						dispatch_async(serialThread, { self.deletePatientFolder((object as Patient).patientID) })
					}
					if object.entity == NSEntityDescription.entityForName("Operation", inManagedObjectContext:managedObjectContext!)
					{
						dispatch_async(serialThread, { self.updateOperationFile(object as Operation, mode: .Delete) })
					}
				}
			}
			
			if let updatedObjects = notification.userInfo![NSUpdatedObjectsKey as String] as? NSSet
			{
				for object in updatedObjects
				{
					if object.entity == NSEntityDescription.entityForName("Patient", inManagedObjectContext:managedObjectContext!)
					{
						var patient = (object as Patient)
						if let oldPatientID = patient.changedValuesForCurrentEvent()["patientID"] as? String
						{
							dispatch_async(serialThread, { self.updatePatientFolder(oldPatientID, newPatientID: patient.patientID) })
						}
					}
					if object.entity == NSEntityDescription.entityForName("Operation", inManagedObjectContext:managedObjectContext!)
					{
						dispatch_async(serialThread, { self.updateOperationFile(object as Operation, mode: .Update) })
					}
				}
			}
		}
	}
	
	init(managedObjectContext: NSManagedObjectContext)
	{
		serialThread = dispatch_queue_create("LungOpsDropbox", nil)
		self.managedObjectContext = managedObjectContext
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "objectChanged:", name: NSManagedObjectContextObjectsDidChangeNotification, object: managedObjectContext)
		
		XMLExcelHeaderRow.append(createCell("Patient ID", text: true))
		XMLExcelHeaderRow.append(createCell("Age", text: true))
		XMLExcelHeaderRow.append(createCell("Gender", text: true))
		XMLExcelHeaderRow.append(createCell("Date of Operation", text: true))
		XMLExcelHeaderRow.append(createCell("Type of Approach", text: true))
		XMLExcelHeaderRow.append(createCell("Type of Resection", text: true))
		XMLExcelHeaderRow.append(createCell("Duration / minutes", text: true))
		XMLExcelHeaderRow.append(createCell("FEV1", text: true))
		XMLExcelHeaderRow.append(createCell("DLCO", text: true))
		XMLExcelHeaderRow.append(createCell("Blood Loss / mL", text: true))
		XMLExcelHeaderRow.append(createCell("Admission to ICU", text: true))
		XMLExcelHeaderRow.append(createCell("Hospital Stay / days", text: true))
		XMLExcelHeaderRow.append(createCell("Complications", text: true))
		XMLExcelHeaderRow.append(createCell("Follow-up Date", text: true))
		XMLExcelHeaderRow.append(createCell("Death Date", text: true))
	}
	
    // Move to new folder and delete old folder if Patient's name change
    func updatePatientFolder(oldPatientID:String, newPatientID:String)
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
	
	func saveAllOperations()
	{
		var startDate = NSDate() // <<<< testing
		
		var fetchRequest = NSFetchRequest(entityName: "Operation")

		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
		var generatedDate = NSDate() // <<<< testing
		if let operations = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Operation]
		{
			var rows = [[String]]()
			rows.append(XMLExcelHeaderRow)
			for operation in operations
			{
				rows.append(createOperationRow(operation))
			}
			
			var dbpath:DBPath = DBPath.root().childPath("All Operations.xls")
			if self.dbFileSystem?.fileInfoForPath(dbpath, error: nil) != nil
			{
				self.dbFileSystem?.deletePath(dbpath, error: nil)
			}
			generatedDate = NSDate() // <<<< testing
			var newFile = self.dbFileSystem?.createFile(dbpath, error: nil)
			if newFile != nil
			{
				newFile!.writeString(XMLDataToXMLExcelString(rows), error: nil)
				newFile!.close()
			}
		}
		var endDate = NSDate() // <<<< testing
		var executionTime = endDate.timeIntervalSinceDate(startDate) // <<<< testing
		var generationTime = generatedDate.timeIntervalSinceDate(startDate) // <<<< testing
		println("executed in \(executionTime) seconds (\(generationTime)) for generating .xls XML and \(executionTime - generationTime) for uploading)") // <<<< testing
	}
    
    func createPatientFolder(patientID:String)
	{
        var path:String = "/" + patientID
        var dbpath:DBPath = DBPath.root().childPath(path)
		self.dbFileSystem?.createFolder(dbpath, error: nil)
    }
    
    func deletePatientFolder(patientID:String)
	{
        var path:String = "/" + patientID
        var dbpath:DBPath = DBPath.root().childPath(path)
		
		if self.dbFileSystem?.fileInfoForPath(dbpath, error: nil) != nil
		{
			self.dbFileSystem?.deletePath(dbpath, error: nil)
		}
    }
    
    // Create or Delete .xls files
	func updateOperationFile(operation:Operation, mode:OperationUpdateMode)
	{
		self.deleteOperationFile(operation)
		if mode == .Create || mode == .Update
		{
			self.createOperationFile(operation)
		}
    }

	func deleteOperationFile(operation:Operation)
	{
        var path:String =  "/" + operation.patient.patientID + "/" + operation.dateString() + ".xls"
        var dbpath:DBPath = DBPath.root().childPath(path)

		if self.dbFileSystem?.fileInfoForPath(dbpath, error: nil) != nil {
			self.dbFileSystem?.deletePath(dbpath, error: nil)
		}
    }
	
	func XMLDataToXMLExcelString(data:[[String]]) -> String
	{
		if data.count > 0 && data[0].count > 0
		{
			var header = "<?xml version=\"1.0\"?>\n<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\"\nxmlns:o=\"urn:schemas-microsoft-com:office:office\"\nxmlns:x=\"urn:schemas-microsoft-com:office:excel\"\nxmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\"\nxmlns:html=\"http://www.w3.org/TR/REC-html40\">\n<Styles>\n<Style ss:ID=\"center\"><Alignment ss:Horizontal=\"CenterAcrossSelection\"/></Style></Styles>\n<Worksheet ss:Name=\"Sheet1\">\n<Table ss:ExpandedColumnCount=\""
			var columncount = "\"ss:ExpandedRowCount=\""
			var rowcount = "\" x:FullColumns=\"1\"x:FullRows=\"1\">\n"
			var footer = "</Table>\n</Worksheet>\n</Workbook>"
			var rowStart = "<Row>\n"
			var rowEnde = "\n</Row>\n"
			
			var xlsstring = header + String(data[0].count) + columncount + String(data.count) + rowcount
			for row:[String] in data
			{
				xlsstring += rowStart
				for cell:String in row
				{
					xlsstring += cell
				}
				xlsstring += rowEnde
			}
			
			xlsstring += footer
			
			return xlsstring
		}
		return ""
	}
	
	func createOperationRow(operation:Operation) -> [String]
	{
		var cells = [String]()
		
		cells.append(createCell(operation.patient.patientID, text: true))
		cells.append(createCell(operation.patient.ageString(), text: false))
		cells.append(createCell(operation.patient.genderString(), text: true))
		cells.append(createCell(operation.dateString(), text: true))
		cells.append(createCell(operation.approachString(), text: true))
		
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
		
		cells.append(createCell(resections, text: true))
		cells.append(createCell("\(operation.duration)", text: false))
		cells.append(createCell("\(operation.fev1)", text: false))
		cells.append(createCell("\(operation.dlco)", text: false))
		cells.append(createCell("\(operation.bloodLoss)", text: false))
		if (operation.admittedToICU == 1){
			cells.append(createCell("Yes", text: true))
		}
		else {
			cells.append(createCell("No", text: true))
		}
		cells.append(createCell("\(operation.durationOfStay)", text: false))
		
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
		cells.append(createCell(complications, text: true))
		
		if (operation.alive == 1) {
			cells.append(createCell(operation.followUpDateString(), text: true))
			cells.append(createCell("NA", text: true))
		}
		if (operation.alive == 0) {
			cells.append(createCell("NA", text: true))
			cells.append(createCell(operation.deathDateString(), text: true))
		}
		
		return cells
	}
	
    func createOperationFile(operation:Operation)
	{
		var xlstring = XMLDataToXMLExcelString([XMLExcelHeaderRow, createOperationRow(operation)])
		
		var path:String =  "/" + operation.patient.patientID + "/" + operation.dateString() + ".xls"
		var dbpath:DBPath = DBPath.root().childPath(path)

		var newFile = self.dbFileSystem?.createFile(dbpath, error: nil)
		if newFile != nil
		{
			newFile!.writeString(xlstring, error: nil)
			newFile!.close()
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