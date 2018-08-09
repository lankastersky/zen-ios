import MessageUI
import UIKit

/// Shows help screen
final class HelpViewController: UIViewController {

    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var versionLabel: UILabel!
    @IBOutlet private var sendFeedbackButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "help_screen_title".localized
        sendFeedbackButton.setTitle("help_screen_send_feedback".localized, for: .normal)
        sendFeedbackButton.setTitleColor(UIColor.darkSkinColor, for: .normal)
        descriptionLabel.text = "help_screen_description".localized
        versionLabel.text =
            String.localizedStringWithFormat("help_screen_version".localized, Utils.versionNumber)
        versionLabel.textColor = UIColor.disabledSkinColor
    }

    @IBAction private func sendFeedback(sender: UIButton!) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["lankastersky@gmail.com"])
            let subject =
                "\(Utils.appName) iOS feedback \(Utils.versionNumber) (\(Utils.buildNumber))"
            mail.setSubject(subject)
            mail.setMessageBody("", isHTML: true)

            present(mail, animated: true)
        } else {
            print("Failed to send email")
            let alert = UIAlertController(title: "help_screen_send_feedback_alert_title".localized,
                                          message: "help_screen_send_feedback_alert_text".localized,
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        }
    }
}

extension HelpViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)

        if let error = error {
            print("Failed to compose email:\(error)")
        }
    }
}
