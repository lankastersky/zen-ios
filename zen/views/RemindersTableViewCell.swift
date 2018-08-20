import UIKit

final class RemindersTableViewCell: UITableViewCell {

    private static var pickerHeight: Int = 200

    static let remindersViewCellReuseIdentifier = "RemindersViewCell"

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailsTextField: UITextField!

    private var pickerView = UIPickerView()
    private var pickerValues: [String]?
    private var reminderType: ReminderType?
    private lazy var reminderService = ReminderService()

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.textColor = UIColor.darkSkinColor
        detailsTextField.textColor = UIColor.darkSkinColor

        pickerView.frame = CGRect(x: 0, y: 0, width: 0, height: RemindersTableViewCell.pickerHeight)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            detailsTextField.becomeFirstResponder()
        }
    }

    @IBAction func onTextEditingDidBegin(_ sender: UITextField) {
        sender.inputView = pickerView
    }

    func setReminderType(_ reminderType: ReminderType) {
        self.reminderType = reminderType
        switch reminderType {
        case .initial:
            titleLabel.text = "settings_screen_initial_reminder".localized
            pickerValues = ReminderUtils.initialReminderPickerValues
        case .constant:
            titleLabel.text = "settings_screen_constant_reminder".localized
            pickerValues = ReminderUtils.constantReminderPickerValues
        case .final:
            titleLabel.text = "settings_screen_final_reminder".localized
            pickerValues = ReminderUtils.finalReminderPickerValues
        }
        let pickerSelectedRow = reminderService.reminderTimeIndex(reminderType)
        detailsTextField.text = pickerValues?[pickerSelectedRow].localized
        pickerView.selectRow(pickerSelectedRow, inComponent: 0, animated:false)
    }

    private func updateReminder(_ selectedPickerRow: Int) {
        guard let reminderType = reminderType else {
            assertionFailure("Failed to get reminder type")
            return
        }
        reminderService.setReminderTime(reminderType, selectedPickerRow)
    }
}

extension RemindersTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerValues?.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {

        return pickerValues?[row].localized
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {

        detailsTextField.text = pickerValues?[row].localized
        updateReminder(row)
        contentView.endEditing(true)
    }
}
