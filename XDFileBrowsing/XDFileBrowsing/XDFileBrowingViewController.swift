//
//  XDFileBrowingViewController.swift
//  XDFileBrowsing
//
//  Created by xiaoda on 2019/1/4.
//  Copyright © 2019 xiaoda. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

private let reuseIdentifier = "XDFileBrowingViewControllerReuseIdentifier"

class XDFileBrowingViewController: UIViewController {
    
    public var homePath: String = ""
    
    private let bag: DisposeBag = DisposeBag()
    
    lazy var tableView: UITableView = {
        
        let tabview = UITableView.init()
        tabview.tableFooterView = UIView()
        tabview.delegate = nil
        tabview.dataSource = nil
        tabview.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        return tabview
    }()

    private var files = BehaviorRelay<[XDFileModel]>(value: [])
    private var showFiles: [XDFileModel] = []
    
    private var docVC: UIDocumentInteractionController = UIDocumentInteractionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white;
        
        setupView()
        
        getData()
        
        bindRx()
        
    }
    
}

extension XDFileBrowingViewController {
    
    func setupView() {
        
        self.view.backgroundColor = UIColor.white
        
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
    
    
    func getData() {

        let items = try?FileManager.default.contentsOfDirectory(atPath: homePath)
        
        showFiles.removeAll()
        
        for str in items ?? [] {
            let contentPath = homePath + "/" + str
            
            let object = XDFileModel.init(filePath: contentPath)
            showFiles.append(object)
        }
        
        files.accept(showFiles)
    }
    
    func bindRx() {

        files.bind(to: tableView.rx.items(cellIdentifier: reuseIdentifier)) {(_,item,cell) in
            
            var imageName = "ico_file"
            
            if item.fileType == XDFileType.XDDirectory {
                imageName = "ico_directory"
            }
            
            cell.imageView?.image = UIImage.init(named: imageName);
            cell.textLabel?.text = item.name
            
            }.disposed(by: bag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: {(indexpath) in
                
                self.tableView.deselectRow(at: indexpath, animated: true)
                
                let item = self.showFiles[indexpath.row];

                if item.fileType == XDFileType.XDFile{
                    self.lookFile(item: item)
                }
                else
                {
                    self.pushToPath(item: item)
                }
            })
            .disposed(by: bag)
    }
    
}


extension XDFileBrowingViewController {
    
    func pushToPath(item: XDFileModel) {
        
        let vc = XDFileBrowingViewController()
        vc.title = item.name
        vc.homePath = item.filePath
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func lookFile(item: XDFileModel) {
        
        let url = NSURL.fileURL(withPath: item.filePath)
        
        docVC.url = url
        
        docVC.delegate = self
        
        docVC.presentOptionsMenu(from: self.view.bounds, in: self.view, animated: true)
    }
    
}

extension XDFileBrowingViewController: UIDocumentInteractionControllerDelegate{
    
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    
}

