import UIKit

final class SettingsViewController: UIViewController {

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
        
        cell.reminderService = reminderService

        guard let reminderType = ReminderType(rawValue: indexPath.row) else {
            assertionFailure("Failed to get reminder type for cell")
            return cell
        }
        let pickerSelectedRow = reminderService.reminderTimeIndex(reminderType)
        cell.reminderType = reminderType

        switch reminderType {
        case .initial:
            cell.title = "settings_screen_initial_reminder".localized
            cell.initPicker(ReminderUtils.initialReminderPickerValues, pickerSelectedRow)
        case .constant:
            cell.title = "settings_screen_constant_reminder".localized
            cell.initPicker(ReminderUtils.constantReminderPickerValues, pickerSelectedRow)
        case .final:
            cell.title = "settings_screen_final_reminder".localized
            cell.initPicker(ReminderUtils.finalReminderPickerValues, pickerSelectedRow)
        }
        return cell
    }
}
