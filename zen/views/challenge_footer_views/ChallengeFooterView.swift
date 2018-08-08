import UIKit

protocol ChallengeFooterViewDelegate: class {
    func onChallengeAccepted(_ challenge: Challenge)
    func onChallengeFinishing(_ challenge: Challenge)
    func onChallengeFinished(_ challenge: Challenge)
}

class ChallengeFooterView: UIView {
    var challenge: Challenge?
    weak var challengeFooterViewDelegate: ChallengeFooterViewDelegate?
    func refreshUI() {}
}
