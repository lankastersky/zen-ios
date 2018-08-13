import UIKit

/// Shows current challenge
final class ChallengeViewController: UIViewController {

    static let challengeViewControllerStoryboardId = "ChallengeViewController"

    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var contentLabel: UILabel!
    @IBOutlet weak private var detailsLabel: UILabel!
    @IBOutlet weak private var quoteLabel: UILabel!
    @IBOutlet weak private var sourceButton: UIButton!
    @IBOutlet weak private var typeLabel: UILabel!
    @IBOutlet weak private var levelLabel: UILabel!
    @IBOutlet weak private var footerHolderView: UIView!
    // Making contraints strong, otherwise they will be removed after deactivating
    @IBOutlet private var typeLabelToSourceButtonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private var typeLabelToQuoteLabelLayoutConstraint: NSLayoutConstraint!

    private var activeFooterView: ChallengeFooterView?
    private var sourceUrl: String?

    var challenge: Challenge?

    override func viewDidLoad() {
        super.viewDidLoad()

        if challenge == nil {
            navigationItem.title = "current_challenge_screen_title".localized
        } else {
            navigationItem.title = "challenge_screen_title".localized
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: .UIApplicationWillEnterForeground, object: nil)

        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dismissKeyboard (_:)))
        view.addGestureRecognizer(tapGesture)

        // Avoid tap event delay when setting the rating. See https://goo.gl/XWBdyn
        scrollView.delaysContentTouches = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        registerKeyboardNotifications()

        if let challenge = self.challenge {
            showChallengeFromJournal(challenge)
        } else {
            loadChallenges()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        typeLabelToSourceButtonLayoutConstraint.isActive = !sourceButton.isHidden
        typeLabelToQuoteLabelLayoutConstraint.isActive = sourceButton.isHidden

        contentView.layoutIfNeeded()
    }

    @objc private func willEnterForeground() {
        if self.challenge == nil {
            loadChallenges()
        }
    }

    @IBAction private func onSourceButton(sender: UIButton!) {
        guard let urlString = sourceUrl else {
            assertionFailure("Failed to get challenge url")
            return
        }
        ChallengeViewController.openUrl(urlString)
    }

    private func loadChallenges() {
        LoadingIndicatorView.show("Loading")

        let firebaseService = FirebaseService(storageService, challengesService)
        firebaseService.signIn(callback: { [weak self] _, error in
            if let error = error {
                print("Failed to authenticate in Firebase: \(error)")
            } else {
                firebaseService.loadChallenges(callback: { error in
                    LoadingIndicatorView.hide()
                    if let error = error {
                        print("Failed to download challenges:\(error)")
                        let alert = Utils.buildAlert(
                            "challenge_screen_error_downloading_challenges_title".localized,
                            "challenge_screen_error_downloading_challenges_message".localized)
                        self?.present(alert, animated: true, completion: nil)

                    } else {
                        self?.showCurrentChallenge()
                    }
                })
            }
        })
    }

    private func showCurrentChallenge() {
        guard let challenge = challengesService.currentChallenge else {
            assertionFailure("Failed to get current challenge")
            return
        }
        showChallengeHeader(challenge)
        switch challenge.status {
        case nil:
            challengesService.markChallengeShown(challenge.challengeId)
            if challengesService.isTimeToAcceptChallenge {
                showShownChallengeFooterView(challenge)
            } else {
                showChallengeStatusFooterView(
                    challenge, "challenge_screen_button_accept_before_6pm".localized)
            }
        case .shown?:
            showShownChallengeFooterView(challenge)
        case .accepted?:
            if !challengesService.isTimeToFinishChallenge {
                showChallengeStatusFooterView(
                    challenge, "challenge_screen_button_return_after_6pm".localized)
            } else {
                showFinishingChallengeFooterView(challenge)
            }
        case .finished?:
            showFinishedChallengeFooterView(challenge)
        case .declined?:
            assertionFailure("Bad challenge status while showing current challenge")
        }
    }

    private func showChallengeFromJournal(_ challenge: Challenge) {
        showChallengeHeader(challenge)
        showFinishedChallengeFooterView(challenge)
    }

    private func showChallengeHeader(_ challenge: Challenge) {
        contentLabel.text = challenge.content
        detailsLabel.text = challenge.details
        quoteLabel.text = challenge.quote
        typeLabel.text = "\("Type".localized): \(challenge.type)"
        typeLabel.textColor = UIColor.darkSkinColor
        levelLabel.text =
        "\("challenge_screen_difficulty".localized): \(challenge.level.description)"
        levelLabel.textColor = UIColor.darkSkinColor
        if !challenge.source.isEmpty {
            sourceButton.isHidden = false
            sourceButton.setTitle(challenge.source, for: .normal)
            sourceUrl = challenge.url
        } else {
            sourceButton.isHidden = true
            sourceUrl = nil
        }
    }

    private func showShownChallengeFooterView(_ challenge: Challenge) {
        let view: ShownChallengeFooterView = ShownChallengeFooterView.fromNib()
        showFooterView(view, challenge)
    }

    private func showChallengeStatusFooterView(_ challenge: Challenge, _ message: String) {
        let view: ChallengeStatusFooterView = ChallengeStatusFooterView.fromNib()
        view.statusText = message
        showFooterView(view, challenge)
    }

    private func showFinishingChallengeFooterView(_ challenge: Challenge) {
        let view: FinishingChallengeFooterView = FinishingChallengeFooterView.fromNib()
        showFooterView(view, challenge)
    }

    private func showFinishedChallengeFooterView(_ challenge: Challenge) {
        let view: FinishedChallengeFooterView = FinishedChallengeFooterView.fromNib()
        view.commentsText = challenge.comments ?? ""
        view.rating = challenge.rating ?? 0
        showFooterView(view, challenge)
    }

    private func showFooterView(_ footerView: ChallengeFooterView, _ challenge: Challenge) {
        activeFooterView?.removeFromSuperview()
        activeFooterView = footerView

        footerHolderView.addSubview(footerView)

        footerView.challenge = challenge
        footerView.challengeFooterViewDelegate = self

        footerView.translatesAutoresizingMaskIntoConstraints = false

        let margins = footerHolderView.layoutMarginsGuide
        footerView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        footerView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        footerView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        footerView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true

        footerView.refreshUI()
    }

    @objc private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }

    // Scroll view when keyboard appears. See https://goo.gl/Eq4Bj9
    @objc private func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        guard let keyboardInfo = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            assertionFailure("Failed to get info from keyboard notification")
            return
        }
        let keyboardSize = keyboardInfo.cgRectValue.size
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (navigationController?.navigationBar.frame.height ?? 0.0)
        let contentInsets =
            UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - topBarHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        var viewRect = view.frame
        viewRect.size.height -= keyboardSize.height

        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height
            + keyboardSize.height
            - scrollView.bounds.size.height
            - topBarHeight)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    private static func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            assertionFailure("Failed to parse challenge url")
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

extension ChallengeViewController: ChallengeFooterViewDelegate {

    func onChallengeAccepted(_ challenge: Challenge) {
        challengesService.markChallengeAccepted(challenge.challengeId)
        showChallengeStatusFooterView(
            challenge, "challenge_screen_button_return_after_6pm".localized)
    }

    func onChallengeFinishing(_ challenge: Challenge) {
        showFinishingChallengeFooterView(challenge)
    }

    func onChallengeFinished(_ challenge: Challenge) {
        challengesService.markChallengeFinished(challenge.challengeId)
        showFinishedChallengeFooterView(challenge)
    }
}
