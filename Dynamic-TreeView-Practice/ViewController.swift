//
//  ViewController.swift
//  Dynamic-TreeView-Practice
//
//  Created by Mac on 07/09/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var productListTableView: UITableView!
    // KJ Tree instances -------------------------
    private var parentTree:[Parent] = []
    private var ingredientTreeInstance: KJTree = KJTree()
    private var childrenForParent = [Child]()
    
    // Data
    private var ingredientNodeCollection: [String] = []
    // -10 is understanding purpose only
    private let subChoiceFlag: String = "-10"
    private var selectedSubChoiceParentId: String = ""
    private var ingredientIdCollection: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureIngredientTableView()
    }


    @IBAction func getSelectedItems(_ sender: UIButton) {
        print("Items: \(ingredientNodeCollection)")
    }
}

extension ViewController {
    
    private func configureIngredientTableView() {
        productListTableView.delegate = self
        productListTableView.dataSource = self
        
        let ingredientCellNib = UINib(nibName: "IngredientTableViewCell", bundle: nil)
        productListTableView.register(ingredientCellNib, forCellReuseIdentifier: "IngredientTableViewCell")
        
        self.configureChildren(for: &self.parentTree)
        self.ingredientTreeInstance = KJTree(Parents: self.parentTree)
        self.ingredientTreeInstance.isInitiallyExpanded = false
        productListTableView.reloadData()
        // This is Default Root Parent Node. For Ingredient Selection Purpose
        for (index, _) in self.parentTree.enumerated() {
            self.ingredientNodeCollection.append("\(index)")
        }
    }
    
    private func configureChildren(for parent: inout [Parent]) {
        guard let mainIngredientGroup = getJsonResponse() else { return }
        for mainGroupItem in mainIngredientGroup {
            var groupIngredient: [GroupIngredient] = []
            if let groupIng = mainGroupItem.groupIngredient {
                groupIngredient = groupIng
            }
            let parentNew = Parent(expanded: true) {
                addChildrenRecursively(mainGroup: mainGroupItem, groupIngredientList: groupIngredient, childVar: &childrenForParent)
                return childrenForParent
            }
            parent.append(parentNew)
            childrenForParent.removeAll()
        }
    }
    
    // Action for Recursive Children
    /// Need to run the loop untill subchoice ingredeint group will empty.
    /// - Parameters:
    ///   - mainGroup: Only for maximum limit
    ///   - groupIngredientList: We can get this array from every main ingredeient
    ///   - childVar: This is collections of child from total ingredient and subchoice ingredient group
    func addChildrenRecursively(mainGroup: MainIngredientGroup? = nil, groupIngredientList: [GroupIngredient], childVar: inout [Child]){
        for groupIngredient in groupIngredientList {
            let groupIngredientSelected = groupIngredient.isSelected == 1
            childVar.append(Child(expanded: groupIngredientSelected){
                var subChoice = [Child]()
                var subChoiceGroupIngredient: [SubChoiceGroupIngredient] = []
                if let subChoiceGroup = groupIngredient.subChoiceGroupIngredient {
                    subChoiceGroupIngredient = subChoiceGroup
                }
                for subItem in subChoiceGroupIngredient {
                    subChoice.append(Child(expanded: groupIngredientSelected){
                        var subChoice1 = [Child]()
                        var groupIngredient1: [GroupIngredient] = []
                        if let ingredientGroup = subItem.groupIngredient {
                            groupIngredient1 = ingredientGroup
                        }
                        addChildrenRecursively(groupIngredientList: groupIngredient1, childVar: &subChoice1)
                        return subChoice1
                    })
                }
                return subChoice
            })
        }
    }
    
    private func getJsonResponse() -> [MainIngredientGroup]? {
        do {
            if let file = Bundle.main.url(forResource: "ingredient_response", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONDecoder().decode(ProductDetails.self, from: data)
                return json.item?[0].mainIngredientGroup
            } else {
                print("No such file")
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func getDataFromKJIndex(index: String) -> IngredientDetails? {
        if index.isEmpty { return nil }
        var indexList: [Int] = index.components(separatedBy: ".").map {Int($0)!}
        var ingredientDetailsFromIndex: IngredientDetails?
        var mainIngredientGroup: [MainIngredientGroup]!
        if let mainIngredientGroup1 = getJsonResponse() {
            mainIngredientGroup = mainIngredientGroup1
        } else { return nil }
        let mainIngredient = mainIngredientGroup[indexList.first!]
        if indexList.count == 1 {
            guard let id = mainIngredient.id,
                  let name = mainIngredient.name,
                  let price = mainIngredient.price,
                  let min = mainIngredient.min,
                  let max = mainIngredient.max
            else { return nil }
            let groupIngredientCount = mainIngredient.groupIngredient?.count ?? 0
            ingredientDetailsFromIndex = IngredientDetails(id: id,
                                                           name: name,
                                                           price: String(format: "%.2f", price),
                                                           parentIDs: "",
                                                           min: min,
                                                           max: max,
                                                           isSelected: nil,
                                                           childrenCount: groupIngredientCount)
        }else{
            indexList.removeFirst()
            var groupIngredient: GroupIngredient?
            var subChoiceGroupIngredient: SubChoiceGroupIngredient?
            
            for (i, item) in indexList.enumerated() {
                if i % 2 == 0 {
                    if groupIngredient != nil {
                        groupIngredient = subChoiceGroupIngredient?.groupIngredient?[item]
                    }else{
                        groupIngredient = mainIngredient.groupIngredient?[item] ?? nil
                    }
                }else{
                    subChoiceGroupIngredient = groupIngredient?.subChoiceGroupIngredient?[item] ?? nil
                }
            }
            if indexList.count % 2 == 0 {
                guard let id = subChoiceGroupIngredient?.id,
                      let name = subChoiceGroupIngredient?.name,
                      let price = subChoiceGroupIngredient?.price,
                      let parentId = subChoiceGroupIngredient?.parentID,
                      let min = subChoiceGroupIngredient?.min,
                      let max = subChoiceGroupIngredient?.max
                else { return nil }
                let groupIngredientCount = subChoiceGroupIngredient?.groupIngredient?.count ?? 0
                ingredientDetailsFromIndex = IngredientDetails(id: id,
                                                               name: name,
                                                               price: String(format: "%.2f", price),
                                                               parentIDs: parentId + "," + "\(id)",
                                                               min: min,
                                                               max: max,
                                                               isSelected: nil,
                                                               childrenCount: groupIngredientCount)
            }else{
                guard let id = groupIngredient?.id,
                      let name = groupIngredient?.name,
                      let price = groupIngredient?.price,
                      let parentId = groupIngredient?.parentID,
                      let selected = groupIngredient?.isSelected
                else { return nil }
                let subChoiceIngredientCount = groupIngredient?.subChoiceGroupIngredient?.count ?? 0
                ingredientDetailsFromIndex = IngredientDetails(id: id,
                                                               name: name,
                                                               price: String(format: "%.2f", price),
                                                               parentIDs: parentId + "," + "\(id)",
                                                               min: 0,
                                                               max: 0,
                                                               isSelected: selected == 1,
                                                               childrenCount: subChoiceIngredientCount)
            }
        }
        return ingredientDetailsFromIndex
    }
    
}

extension ViewController: UITableViewDelegate & UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let total = ingredientTreeInstance.tableView(tableView, numberOfRowsInSection: section)
        return total
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = ingredientTreeInstance.cellIdentifierUsingTableView(tableView, cellForRowAt: indexPath)
        let indexTuples = node.index.components(separatedBy: ".")
        let currentParentNode = indexTuples.prefix(indexTuples.count - 1).joined(separator: ".")
        let tableviewcell = tableView.dequeueReusableCell(withIdentifier: "IngredientTableViewCell") as! IngredientTableViewCell
        guard let details = getDataFromKJIndex(index: node.index) else { return UITableViewCell() }
        let parentMaxLimt = getDataFromKJIndex(index: currentParentNode)?.max ?? 0
        let ingredientAlreadySelected = ingredientNodeCollection.contains(node.index)

        if let selected = details.isSelected, selected, !ingredientAlreadySelected,
           node.state == .open {
            selectedSubChoiceParentId = subChoiceFlag
            if !ingredientNodeCollection.contains(currentParentNode) {
                ingredientNodeCollection.append(currentParentNode)
            }
            ingredientNodeCollection.append(node.index)
        }
        let cellType: CellType = parentMaxLimt == 1 ? .RadioButton : .CheckBox
        tableviewcell.configureView(state: node.state, ingredient: details.name, price: details.price, spacing: indexTuples.count, type: cellType)
        return tableviewcell
    }
}

extension ViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNode = ingredientTreeInstance.cellIdentifierUsingTableView(tableView, cellForRowAt: indexPath)
        if selectedNode.index.components(separatedBy: ".").count % 2 == 1 { return }
        if selectedNode.index.count == 1 { return }
        // Parent Node Array
        var tempIndexArray = selectedNode.index.components(separatedBy: ".")
        tempIndexArray.removeLast()
        let parentNode = tempIndexArray.joined(separator: ".")
        
        // Only for limit calculation
        guard let limit = getDataFromKJIndex(index: parentNode) else { return }
        // Choice details for current node
        guard let choice = getDataFromKJIndex(index: selectedNode.index) else { return }
        let rootParent = selectedNode.index.split(separator: ".").prefix(2).joined(separator: ".")
        if selectedNode.state == .close {
            if limit.min >= 0, limit.max > 1 {
                let alreadyContainParentAndChild = ingredientNodeCollection.filter{
                    if String($0.prefix(parentNode.count)) == parentNode { return true }
                    return false
                }
                let selectedChoiceNew = alreadyContainParentAndChild.filter{
                    $0.components(separatedBy: ".").count == tempIndexArray.count + 1
                }
                if selectedChoiceNew.count < limit.max {
                    ingredientNodeCollection.append(selectedNode.index)
                    let containsParentCount = ingredientNodeCollection.filter { $0 == parentNode }.count
                    if containsParentCount == 0 { ingredientNodeCollection.append(parentNode) }
                }else{
//                    SVProgressHUD.showInfo(withStatus: "Limit Exceed!".localized)
                    return
                }
            } else if limit.min >= 0, limit.max == 1 {
                // Check we reached the parent or not?
                for i in (0...indexPath.row).reversed() {
                    let indexPathTemp = IndexPath(row: i, section: 0)
                    let newParentNodeIndex = ingredientTreeInstance.cellIdentifierUsingTableView(tableView, cellForRowAt: indexPathTemp).index
                    if newParentNodeIndex == parentNode {
                        let childNew1 = getDataFromKJIndex(index: newParentNodeIndex)
                        let childNewCount = childNew1?.childrenCount ?? 0
                        for j in (1...childNewCount) {
                            let newIndexPath1 = IndexPath(row: i + j, section: 0)
                            let childState = ingredientTreeInstance.cellIdentifierUsingTableView(tableView, cellForRowAt: newIndexPath1).state
                            if childState == .open {
                                _ = ingredientTreeInstance.tableView(tableView, didSelectRowAt: newIndexPath1)
                            }
                        }
                        for k in (1...childNewCount){
                            let newIndexPath1 = IndexPath(row: i + k, section: 0)
                            let childNew1 = ingredientTreeInstance.cellIdentifierUsingTableView(tableView, cellForRowAt: newIndexPath1)
                            if childNew1.state == .close, childNew1.index == selectedNode.index {
                                selectTheSubChoiceItem(for: newIndexPath1, node: childNew1.index, state: .close)
                            }
                        }
                    }
                }
                ingredientNodeCollection = ingredientNodeCollection.filter {                    $0.prefix(parentNode.count) != parentNode
                }
                ingredientNodeCollection.append(parentNode)
                ingredientNodeCollection.append(selectedNode.index)
                
                ingredientIdCollection = ingredientIdCollection.filter {
                    ingredientNodeCollection.contains($0.key)
                }
                ingredientIdCollection[rootParent] = ""
                
                productListTableView.reloadData()
                return
            }
        }else if selectedNode.state == .open {
            if limit.min >= 0, limit.max == 1 {
                return
            }
            
            // It will remove the current node and their children
            ingredientNodeCollection = ingredientNodeCollection.filter{
                if !(String($0.prefix(selectedNode.index.count)) == selectedNode.index) { return true }
                return false
            }
            // For filter the node collection
            let selectedNodeChild1 = ingredientNodeCollection.filter {
                return $0.prefix(parentNode.count) == parentNode
            }
            if selectedNodeChild1.count == 1 {
                ingredientNodeCollection = ingredientNodeCollection.filter { $0 != parentNode }
            }
        }
        selectTheSubChoiceItem(for: indexPath, node: selectedNode.index, state: selectedNode.state)
    }
    
    /// This function will open all subchoice when we open group ingredeint.
    /// - Parameters:
    ///   - indexPath: selected tndex path from tableView
    ///   - node: Node string from KJTree
    ///   - state: Current cell state
    private func selectTheSubChoiceItem(for indexPath: IndexPath, node: String, state: CellState) {
        let selectedChoice = getDataFromKJIndex(index: node)
        var tempRow = indexPath.row + 1
        let childCount = selectedChoice?.childrenCount ?? 0
        _ = ingredientTreeInstance.tableView(productListTableView, didSelectRowAt: indexPath)
        
        if state == .close, childCount > 0{
            for i in 0...childCount - 1 {
                _ = ingredientTreeInstance.tableView(productListTableView, didSelectRowAt: IndexPath(row: tempRow, section: 0))
                let subChildCount = getDataFromKJIndex(index: node + "." + "\(i)")?.childrenCount ?? 0
                tempRow += subChildCount + 1
            }
        }
    }
}
