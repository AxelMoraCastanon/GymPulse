import UIKit
import CalendarKit

class SessionsViewController: UIViewController, DayViewDelegate, EventDataSource {
    
    private var calendarView: DayView!
    private var sessions: [Event] = []
    private var fetchedSchedules: [[String: Any]] = []
    private var userEmail: String?
    private var isUserClient: Bool = true

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
            self.promptEmail(isClient: true)
        }))
        alert.addAction(UIAlertAction(title: "Trainer", style: .default, handler: { _ in
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
                self.fetchID(email: email, isClient: isClient)
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
            self.fetchID(email: email, isClient: self.isUserClient)
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

    
    func fetchID(email: String, isClient: Bool) {
        sessions.removeAll() // Clear the sessions array

        guard let unwrappedBaseURL = baseURL else {
            print("Error fetching baseURL")
            return
        }
        let endpoint = isClient ? "get_client_id.php" : "get_trainer_id.php"
        guard let url = URL(string: unwrappedBaseURL + endpoint + "?email=\(email)") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let idInt = json[isClient ? "client_id" : "trainer_id"] as? Int {
                        let id = String(idInt)
                        self.fetchScheduleID(id: id, isClient: isClient)
                    }
                }
            } catch {}
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
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let schedules = json["schedules"] as? [[String: Any]] {
                        self.fetchedSchedules = schedules
                        for schedule in schedules {
                            if let scheduleID = schedule["schedule_id"] as? Int {
                                self.fetchSessions(scheduleID: String(scheduleID))
                            }
                        }
                    }
                }
            } catch {}
        }.resume()
    }

    func fetchSessions(scheduleID: String) {
        guard let unwrappedBaseURL = baseURL else {
            print("Error fetching baseURL")
            return
        }
        guard let url = URL(string: unwrappedBaseURL + "get_sessions_by_id.php?schedule_id=\(scheduleID)") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
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
                }
            } catch {}
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
        print("Tapped on timeline at date: \(date)")
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
