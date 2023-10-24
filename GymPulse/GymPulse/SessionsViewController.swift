import UIKit
import CalendarKit

class SessionsViewController: UIViewController, DayViewDelegate, EventDataSource {
    
    private var calendarView: DayView!
    private var sessions: [Event] = []
    private var fetchedSchedules: [[String: Any]] = []
    private var userEmail: String?
    private var isUserClient: Bool = true

    var clientID: String?
    
    let baseURL = Bundle.main.infoDictionary?["BASE_URL"] as? String

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        promptUserType()
        setupRefreshButton()
    }

    func setupRefreshButton() {
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshCalendar))
        navigationItem.rightBarButtonItem = refreshButton
    }

    func setupUI() {
        calendarView = DayView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.backgroundColor = .darkGray
        view.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func promptUserType() {
        let alert = UIAlertController(title: "Are you a client or trainer?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Client", style: .default, handler: { _ in
            self.isUserClient = true
            self.promptEmail(isClient: true)
        }))
        alert.addAction(UIAlertAction(title: "Trainer", style: .default, handler: { _ in
            self.isUserClient = false
            self.promptEmail(isClient: false)
        }))
        present(alert, animated: true)
    }

    func promptEmail(isClient: Bool) {
        let alert = UIAlertController(title: "Enter Email", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            if let email = alert.textFields?.first?.text {
                self.userEmail = email
                self.isUserClient = isClient
                self.fetchID(email: email, isClient: isClient) { fetchedID in
                    // Refresh the calendar with the fetched ID
                    if let fetchedID = fetchedID {
                        self.fetchScheduleID(id: fetchedID, isClient: isClient)
                    } else {
                        // Handle the error if the ID is not fetched
                        self.showErrorAlert(message: "Failed to fetch ID. Please try again.")
                    }
                }
            }
        }))
        present(alert, animated: true)
    }

    @objc func refreshCalendar() {
        guard let email = userEmail else {
            showAlertWith(message: "Please enter your email first.")
            return
        }
        
        let alert = UIAlertController(title: "Refresh Calendar", message: "Do you want to use the current email (\(email)) or re-enter a new one?", preferredStyle: .alert)
        
        // Use current email
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            if let existingID = self.clientID {
                // Use the existing ID to fetch the schedule
                self.fetchScheduleID(id: existingID, isClient: self.isUserClient)
            } else {
                // Fetch the ID again
                self.fetchID(email: email, isClient: self.isUserClient) { fetchedID in
                    if self.isUserClient {
                        self.clientID = fetchedID
                    }
                    // Refresh the calendar with the fetched ID
                    if let fetchedID = fetchedID {
                        self.fetchScheduleID(id: fetchedID, isClient: self.isUserClient)
                    } else {
                        // Handle the error if the ID is not fetched
                        self.showErrorAlert(message: "Failed to fetch ID. Please try again.")
                    }
                }
            }
        }))
        
        // Re-enter email
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
            self.promptUserType()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    func showAlertWith(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Add an action to re-enter email
        alert.addAction(UIAlertAction(title: "Re-enter Email", style: .default, handler: { _ in
            self.promptUserType()
        }))
        
        present(alert, animated: true, completion: nil)
    }

    
    func fetchID(email: String, isClient: Bool, completion: @escaping (String?) -> Void) {
        sessions.removeAll() // Clear the sessions array
        print("Starting fetchID function with email: \(email) and isClient: \(isClient)")

        guard let unwrappedBaseURL = baseURL else {
            print("Error fetching baseURL")
            completion(nil)
            return
        }
        let endpoint = isClient ? "get_client_id.php" : "get_trainer_id.php"
        guard let url = URL(string: unwrappedBaseURL + endpoint + "?email=\(email)") else {
            print("Error constructing URL with email: \(email)")
            completion(nil)
            return
        }
        print("Constructed URL: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Network error occurred: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Network error: \(error.localizedDescription)")
                }
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("Failed to receive data from server.")
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Failed to receive data from server.")
                }
                completion(nil)
                return
            }
            print("Received data from server: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Parsed JSON: \(json)")
                    if let idInt = json[isClient ? "client_id" : "trainer_id"] as? Int {
                        let id = String(idInt)
                        print("Successfully fetched ID: \(id)")
                        DispatchQueue.main.async {
                            completion(id)
                        }
                    } else {
                        print("Failed to fetch ID from JSON response.")
                        DispatchQueue.main.async {
                            self.showErrorAlert(message: "Failed to fetch ID. Please try again.")
                            completion(nil)
                        }
                    }
                } else {
                    print("Failed to parse server response into JSON.")
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Failed to parse server response.")
                        completion(nil)
                    }
                }
            } catch {
                print("Error processing server response: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Error processing server response.")
                    completion(nil)
                }
            }
        }.resume()
    }

    func fetchScheduleID(id: String, isClient: Bool) {
        fetchedSchedules.removeAll() // Clear the fetchedSchedules array
        guard let unwrappedBaseURL = baseURL else {
            print("Error fetching baseURL")
            return
        }
        let endpoint = "get_schedules_by_id.php"
        guard let url = URL(string: unwrappedBaseURL + endpoint + "?\(isClient ? "client_id" : "trainer_id")=\(id)") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Failed to receive data from server.")
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let schedules = json["schedules"] as? [[String: Any]] {
                    self.fetchedSchedules = schedules
                    DispatchQueue.main.async {
                        for schedule in schedules {
                            if let scheduleID = schedule["schedule_id"] as? Int {
                                self.fetchSessions(scheduleID: String(scheduleID))
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Failed to parse server response.")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Error processing server response.")
                }
            }
        }.resume()
    }

    func fetchSessions(scheduleID: String) {
        guard let unwrappedBaseURL = baseURL else {
            print("Error fetching baseURL")
            return
        }
        guard let url = URL(string: unwrappedBaseURL + "get_sessions_by_id.php?schedule_id=\(scheduleID)") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Failed to receive data from server.")
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let sessionArray = json["sessions"] as? [[String: Any]] {
                    for session in sessionArray {
                        if let schedule = self.fetchedSchedules.first(where: { ($0["schedule_id"] as? Int) == (session["schedule_id"] as? Int) }) {
                            let start = self.ConversionFunction(dateString: schedule["session_date"] as? String, timeString: schedule["start_time"] as? String)
                            let end = self.ConversionFunction(dateString: schedule["session_date"] as? String, timeString: schedule["end_time"] as? String)
                            
                            let event = Event()

                            if let startDate = start, let endDate = end {
                                event.dateInterval = DateInterval(start: startDate, end: endDate)
                            }

                            if let workoutType = session["workout_type"] as? String,
                               let durationMinutes = session["duration_minutes"] as? Int {
                                event.text = "Workout Type: \(workoutType) Minutes: \(durationMinutes)"
                            }

                            self.sessions.append(event)
                        }
                    }
                    DispatchQueue.main.async {
                        self.calendarView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Failed to parse server response.")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Error processing server response.")
                }
            }
        }.resume()
    }

    func ConversionFunction(dateString: String?, timeString: String?) -> Date? {
        guard let dateStr = dateString, let timeStr = timeString else { return nil }

        let dateTimeStr = "\(dateStr) \(timeStr)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        
        return dateFormatter.date(from: dateTimeStr)
    }
    
    func promptForTrainerEmail(completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Enter Trainer's Email", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Trainer's Email"
            textField.keyboardType = .emailAddress
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            if let email = alert.textFields?.first?.text, !email.isEmpty {
                completion(email)
            } else {
                // Show an error and retry the prompt if the email is empty
                self.showAlertWith(message: "Please enter a valid email.") {
                    self.promptForTrainerEmail(completion: completion)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    func promptForClientEmail(completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Enter Client's Email", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Client's Email"
            textField.keyboardType = .emailAddress
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            if let email = alert.textFields?.first?.text, !email.isEmpty {
                completion(email)
            } else {
                // Show an error and retry the prompt if the email is empty
                self.showAlertWith(message: "Please enter a valid email.") {
                    self.promptForClientEmail(completion: completion)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    func showAlertWith(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func addSessionAt(date: Date) {
        print("Adding session at date: \(date)")

        // Check if the user is a client or trainer
        if isUserClient {
            // If client, ask for trainer's email
            promptForTrainerEmail { trainerEmail in
                self.fetchID(email: trainerEmail, isClient: false) { fetchedTrainerID in
                    guard let trainerID = fetchedTrainerID else {
                        self.showErrorAlert(message: "Failed to fetch trainer ID. Please try again.")
                        return
                    }
                    self.addSchedule(clientID: self.clientID!, trainerID: trainerID, date: date)
                }
            }
        } else {
            // If trainer, fetch trainerID and locationID
            guard let userEmail = userEmail else {
                self.showErrorAlert(message: "User email not set.")
                return
            }
            
            fetchID(email: userEmail, isClient: false) { fetchedTrainerID in
                guard let trainerID = fetchedTrainerID else {
                    self.showErrorAlert(message: "Failed to fetch trainer ID. Please try again.")
                    return
                }
                
                self.fetchLocationID(trainerID: trainerID) { locationID in
                    guard let locationID = locationID else {
                        self.showErrorAlert(message: "Failed to fetch location ID. Please try again.")
                        return
                    }
                    
                    // Ask for client's email
                    self.promptForClientEmail { clientEmail in
                        self.fetchID(email: clientEmail, isClient: true) { fetchedClientID in
                            guard let clientID = fetchedClientID else {
                                self.showErrorAlert(message: "Failed to fetch client ID. Please try again.")
                                return
                            }
                            self.addSchedule(clientID: clientID, trainerID: trainerID, date: date, locationID: locationID)
                        }
                    }
                }
            }
        }
    }

    func fetchLocationID(trainerID: String, completion: @escaping (String?) -> Void) {
        print("Starting fetchLocationID function with trainerID: \(trainerID)")
        
        guard let baseURL = self.baseURL, let url = URL(string: baseURL + "get_location_id.php?trainer_id=\(trainerID)") else {
            print("Error: Failed to construct the URL with baseURL: \(String(describing: self.baseURL)) and trainerID: \(trainerID)")
            completion(nil)
            return
        }
        
        print("Constructed URL: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Failed to receive data from server.")
                }
                return
            }
            
            print("Received data from server: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let locationIDInt = jsonResponse["location_id"] as? Int {
                    let locationID = String(locationIDInt)
                    print("Successfully parsed location_id from JSON response: \(locationID)")
                    DispatchQueue.main.async {
                        completion(locationID)
                    }
                } else if let errorResponse = jsonResponse["error"] as? String {
                    print("Error from server: \(errorResponse)")
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Failed to fetch location ID. Please ensure the trainer has a valid location set.")
                        completion(nil)
                    }
                } else {
                    print("Error: Unable to parse location_id from JSON response.")
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Failed to fetch location ID. Please ensure the trainer has a valid location set.")
                        completion(nil)
                    }
                }
            } else {
                print("Error: Failed to deserialize JSON response.")
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Error processing server response.")
                    completion(nil)
                }
            }
        }.resume()
    }

    
    func addSchedule(clientID: String, trainerID: String, date: Date, locationID: String? = nil) {
        // Convert the date to the desired format and split it into date and time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let sessionDate = dateFormatter.string(from: date).split(separator: " ")[0]
        let startTime = dateFormatter.string(from: date).split(separator: " ")[1]
        
        // Assuming a default session length of 1 hour for now
        let endDate = date.addingTimeInterval(3600)
        let endTime = dateFormatter.string(from: endDate).split(separator: " ")[1]

        // Create the POST request payload
        var payload: [String: Any] = [
            "trainer_id": trainerID,  // Change this
            "client_id": clientID,    // Change this
            "session_date": sessionDate,
            "start_time": startTime,
            "end_time": endTime
        ]
        if let locationID = locationID {
            payload["location_id"] = locationID
        }

        print("Payload to be sent: \(payload)") // Print the payload

        // Make the POST request to add_schedule.php
        guard let baseURL = self.baseURL, let url = URL(string: baseURL + "add_schedule.php") else {
            print("Error constructing URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Network error: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Failed to receive data from server.")
                }
                return
            }

            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Server response: \(jsonResponse)") // Print the server response

                DispatchQueue.main.async {
                    if let status = jsonResponse["status"] as? String, status == "success",
                       let scheduleID = jsonResponse["schedule_id"] as? String {
                        // Prompt the user for workout_type and duration_minutes
                        self.promptForSessionDetails(scheduleID: scheduleID)
                    } else {
                        self.showErrorAlert(message: jsonResponse["message"] as? String ?? "Unknown error occurred while adding schedule.")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Unknown error occurred while adding schedule.")
                }
            }
        }.resume()
    }

    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    func promptForSessionDetails(scheduleID: String) {
        let alert = UIAlertController(title: "Add Training Session", message: "Enter workout type and duration in minutes", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Workout Type"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Duration (minutes)"
            textField.keyboardType = .numberPad
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            if let workoutType = alert.textFields?[0].text, !workoutType.isEmpty,
               let durationString = alert.textFields?[1].text, let duration = Int(durationString) {
                
                self.addTrainingSession(scheduleID: scheduleID, workoutType: workoutType, duration: duration)
            } else {
                self.showAlertWith(message: "Please enter valid details.")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    func addTrainingSession(scheduleID: String, workoutType: String, duration: Int) {
        // Create the POST request payload
        let payload: [String: Any] = [
            "schedule_id": scheduleID,
            "workout_type": workoutType,
            "duration_minutes": duration
        ]

        // Make the POST request to add_training_session.php
        guard let baseURL = self.baseURL, let url = URL(string: baseURL + "add_training_session.php") else {
            print("Error constructing URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Network error: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Failed to receive data from server.")
                }
                return
            }

            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                DispatchQueue.main.async {
                    if let status = jsonResponse["status"] as? String, status == "success" {
                        let successAlert = UIAlertController(title: "Success", message: "Training session added successfully!", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(successAlert, animated: true, completion: nil)
                    } else {
                        self.showErrorAlert(message: jsonResponse["message"] as? String ?? "Unknown error occurred while adding training session.")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Unknown error occurred while adding training session.")
                }
            }
        }.resume()
    }

    
    func eventsForDate(_ date: Date) -> [EventDescriptor] {
        return sessions.filter { Calendar.current.isDate($0.dateInterval.start, inSameDayAs: date) }
    }

    func dayViewDidSelectEventView(_ eventView: EventView) {
        print("Selected event: \(String(describing: eventView.descriptor))")
    }

    func dayViewDidLongPressEventView(_ eventView: EventView) {
        print("Long pressed event: \(String(describing: eventView.descriptor))")
    }

    func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        addSessionAt(date: date)
    }

    func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        print("Long pressed on timeline at date: \(date)")
    }

    func dayViewDidBeginDragging(dayView: DayView) {
        print("Began dragging day view")
    }

    func dayViewDidTransitionCancel(dayView: DayView) {
        print("Cancelled day view transition")
    }

    func dayView(dayView: DayView, willMoveTo date: Date) {
        print("Day view will move to date: \(date)")
    }

    func dayView(dayView: DayView, didMoveTo date: Date) {
        print("Day view did move to date: \(date)")
    }

    func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        print("Updated event: \(event)")
    }
}
