//
//  TableViewBindingHelper.swift
//  ReactiveSwiftFlickrSearch
//
//  Created by Colin Eberhardt on 15/07/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result

@objc protocol ReactiveView {
  func bindViewModel(viewModel: AnyObject)
}

// a helper that makes it easier to bind to UITableView instances
// see: http://www.scottlogic.com/blog/2014/05/11/reactivecocoa-tableview-binding.html
class TableViewBindingHelper<T: AnyObject> : NSObject {
  
  //MARK: Properties
  
  var delegate: UITableViewDelegate?
  
  private let tableView: UITableView
  private let templateCell: UITableViewCell
  private let selectionCommand: RACCommand?
  private let dataSource: DataSource
  
  //MARK: Public API
  
  init(tableView: UITableView, sourceSignal: SignalProducer<[T], NoError>, nibName: String, selectionCommand: RACCommand? = nil) {
    self.tableView = tableView
    self.selectionCommand = selectionCommand
    
    let nib = UINib(nibName: nibName, bundle: nil)
    
    // create an instance of the template cell and register with the table view
    templateCell = nib.instantiateWithOwner(nil, options: nil)[0] as! UITableViewCell
    tableView.registerNib(nib, forCellReuseIdentifier: templateCell.reuseIdentifier!)
    
    dataSource = DataSource(data: nil, templateCell: templateCell)
    
    super.init()
    
    sourceSignal.startWithNext { [weak self] data in
        self?.dataSource.data = data.map({ $0 as AnyObject })
        self?.tableView.reloadData()
    }

    self.tableView.dataSource = dataSource
    self.tableView.delegate = dataSource

    self.tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100.0
  }
}

class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
  private let templateCell: UITableViewCell
  var data: [AnyObject]?
  
  init(data: [AnyObject]?, templateCell: UITableViewCell) {
    self.data = data
    self.templateCell = templateCell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data?.count ?? 0
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCellWithIdentifier(templateCell.reuseIdentifier!),
              item = data?.safeIndex(indexPath.row),
              reactiveView = cell as? ReactiveView else {
        return UITableViewCell()
    }

    reactiveView.bindViewModel(item)
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
   /* if selectionCommand != nil {
      selectionCommand?.execute(data[indexPath.row])
    }*/
  }
}
