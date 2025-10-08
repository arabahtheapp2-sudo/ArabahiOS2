//
//  RaiseTicketTVC.swift
//  ARABAH
//
//  Created by cqlios on 21/10/24.
//

import UIKit

class RaiseTicketTVC: UITableViewCell {
    
    // MARK: - OUTLETS
    
    /// Label to display the date when the ticket was created
    @IBOutlet var lblDate: UILabel!
    
    /// Main container view for the cell's UI elements
    @IBOutlet var viewMain: UIView!
    
    /// Label to display the description/details of the ticket
    @IBOutlet var lblDescription: UILabel!
    
    /// Label to display the ticket title or subject
    @IBOutlet weak var ticketLbl: UILabel!
    
    // MARK: - CELL REUSE HANDLING
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset all UI elements to prevent old data being shown
        lblDate.text = nil
        lblDescription.text = nil
        ticketLbl.text = nil
        
    }
    
    // MARK: - VARIABLES
    
    /// Property to hold the ticket data model for this cell
    /// Updates UI elements whenever a new ticket data is set
    var ticketListing: GetTicketModalBody? {
        didSet {
            // Set the description text from the model or empty string if nil
            lblDescription.text = ticketListing?.description ?? ""
            
            // Date formatter for parsing and formatting date strings
            let formato = DateFormatter()
            
            // Original date format as received from the API (UTC time zone)
            formato.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let utcTimeZone = TimeZone(identifier: "UTC") {
                formato.timeZone = utcTimeZone
            } else {
                // Failed to create UTC timezone
                formato.timeZone = TimeZone.current // fallback
            }
            formato.formatterBehavior = .default
            
            // Parse the createdAt string into a Date object
            if let createdAt = ticketListing?.createdAt, let date = formato.date(from: createdAt) {
                
                // Change formatter to local timezone and desired display format
                formato.timeZone = TimeZone.current
                formato.dateFormat = "dd/MM/yyyy"
                
                // Set the formatted date string to the label
                lblDate.text = formato.string(from: date)
            } else {
                // If date parsing fails, clear the label
                lblDate.text = ""
            }
            
            // Set the ticket title or fallback to empty string
            ticketLbl.text = ticketListing?.title ?? ""
            
            // Example placeholder if needed:
            // cell.ticketLbl.text = "Ticket \(indexPath.row+1)"
        }
    }
}
