import UIKit

final class RemindersTableViewCell: UITableViewCell {

    private static var pickerHeight: Int = 200

    static let remindersViewCellReuseIdentifier = "RemindersViewCell"

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailsTextField: UITextField!

    private var pickerView: UIPickerView?
    private var pickerValues: [String]?

    var reminderType: ReminderType?
    var reminderService: ReminderService?

    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = UIColor.darkSkinColor
        detailsTextField.textColor = UIColor.darkSkinColor
        pickerView = UIPickerView()
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

        return pickerValues?[row]
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {

        detailsTextField.text = pickerValues?[row]
        updateReminder(row)
        contentView.endEditing(true)
    }

    func initPicker(_ pickerValues: [String]?, _ selectedRow: Int) {
        self.pickerValues = pickerValues
        detailsTextField.text = pickerValues?[selectedRow]

        pickerView?.frame =
            CGRect(x: 0, y: 0, width: 0, height: RemindersTableViewCell.pickerHeight)
        pickerView?.delegate = self
        pickerView?.dataSource = self
        pickerView?.backgroundColor = UIColor.white
        pickerView?.selectRow(selectedRow, inComponent: 0, animated:false)
    }

    private func updateReminder(_ selectedPickerRow: Int) {
        guard let reminderType = reminderType else {
            assertionFailure("Failed to get reminder type")
            return
        }
        reminderService?.setReminderTime(reminderType, selectedPickerRow)
    }
}
