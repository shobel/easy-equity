//
//  KeyStatsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 8/20/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit

protocol StatsVC {
    func updateData()
    func getContentHeight() -> CGFloat
}

extension KeyStatsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.company.peerQuotes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "top10cell", for: indexPath) as! Top10CollectionViewCell
        if let peerQuotes = self.company.peerQuotes {
            let item = peerQuotes[indexPath.row]
            cell.symbolLabel.text = item.symbol
            cell.changePercentLabel.setValue(value: item.changePercent!, isPercent: true)
            cell.latestPriceLabel.text = String("\(item.latestPrice!)")
            cell.latestPriceLabel.textColor = cell.changePercentLabel.getColor(value: item.changePercent)
            return cell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let peerQuotes = self.company.peerQuotes {
            let item = peerQuotes[indexPath.row]
            Dataholder.selectedCompany = Company(symbol: item.symbol!, fullName: "")
            let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StockDetails")
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    
}

class KeyStatsViewController: UIViewController, StatsVC {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var marketCap: FormattedNumberLabel!
    @IBOutlet weak var beta: FormattedNumberLabel!
    @IBOutlet weak var dividend: FormattedNumberLabel!
    @IBOutlet weak var pe: FormattedNumberLabel!
    @IBOutlet weak var eps: FormattedNumberLabel!
    @IBOutlet weak var float: FormattedNumberLabel!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var evLabel: FormattedNumberLabel!
    @IBOutlet weak var dcf: FormattedNumberLabel!
    @IBOutlet weak var pefwd: FormattedNumberLabel!
    @IBOutlet weak var peg: FormattedNumberLabel!
    @IBOutlet weak var sharesOut: FormattedNumberLabel!
    @IBOutlet weak var pb: FormattedNumberLabel!
    @IBOutlet weak var ps: FormattedNumberLabel!
    @IBOutlet weak var rps: FormattedNumberLabel!
    @IBOutlet weak var de: FormattedNumberLabel!
    @IBOutlet weak var evrev: FormattedNumberLabel!
    
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var ceo: UILabel!
    @IBOutlet weak var hq: UILabel!
    @IBOutlet weak var website: UILabel!
    @IBOutlet weak var sector: UILabel!
    @IBOutlet weak var industry: UILabel!
    @IBOutlet weak var employees: UILabel!
    
    @IBOutlet weak var insidersLabel: UILabel!
    @IBOutlet weak var insidersValue: UILabel!
    
    private var company:Company!
    private var isLoaded = false
    @IBOutlet weak var peerCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.peerCollection.delegate = self
        self.peerCollection.dataSource = self
        self.company = Dataholder.selectedCompany!
    }
    
    func updateQuoteData(){
        DispatchQueue.main.async {
            if let x = self.company.quote?.marketCap {
                self.marketCap.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
            }
            if let x = self.company.quote?.peRatio {
                self.pe.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
            }
            if let x = self.company.quote?.eps {
                self.eps.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
            }
            //computed based on quote latest quote
            if let x = self.company.peFwd {
                self.pefwd.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
            }
        }
    }
    
    func updateData() {
        if (!isLoaded){
            DispatchQueue.main.async {
                self.peerCollection.reloadData()
                self.updateQuoteData()
                if let x = self.company.generalInfo?.beta {
                    self.beta.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.generalInfo?.lastDiv {
                    self.dividend.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.generalInfo?.float {
                    self.float.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.generalInfo?.sharesOutstanding {
                    self.sharesOut.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.generalInfo?.dcf {
                    self.dcf.setValue(value: String(x), format: FormattedNumberLabel.Format.DATE)
                }
                if let x = self.company.advancedStats?.pegRatio {
                    self.peg.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.advancedStats?.priceToBook {
                    self.pb.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.advancedStats?.priceToSales {
                    self.ps.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.advancedStats?.revenuePerShare {
                    self.rps.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.advancedStats?.debtToEquity {
                    self.de.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.advancedStats?.enterpriseValueToRevenue {
                    self.evrev.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.advancedStats?.enterpriseValue {
                    self.evLabel.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.generalInfo?.description {
                    self.desc.text = x
                }
                if let x = self.company.generalInfo?.ceo {
                    self.ceo.text = x
                }
                if let x = self.company.generalInfo?.city, let y = self.company.generalInfo?.state {
                    self.hq.text = String("\(x), \(y)")
                }
                if let x = self.company.generalInfo?.sector {
                    self.sector.text = x
                }
                if let x = self.company.generalInfo?.industry {
                    self.industry.text = x
                }
                if let x = self.company.generalInfo?.website {
                    self.website.text = x
                }
                if let x = self.company.generalInfo?.employees {
                    self.employees.text = String(x)
                }
                
                if let nt = self.company.insiders?.netTransacted, let days = self.company.insiders?.days {
                    if nt > 0 {
                        self.insidersLabel.text = String("Insiders net bought (past \(days) days)")
                        let valFormatted = NumberFormatter.formatNumber(num: Double(nt))
                        self.insidersValue.text = "$\(valFormatted)"
                        self.insidersValue.textColor = Constants.green
                    } else {
                        self.insidersLabel.text = String("Insiders net sold (past \(days) days)")
                        let valFormatted = NumberFormatter.formatNumber(num: Double(-nt))
                        self.insidersValue.text = "$\(valFormatted)"
                        self.insidersValue.textColor = Constants.darkPink
                    }
                }
            }
            self.isLoaded = true
            DispatchQueue.main.async {
                if let p = self.parent?.parent?.parent as? StockDetailsVC {
                    p.adjustContentHeight(vc: self)
                }
            }
        }
    }
     
    func getContentHeight() -> CGFloat {
        return self.contentView.bounds.height
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
