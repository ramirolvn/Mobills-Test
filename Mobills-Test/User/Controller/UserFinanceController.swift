import UIKit
import Floaty
import SwiftSpinner
import Charts
import BTNavigationDropdownMenu

class UserFinanceController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var infoTable: UITableView!
    
    var user: FirebaseUser!
    var userProfits: [FirebaseProfit]?
    var userWastes: [FirebaseWaste]?
    private let items = ["Todos as transações", "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: BTTitle.index(0), items: items)
        self.navigationItem.titleView = menuView
        self.addFloatBtn()
        self.infoTable.delegate = self
        self.infoTable.dataSource = self
        self.infoTable.rowHeight = UITableView.automaticDimension
        self.infoTable.estimatedRowHeight = 250
        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            print("Did select item at index: \(indexPath)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getProfitsAndWastes()
    }
    
    
    
    @IBAction func logouAction(_ sender: UIBarButtonItem) {
        SwiftSpinner.show("Saindo...")
        UserNetworking.logoutUser(user, completion: {response in
            SwiftSpinner.hide()
            if let err = response.err{
                SwiftSpinner.hide()
                self.simpleAlert(title: "Erro", msg: err)
            }else{
                SwiftSpinner.hide()
                let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                if let loginNavigation = mainStoryBoard.instantiateViewController(withIdentifier: "loginNavigation") as? UINavigationController, let window = appDel.window{
                    window.rootViewController = loginNavigation
                    window.makeKeyAndVisible()
                }
            }
        })
        
    }
    
    //Mark:-- TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Receitas"
        case 2:
            return "Despesas"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return self.userProfits?.count ?? 0
        case 2:
            return self.userWastes?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0, let chartCell = self.infoTable.dequeueReusableCell(withIdentifier: "chartCell") as? ChartCell{
            chartCell.chartView = self.setupChart(chart: chartCell.chartView)
            cell = chartCell
        }else if indexPath.section == 1, let userProfits = self.userProfits, let cellProfitOrWaste = self.infoTable.dequeueReusableCell(withIdentifier: "profitOrWasteCell") as? ProfitOrWasteCell{
            let profit = userProfits[indexPath.row]
            cellProfitOrWaste.valorLB.textColor = UIColor.init(rgb: 0x009000)
            cellProfitOrWaste.valorLB.text = profit.valor?.stringValue.currencyInputFormatting() ?? ""
            cellProfitOrWaste.dateLB.text = profit.data?.dateValue().getStringDate()
            cell = cellProfitOrWaste
        }else if indexPath.section == 2, let userWastes = self.userWastes, let cellProfitOrWaste = self.infoTable.dequeueReusableCell(withIdentifier: "profitOrWasteCell") as? ProfitOrWasteCell{
            let waste = userWastes[indexPath.row]
            cellProfitOrWaste.valorLB.textColor = UIColor.init(rgb: 0xcc0000)
            cellProfitOrWaste.valorLB.text = waste.valor?.stringValue.currencyInputFormatting() ?? ""
            cellProfitOrWaste.dateLB.text = waste.data?.dateValue().getStringDate()
            cell = cellProfitOrWaste
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1, let profits = self.userProfits{
            let profit = profits[indexPath.row]
            self.performSegue(withIdentifier: "crudFinance", sender: ["Editar Receita", profit])
            
        }else if indexPath.section == 2, let wastes = self.userWastes{
            let waste = wastes[indexPath.row]
            self.performSegue(withIdentifier: "crudFinance", sender: ["Editar Despesa", waste])
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0{
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions: [UITableViewRowAction]?
        if indexPath.section == 1{
            let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
                let profit = self.userProfits![indexPath.row]
                let alert = UIAlertController(title: "Atenção", message: "Tem certeza que deseja deletar essa transação?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Sim", style: .destructive, handler: {_ in
                    DispatchQueue.main.async {
                        SwiftSpinner.show("Deletando..")
                    }
                    ProfitNetworking.deleteProfit(userUID: self.user.uid, profit: profit, completion: {
                        (response) in
                        DispatchQueue.main.async {
                            SwiftSpinner.hide()
                            if let errDcm = response.errDocument{
                                self.simpleAlert(title: "Erro", msg: errDcm)
                            }else{
                                self.userProfits?.remove(at: indexPath.row)
                                self.infoTable.reloadData()
                            }
                        }
                    })
                }))
                alert.addAction(UIAlertAction(title: "Não", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            })
            actions = [deleteAction]
        }else{
            let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
                let waste = self.userWastes![indexPath.row]
                let alert = UIAlertController(title: "Atenção", message: "Tem certeza que deseja deletar essa transação?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Sim", style: .destructive, handler: {_ in
                    DispatchQueue.main.async {
                        SwiftSpinner.show("Deletando..")
                    }
                    WasteNetworking.deleteWaste(userUID: self.user.uid, waste: waste, completion: {
                        (response) in
                        DispatchQueue.main.async {
                            SwiftSpinner.hide()
                            if let errDcm = response.errDocument{
                                self.simpleAlert(title: "Erro", msg: errDcm)
                            }else{
                                self.userWastes?.remove(at: indexPath.row)
                                self.infoTable.reloadData()
                            }
                        }
                    })
                }))
                alert.addAction(UIAlertAction(title: "Não", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            })
            actions = [deleteAction]
        }
        
        return actions
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let crudFinanceCntrl = segue.destination as? CrudFinanceController else { return }
        if let objToSender = sender as? [Any], let typeChosen = objToSender[0] as? String{
            crudFinanceCntrl.user = self.user
            crudFinanceCntrl.labelText = "Pago?"
            crudFinanceCntrl.navigationItem.title = typeChosen
            if typeChosen == "Cadastrar Receita"{
                crudFinanceCntrl.labelText = "Recebido?"
                crudFinanceCntrl.dataType = .NewProfit
                crudFinanceCntrl.setup(for: .NewProfit)
            }else if typeChosen == "Cadastrar Despesa"{
                crudFinanceCntrl.labelText = "Pago?"
                crudFinanceCntrl.dataType = .NewWaste
                crudFinanceCntrl.setup(for: .NewWaste)
            }else if typeChosen == "Editar Receita"{
                crudFinanceCntrl.userProfit = objToSender[1] as? FirebaseProfit ?? nil
                crudFinanceCntrl.labelText = "Recebido?"
                crudFinanceCntrl.dataType = .EditProfit
                crudFinanceCntrl.setup(for: .EditProfit)
            }else if typeChosen == "Editar Despesa"{
                crudFinanceCntrl.userWaste = objToSender[1] as? FirebaseWaste ?? nil
                crudFinanceCntrl.labelText = "Pago?"
                crudFinanceCntrl.dataType = .EditWaste
                crudFinanceCntrl.setup(for: .EditWaste)
            }
        }
    }
    
    private func setupChart(chart: PieChartView) -> PieChartView{
        let track = ["Despesas", "Receitas"]
        
        var money = [NSNumber]()
        if let userProfits = self.userProfits, let userWastes = self.userWastes{
            var totalUserProfits: NSNumber = 0.0
            var totalWastesProfits: NSNumber = 0.0
            for w in userWastes{
                if let valor = w.valor{
                    totalWastesProfits = totalWastesProfits + valor
                }
            }
            
            for p in userProfits{
                if let valor = p.valor{
                    totalUserProfits = totalUserProfits + valor
                }
            }
            
            money.append(totalWastesProfits)
            money.append(totalUserProfits)
        }
        
        var entries = [PieChartDataEntry]()
        for (index, value) in money.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = value.doubleValue
            entry.label = track[index]
            entries.append( entry)
        }
        
        let set = PieChartDataSet(values: entries, label: nil)
        set.colors = [UIColor.init(rgb: 0xcc0000),UIColor.init(rgb: 0x009000)]
        let data = PieChartData(dataSet: set)
        chart.data = data
        chart.noDataText = "Sem registro até o momento"
        chart.isUserInteractionEnabled = true
        
        let d = Description()
        d.text = "Despesas x Receitas"
        d.position = CGPoint(x: 110, y: 10)
        chart.chartDescription = d
        chart.holeRadiusPercent = 0.2
        chart.transparentCircleColor = UIColor.clear
        return chart
    }
    
    
    private func addFloatBtn(){
        let floaty = Floaty()
        floaty.openAnimationType = .fade
        floaty.addItem("Adicionar despesa", icon: UIImage(named: "waste"), handler: { item in
            self.performSegue(withIdentifier: "crudFinance", sender: ["Cadastrar Despesa"])
            floaty.close()
        })
        floaty.addItem("Adicionar receita", icon: UIImage(named: "profit"), handler: { item in
            self.performSegue(withIdentifier: "crudFinance", sender: ["Cadastrar Receita"])
            floaty.close()
        })
        DispatchQueue.main.async {
            floaty.tintColor = .darkGray
            self.view.addSubview(floaty)
        }
    }
    
    private func getProfitsAndWastes(){
        SwiftSpinner.show("Carregando Informações...")
        WasteNetworking.getUserWastes(userUID: self.user.uid, completion: {
            (response) in
            if let err = response.err{
                self.simpleAlert(title: "Erro", msg: err)
            }
            if let wastes = response.userWastes{
                self.userWastes = wastes
            }
            //get profits
            ProfitNetworking.getUserPrtofits(userUID: self.user.uid, completion: {
                (response) in
                SwiftSpinner.hide()
                if let err = response.err{
                    self.simpleAlert(title: "Erro", msg: err)
                }
                if let profits = response.userProfits{
                    self.userProfits = profits
                }
                DispatchQueue.main.async {
                    self.infoTable.reloadData()
                }
            })
        })
        
        
    }
    
}
