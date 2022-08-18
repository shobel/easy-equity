//
//  PlaidViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 5/31/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit
import LinkKit
import FCAlertView

class PlaidViewController: UIViewController {

    @IBOutlet var mainView: UIView!
    private var linkToken:String?
    private var handler:LinkKit.Handler?
    private var account:BrokerageAccount?
    private var holdings:[Holding] = []
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var accountContainer: ShadowView!
    @IBOutlet weak var instName: UILabel!
    @IBOutlet weak var accountType: UILabel!
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var accountValue: UILabel!
    
    @IBOutlet weak var holdingSummaryContainer: ShadowView!
    @IBOutlet weak var plPercent: UILabel!
    @IBOutlet weak var investedTotal: UILabel!
    @IBOutlet weak var openPL: UILabel!
    @IBOutlet weak var numHoldings: UILabel!
    
    @IBOutlet weak var balanceChart: BalanceChart!
    @IBOutlet weak var chartContainer: ShadowView!
    
    @IBOutlet weak var linkContainer: UIView!
    private var totalInvested:Double = 0.0
    private var openPLValue:Double = 0.0
    private var balances:[DateAndBalance] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainView.addPurpleGradientBackground()
        self.chartContainer.isHidden = true
        
        DispatchQueue.main.async {
            self.balanceChart.setup()
        }

        self.loader.startAnimating()
        
        self.fetchAccountData()
        
    }
    
    func fetchAccountData(){
        DispatchQueue.main.async {
            self.loader.startAnimating()
        }
        if Dataholder.account == nil {
            NetworkManager.getMyRestApi().getLinkedAccountAndHoldings { account, holdings in
                if account != nil {
                    self.account = account
                    self.holdings = holdings
                    Dataholder.account = account
                    Dataholder.holdings = holdings
                    self.setData()
                } else {
                    DispatchQueue.main.async {
                        self.loader.stopAnimating()
                    }
                }
            }
        } else {
            self.account = Dataholder.account
            self.holdings = Dataholder.holdings
            self.setData()
        }
        
        NetworkManager.getMyRestApi().getBalanceHistory { balances in
            self.balances = balances
            DispatchQueue.main.async {
                self.balanceChart.setData(self.balances)
            }
        }
    }
    
    func setData(){
        self.deriveStatsFromHoldings()
        
        DispatchQueue.main.async {
            self.instName.text = self.account?.institutionName ?? ""
            self.accountType.text = (self.account?.accountType ?? "") + " account"
            self.accountName.text = self.account?.accountName ?? ""
            self.accountValue.text = NumberFormatter.formatMonetaryValue(self.account?.balance?.current ?? 0.0, numDec: 0, addPlusMinus: false)//String(format: "%0.2f", self.account?.balance?.current ?? 0.0)
            
            self.investedTotal.text = NumberFormatter.formatMonetaryValue( self.totalInvested, numDec: 0, addPlusMinus: false)
            self.openPL.text = NumberFormatter.formatMonetaryValue(self.openPLValue, numDec: 0, addPlusMinus: true)
            self.openPL.textColor = Constants.green
            if self.openPLValue < 0 {
                self.openPL.textColor = Constants.darkPink
            }
            
            self.plPercent.text = ""
            if let b = self.account?.balance?.current {
                if b > 0 {
                    let percent = ((b - (b - self.openPLValue))  / (b - self.openPLValue))*100.0
                    self.plPercent.text = String(format: "(%0.1f%%)", percent)
                    self.plPercent.textColor = Constants.darkPink
                    if self.openPLValue > 0 {
                        self.plPercent.text = String(format: "(+%0.1f%%)", percent)
                        self.plPercent.textColor = Constants.green

                    }
                }
            }
          
            self.numHoldings.text = "\(self.holdings.count)"
            self.showAccountViews()
            self.loader.stopAnimating()
        }
    }
    
    func showAccountViews(){
        DispatchQueue.main.async {
            self.linkContainer.isHidden = true
            self.accountContainer.isHidden = false
            self.holdingSummaryContainer.isHidden = false
            //self.chartContainer.isHidden = false
        }
    }
    
    func hideAccountViews(){
        DispatchQueue.main.async {
            self.linkContainer.isHidden = false
            self.accountContainer.isHidden = true
            self.holdingSummaryContainer.isHidden = true
            //self.chartContainer.isHidden = true
        }
    }
    
    func deriveStatsFromHoldings() {
        let portfolio = Dataholder.watchlistManager.getPortfolio()
        var total:Double = 0.0
        var totalPL:Double = 0.0
        for h in self.holdings {
            for p in portfolio {
                if h.symbol == p.symbol {
                    let currenVal = (h.quantity ?? 0.0) * (p.quote?.latestPrice ?? 0.0)
                    total += currenVal
                    totalPL += currenVal - (h.cost_basis ?? 0.0)
                }
            }
        }
        self.totalInvested = total
        self.openPLValue = totalPL
    }
    
    @IBAction func linkButtonAction(_ sender: Any) {
        NetworkManager.getMyRestApi().createPlaidLinkToken { token in
            self.linkToken = token
            if self.linkToken != nil {
                self.initLink()
            }
        }
    }
    
    func initLink(){
        let linkConfiguration = LinkTokenConfiguration(
            token: self.linkToken!,
            onSuccess: { linkSuccess in
                print(linkSuccess)
                if linkSuccess.metadata.accounts.count > 0{
                    let inst = linkSuccess.metadata.institution
                    let account = linkSuccess.metadata.accounts[0]
                    var ba = BrokerageAccount()
                    ba.accountId = account.id
                    ba.accountName = account.name
                    ba.accountType = "\(account.subtype)"
                    ba.institutionId = inst.id
                    ba.institutionName = inst.name
                    
                    DispatchQueue.main.async {
                        self.loader.startAnimating()
                    }
                    NetworkManager.getMyRestApi().handleLinkedAccount(linkSuccess.publicToken, account: ba) {
                        DispatchQueue.main.async {
                            self.loader.stopAnimating()
                        }
                        self.fetchAccountData()
                    }
                }
            }
        )
        
        let result = Plaid.create(linkConfiguration)
        switch result {
        case .failure(let error): break
          case .success(let handler):
              self.handler = handler
        }
        
        if self.handler != nil {
            let method: PresentationMethod = .viewController(self)
            DispatchQueue.main.async {
                self.handler!.open(presentUsing: method)
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unlinkAccount(_ sender: Any) {
        self.loader.startAnimating()
        Dataholder.holdings = []
        Dataholder.account = nil
        NetworkManager.getMyRestApi().unlinkPlaidAccount {
            DispatchQueue.main.async {
                self.loader.stopAnimating()
            }
            self.hideAccountViews()
        }
    }
    
    @IBAction func info(_ sender: Any) {
        self.showInfoAlert1()
    }
    
    @IBAction func infoBalanceHistory(_ sender: Any) {
        self.showInfoAlert2()
    }
    
    func showInfoAlert1() {
        let message = "Stoccoon uses Plaid to securely and safely receive data from financial institutions. You control what account to link with this app can unlink your account at any time. Only account balance and investment holdings information are received. Only common stock holdings are shown in the Watchlists tab. Options positions are not supported at this time."
        let alert = FCAlertView()
        alert.doneActionBlock {
            //print()
        }
        alert.alertBackgroundColor = Constants.themePurple
        alert.titleColor = .white
        alert.subTitleColor = .white
        alert.colorScheme = Constants.lightPurple
        alert.doneButtonTitleColor = .white
        alert.secondButtonTitleColor = .darkGray
        alert.firstButtonTitleColor = .darkGray
        alert.dismissOnOutsideTouch = true
        alert.detachButtons = true
        alert.showAlert(inView: self,
                        withTitle: title,
                        withSubtitle: message,
                        withCustomImage: UIImage(systemName: "info.circle"),
                        withDoneButtonTitle: "Ok",
                        andButtons: [])
    }
    
    func showInfoAlert2() {
        let message = "Stoccoon does not receive balance history from your bank and therefore past account values are not graphed. However, the future evolution of your account balance will be graphed below."
        let alert = FCAlertView()
        alert.doneActionBlock {
            //print()
        }
        alert.alertBackgroundColor = Constants.themePurple
        alert.titleColor = .white
        alert.subTitleColor = .white
        alert.colorScheme = Constants.lightPurple
        alert.doneButtonTitleColor = .white
        alert.secondButtonTitleColor = .darkGray
        alert.firstButtonTitleColor = .darkGray
        alert.dismissOnOutsideTouch = true
        alert.detachButtons = true
        alert.showAlert(inView: self,
                        withTitle: title,
                        withSubtitle: message,
                        withCustomImage: UIImage(systemName: "info.circle"),
                        withDoneButtonTitle: "Ok",
                        andButtons: [])
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
