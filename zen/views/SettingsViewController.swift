import UIKit

final class SettingsViewController: UIViewController {

    private static let initialReminderPickerRowKey = "initial_reminder_time"
    private static let constantReminderPickerRowKey = "constant_reminder_time"
    private static let finalReminderPickerRowKey = "finalc_reminder_time"

    @IBOutlet weak var remindersTableView: UITableView!
    @IBOutlet var remindersTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var remindersLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "settings_screen_title".localized
        remindersLabel.text = "settings_screen_reminders_title".localized
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dismissKeyboard (_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        remindersTableView.register(
            UINib(nibName: "RemindersTableViewCell", bundle: nil),
            forCellReuseIdentifier: RemindersTableViewCell.remindersViewCellReuseIdentifier)

        remindersTableView.backgroundColor = UIColor.clear
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
        remindersTableViewHeightConstraint.constant = remindersTableView.contentSize.height
    }

    @objc private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

extension SettingsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RemindersTableViewCell.remindersViewCellReuseIdentifier)
            as? RemindersTableViewCell else {
            assertionFailure("Failed to get reminders cell")
            return UITableViewCell()
        }
        
        cell.notificationService = notificationService
        cell.storageService = storageService

        switch indexPath.row {
        case ReminderType.initial.rawValue:
            let pickerSelectedRow =
                storageService.object(forKey: SettingsViewController.initialReminderPickerRowKey)
                    as? Int ?? ReminderUtils.initialReminderPickerValues.count - 1
            cell.title = "settings_screen_initial_reminder".localized
            cell.initPicker(ReminderUtils.initialReminderPickerValues, pickerSelectedRow)
            cell.reminderType = .initial
            cell.selectedPickerRowKey = SettingsViewController.initialReminderPickerRowKey
        case ReminderType.constant.rawValue:
            let pickerSelectedRow = storageService.object(
                forKey: SettingsViewController.constantReminderPickerRowKey) as? Int ?? 1
            cell.title = "settings_screen_constant_reminder".localized
            cell.initPicker(ReminderUtils.constantReminderPickerValues, pickerSelectedRow)
            cell.reminderType = .constant
            cell.selectedPickerRowKey = SettingsViewController.constantReminderPickerRowKey
        case ReminderType.final.rawValue:
            let pickerSelectedRow =
                storageService.object(forKey: SettingsViewController.finalReminderPickerRowKey)
                    as? Int ?? ReminderUtils.finalReminderPickerValues.count - 1
            cell.title = "settings_screen_final_reminder".localized
            cell.initPicker(ReminderUtils.finalReminderPickerValues, pickerSelectedRow)
            cell.reminderType = .final
            cell.selectedPickerRowKey = SettingsViewController.finalReminderPickerRowKey
        default:
            assertionFailure("No reminders cell for this row")
        }
        return cell
    }
}
