//
//  CustomViewController.swift
//  PbSwiftPaintingYxy
//
//  Created by Maqiang on 16/3/12.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import Foundation
import UIKit
import PbSwiftLibrary

//CustomViewController
class CustomViewController:UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setBarBackItem()
    }
    
    func setBarBackItem()
    {
        //设置返回按钮
        let backView=UIButton(type:.custom)
        backView.setImage(UIImage(named:"icon_left"), for: UIControlState())
        backView.frame=CGRect(x: 0, y: 0, width: 28, height: 28)
        backView.contentMode = .center
        backView.backgroundColor=UIColor(white:0, alpha:0.8)
        backView.layer.cornerRadius=14
        backView.layer.borderColor=UIColor.white.cgColor
        backView.layer.borderWidth=1
        backView.addTarget(self, action:#selector(CustomViewController.popViewController), for:.touchUpInside)
        self.navigationItem.leftBarButtonItem=UIBarButtonItem(customView:backView)
    }
    
    func popViewController()
    {
        _=self.navigationController?.popViewController(animated: true)
    }
}

//CustomTableViewController
class CustomTableViewController:UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setBarBackItem()
        self.tableView.backgroundView=UIImageView(image:UIImage(named:"main_bg"))
    }
    
    func setBarBackItem()
    {
        //设置返回按钮
        let backView=UIButton(type:.custom)
        backView.setImage(UIImage(named:"icon_left"), for: UIControlState())
        backView.frame=CGRect(x: 0, y: 0, width: 28, height: 28)
        backView.contentMode = .center
        backView.backgroundColor=UIColor(white:0, alpha:0.8)
        backView.layer.cornerRadius=14
        backView.layer.borderColor=UIColor.white.cgColor
        backView.layer.borderWidth=1
        backView.addTarget(self, action:#selector(CustomViewController.popViewController), for:.touchUpInside)
        self.navigationItem.leftBarButtonItem=UIBarButtonItem(customView:backView)
    }
    
    func popViewController()
    {
        _=self.navigationController?.popViewController(animated: true)
    }
}

//CustomPbTableViewController
class CustomPbTableViewController:PbUITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setBarBackItem()
        self.tableView.backgroundView=UIImageView(image:UIImage(named:"main_bg"))
    }
    
    func setBarBackItem()
    {
        //设置返回按钮
        let backView=UIButton(type:.custom)
        backView.setImage(UIImage(named:"icon_left"), for: UIControlState())
        backView.frame=CGRect(x: 0, y: 0, width: 28, height: 28)
        backView.contentMode = .center
        backView.backgroundColor=UIColor(white:0, alpha:0.8)
        backView.layer.cornerRadius=14
        backView.layer.borderColor=UIColor.white.cgColor
        backView.layer.borderWidth=1
        backView.addTarget(self, action:#selector(CustomViewController.popViewController), for:.touchUpInside)
        self.navigationItem.leftBarButtonItem=UIBarButtonItem(customView:backView)
    }
    
    func popViewController()
    {
        _=self.navigationController?.popViewController(animated: true)
    }
}

//CustomPbCollectionViewController
class CustomPbCollectionViewController:PbUICollectionViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setBarBackItem()
        self.collectionView!.backgroundView=UIImageView(image:UIImage(named:"main_bg"))
    }
    
    func setBarBackItem()
    {
        //设置返回按钮
        let backView=UIButton(type:.custom)
        backView.setImage(UIImage(named:"icon_left"), for: UIControlState())
        backView.setTitle("", for: UIControlState())
        backView.frame=CGRect(x: 0, y: 0, width: 28, height: 28)
        backView.contentEdgeInsets=UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        backView.contentMode = .center
        backView.backgroundColor=UIColor(white:0, alpha:0.8)
        backView.layer.cornerRadius=14
        backView.layer.borderColor=UIColor.white.cgColor
        backView.layer.borderWidth=1
        backView.addTarget(self, action:#selector(CustomViewController.popViewController), for:.touchUpInside)
        self.navigationItem.leftBarButtonItem=UIBarButtonItem(customView:backView)
    }
    
    func popViewController()
    {
        _=self.navigationController?.popViewController(animated: true)
    }
}
