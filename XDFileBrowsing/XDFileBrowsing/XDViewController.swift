//
//  ViewController.swift
//  XDFileBrowsing
//
//  Created by xiaoda on 2019/1/4.
//  Copyright © 2019 xiaoda. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

private let reuseIdentifier = "XDViewControllerReuseIdentifier"

class XDViewController: UIViewController {

    lazy var tableView: UITableView = {
        
        let tabview = UITableView.init()
        tabview.tableFooterView = UIView()
        tabview.delegate = nil
        tabview.dataSource = nil
        tabview.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        return tabview
    }()
    
    private let bag: DisposeBag = DisposeBag()
    private var menus = BehaviorRelay<[String]>(value: ["Documents", "Library"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        bindRx()
        
    }
    
}

extension XDViewController {
    
    //MARK:- view
    private func setupView() {
        
        self.title = "文件管理"
        self.view.addSubview(tableView)
        self.automaticallyAdjustsScrollViewInsets = false;
        self.extendedLayoutIncludesOpaqueBars = true;
        self.navigationController?.navigationBar.isTranslucent = false;
        
        let statusH = UIApplication.shared.statusBarFrame.height
        let navH = self.navigationController?.navigationBar.frame.height ?? 0
        let top = statusH + navH
        
        tableView.translatesAutoresizingMaskIntoConstraints = false;
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant:top).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    //MARK:- bindRx
    private func bindRx(){
        
        // 将数据源数据绑定到tableView上
        menus.bind(to: tableView.rx.items(cellIdentifier: reuseIdentifier)) {(_,name,cell) in
            
            cell.selectionStyle  = .none
            cell.accessoryType   = .disclosureIndicator
            cell.textLabel?.text = name
            
            }.disposed(by: bag)
        
        // 处理点击事件
//        tableView.rx.modelSelected(NSString.self)
//            .subscribe(onNext: {(value) in
//
//                print("did selected \(value)")
//            })
//            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: {(indexpath) in

                print("did selected \(indexpath)")
                
                self.didSelectedCell(indexPath: indexpath)
            })
            .disposed(by: bag)
    }
    
    private func didSelectedCell(indexPath:IndexPath){
        
        let fileBrowVC = XDFileBrowingViewController()
        
        if indexPath.row == 0 {
            fileBrowVC.title = "Documents"
            let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last
            fileBrowVC.homePath = documentsPath ?? ""
        }
        else
        {
            fileBrowVC.title = "Library"
            let libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last
            fileBrowVC.homePath = libraryPath ?? ""
        }
        
        navigationController?.pushViewController(fileBrowVC, animated: true)
        
    }
    
    
}

