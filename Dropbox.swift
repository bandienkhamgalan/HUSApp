/**
	Dropbox.swift

	This class as used as a singleton in Lung Ops. A single instance of Dropbox runs independently, and monitors the Core Data object model for changes. When a change event fires, all operations are compiled and exported, on a separate thread, to a single Excel document in the application folder of the user's Dropbox.
 */

import Foundation

class Dropbox
{
	enum OperationUpdateMode // used in calls between class functions
	{
		case Create
		case Update
		case Delete
	}

	// Dropbox Sync API
	var dbFileSystem: DBFilesystem?
	{
		if DBFilesystem.sharedFilesystem() == nil
		{
			DBFilesystem.setSharedFilesystem(DBFilesystem(account: DBAccountManager.sharedManager().linkedAccount))
		}
		return DBFilesystem.sharedFilesystem()
	}
	
	// Core Data
	var managedObjectContext: NSManagedObjectContext?
	
	var serialThread: dispatch_queue_t	// serial thread for data processing & networking
	var XMLExcelHeaderRow = [String]()	// convenience constant
	
	/* Designated initializer */
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
	
	/*	objectChanged is set to execute when the system posts NSManagedObjectContextObjectsDidChangeNotification.
		It simply commences data processing & exporting on a separate thread. */
	@objc func objectChanged(notification: NSNotification)
	{
		dispatch_async(serialThread, { self.saveAllOperations() } )
	}
	
	/*	saveAllOperations compiles, formats and writes Operation data onto user's Dropbox */
	func saveAllOperations()
	{
		// Fetch all Operation entities, sorted in reverse chronological order
		var fetchRequest = NSFetchRequest(entityName: "Operation")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
	
		if let operations = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Operation]
		{
			var rows = [[String]]()
			rows.append(XMLExcelHeaderRow)
			
			// Format Operation entity data into Excel XML spreadsheet
			for operation in operations
			{
				rows.append(createOperationRow(operation))
			}
			
			// Delete existing file on Dropbox
			var dbpath:DBPath = DBPath.root().childPath("All Operations.xls")
			if self.dbFileSystem?.fileInfoForPath(dbpath, error: nil) != nil
			{
				self.dbFileSystem?.deletePath(dbpath, error: nil)
			}
			
			// Save file to Dropbox
			var newFile = self.dbFileSystem?.createFile(dbpath, error: nil)
			if newFile != nil
			{
				newFile!.writeString(XMLDataToXMLExcelString(rows), error: nil)
				newFile!.close()
			}
		}
	}
	
	/*	createOperationRow takes an Operation entity as a parameter and formats the data for exporting to Excel XML format. 
		It returns an array (of XML data strings), with each element representing one cell. */
	func createOperationRow(operation:Operation) -> [String]
	{
		var cells = [String]()
		
		cells.append(createCell(operation.patient.patientID, text: true))
		cells.append(createCell(operation.patient.ageString(), text: false))
		cells.append(createCell(operation.patient.genderString(), text: true))
		cells.append(createCell(operation.dateString(), text: true))
		cells.append(createCell(operation.approachString(), text: true))
		
		// prepare contents of Resection cell (comma delimited list)
		var first = true
		var resections = ""
		if (operation.resectionsArray().count > 0){
			for obj in operation.resectionsArray() {
				var resection = obj as! String
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
		
		// prepare contents of Admitted to ICU cell (yes/no)
		if (operation.admittedToICU == 1) {
			cells.append(createCell("Yes", text: true))
		}
		else {
			cells.append(createCell("No", text: true))
		}
		
		cells.append(createCell("\(operation.durationOfStay)", text: false))
		
		// prepare contents of Complications cell (comma delimited list)
		first = true
		var complications = ""
		if (operation.complicationsArray().count > 0){
			for obj in operation.complicationsArray() {
				var complication = obj as! String
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
		
		// prepare contents of Alive status cell (yes/no with optional date)
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
	
	/*	createOperationRow takes a string as a parameter, and returns a string holding Excel XML for a cell that contains the text. */

	func createCell(value:String, text:Bool) -> String
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
	
	/*	XMLDataToXMLExcelString takes a structured array of arrays of Strings (each holding Excel XML data for one cell) as a parameter and encloses it within proper header and footer data, returning a complete, valid String representation of an Excel spreadsheet file. */
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
	
}