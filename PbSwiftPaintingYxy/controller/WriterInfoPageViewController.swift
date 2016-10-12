//
//  WriterInfoPageViewController.swift
//  PbSwiftPaintingLys
//
//  Created by Maqiang on 16/2/16.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import Foundation
import UIKit
import PbSwiftLibrary

//切换的视图
class WriterInfoTabView:UIView
{
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.backgroundColor=UIColor.clear
    }
    
    override func draw(_ rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        
        let width:CGFloat=1
        context?.setLineWidth(width)
        context?.setStrokeColor(UIColor.black.cgColor)
        
        context?.move(to: CGPoint(x: 0, y: 1))
        context?.addLine(to: CGPoint(x: self.frame.size.width, y: 1))
        context?.move(to: CGPoint(x: 0, y: self.frame.size.height-width))
        context?.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height-width))
        
        context?.strokePath()
    }
}

//Tabbar
class WriterInfoMenuView:PbUITabMenuView
{
    let margin:CGFloat=20
    var tabView=WriterInfoTabView(frame:CGRect.zero)
    //menuData:指定菜单数据
    override var menuData:Array<PbUITabMenuData>?
        {
        didSet
        {
            //根据菜单数量进行设置
            self.collectionView.setCollectionViewLayout(self.collectionViewLayout(), animated: true)
            
            collectionView.reloadData()
            self.moveTabViewToMenu(0)
            self.collectionView.selectItem(at:IndexPath(row: 0, section: 0), animated: true, scrollPosition: .right)
        }
    }
    
    func moveTabViewToMenu(_ index:Int)
    {
        let width=self.menuWidth()
        self.tabView.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            self.tabView.frame=CGRect(x: self.margin+(CGFloat(index)*width),y: 0, width: width, height: CGFloat(PbSystem.sizeTopMenuBarHeight))
            self.tabView.layoutIfNeeded()
            
            }) { (finish) -> Void in
                
        }
    }
    
    func menuWidth() -> CGFloat
    {
        return (PbSystem.screenWidth-margin*2)/CGFloat(min(self.maxNumPer,self.menuData!.count))
    }
    
    override func selectMenu(_ index: Int)
    {
        super.selectMenu(index)
        self.moveTabViewToMenu(index)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.addSubview(self.tabView)
    }
    
    override func draw(_ rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        
        let width:CGFloat=0.1
        context?.setLineWidth(width)
        context?.setStrokeColor(UIColor.black.cgColor)
        
        context?.move(to: CGPoint(x: margin, y: self.frame.size.height-width))
        context?.addLine(to: CGPoint(x: self.frame.size.width-margin, y: self.frame.size.height-width))
        
        context?.strokePath()
        
        self.collectionView.setCollectionViewLayout(self.collectionViewLayout(), animated: true)
    }
    
    override func collectionViewLayout() -> UICollectionViewFlowLayout
    {
        let layout=UICollectionViewFlowLayout()
        layout.scrollDirection=UICollectionViewScrollDirection.horizontal
        layout.sectionInset=UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        layout.minimumInteritemSpacing=0
        layout.minimumLineSpacing=0
        
        if(self.menuData != nil)
        {
            layout.itemSize=CGSize(width:self.menuWidth(),height:CGFloat(PbSystem.sizeTopMenuBarHeight))
        }
        
        return layout
    }
    
    //选中单元格时处理
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.moveTabViewToMenu((indexPath as NSIndexPath).row)
        super.collectionView(collectionView, didSelectItemAt: indexPath)
    }
}

//分页控制器
open class WriterInfoPageViewController: UIPageViewController,UIPageViewControllerDataSource,UIPageViewControllerDelegate,UITableViewDelegate,UITableViewDataSource
{
    //curIndex：记录当前的页码,从0开始
    var curIndex=0
    //storyBoardIds：记录视图StoryBoardID数组
    let storyBoardIds=["WorksCollectionView","WriterNewsView","WriterVideoView","WriterNewsView"]
    //sectionIds:记录对应的栏目标识
    let sectionIds=["0000","0001","0002","0003"]
    //tabbarTableView:tabbar表格视图（用于顶部的切换栏）
    let tabbarTableView=UITableView(frame: CGRect.zero)
    //blockHandleInforHeight:处理信息显示高度
    var blockHandleInforHeight:((_ toShowMax:Bool)->Void)?
    
    /*----------开始：实现UIPageViewControllerDataSource委托*/
    //返回前翻的视图
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        if(curIndex==0){return nil}
        return self.viewControllerAtIndex(curIndex-1)
    }
    
    //返回后翻的视图
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        let index=curIndex+1
        if(index == self.storyBoardIds.count){return nil}
        return self.viewControllerAtIndex(index)
    }
    
    //返回指定索引的视图
    fileprivate func viewControllerAtIndex(_ index:NSInteger) -> UIViewController?
    {
        let result=self.storyboard?.instantiateViewController(withIdentifier: storyBoardIds[index])
        result?.view.tag=index
        
        if(result != nil)
        {
            if(result!.isKind(of: WorksCollectionViewController.self))
            {
                (result as! WorksCollectionViewController).blockHandleInforHeight=self.blockHandleInforHeight
            }
            if(result!.isKind(of: WriterNewsTableViewController.self))
            {
                (result as! WriterNewsTableViewController).blockHandleInforHeight=self.blockHandleInforHeight
                (result as! WriterNewsTableViewController).sectionId=self.sectionIds[index]
            }
            if(result!.isKind(of: WriterVideoCollectionViewController.self))
            {
                (result as! WriterVideoCollectionViewController).blockHandleInforHeight=self.blockHandleInforHeight
            }
        }
        
        return result
    }
    /*----------结束：实现UIPageViewControllerDataSource委托*/
    
    /*----------开始：实现UIPageViewControllerDelegate委托*/
    //获取当前的页码
    open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        if(completed)
        {
            curIndex=pageViewController.viewControllers![0].view.tag
            ((self.tabbarTableView.cellForRow(at:IndexPath(row: 0, section: 0))) as! PbUITabMenuView).selectMenu(curIndex)
        }
    }
    /*----------结束：实现UIPageViewControllerDelegate委托*/
    
    /*----------开始：实现UITableViewDataSource委托*/
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 3
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return CGFloat(PbSystem.sizeTopMenuBarHeight)
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var result:UITableViewCell?
        let identifier="TabbarMenuViewCell"
        
        //菜单栏
        if((indexPath as NSIndexPath).section==0 && (indexPath as NSIndexPath).row==0)
        {
            result=(self.tabbarTableView.dequeueReusableCell(withIdentifier: identifier))
            if(result == nil)
            {
                result=WriterInfoMenuView(style: UITableViewCellStyle.default, reuseIdentifier:identifier)
                (result as! WriterInfoMenuView).textFont=UIFont.systemFont(ofSize: 14)
                (result as! WriterInfoMenuView).selectionStyle = .none
                (result as! WriterInfoMenuView).click={ (data:PbUITabMenuData) -> Void in
                    //点击选项卡时切换页面
                    self.setViewControllers([self.viewControllerAtIndex(data.indexId)!], direction: (data.indexId>self.curIndex ? .forward:.reverse), animated: true, completion:{ (finished) -> Void in
                        if(finished)
                        {
                            self.curIndex=data.indexId
                        }
                    })
                }
            }
            
            //设置菜单
            (result as! WriterInfoMenuView).menuData=[
                PbUITabMenuData(index:"0", indexId:0, displayName:"作品", targetController:nil),
                PbUITabMenuData(index:"1", indexId:1, displayName:"动态", targetController:nil),
                PbUITabMenuData(index:"2", indexId:2, displayName:"视频", targetController:nil),
                PbUITabMenuData(index:"3", indexId:3, displayName:"评论", targetController:nil)
            ]
        }
        
        if(result == nil)
        {
            result=UITableViewCell()
        }
        
        return result!
    }
    
    /*----------结束：实现UITableViewDataSource委托*/
    
    //视图初始化
    open override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //设置tabbar
        self.tabbarTableView.delegate=self
        self.tabbarTableView.dataSource=self
        self.tabbarTableView.translatesAutoresizingMaskIntoConstraints=false
        self.tabbarTableView.backgroundColor=UIColor.clear
        self.tabbarTableView.separatorStyle=UITableViewCellSeparatorStyle.none
        self.tabbarTableView.isScrollEnabled=false
        self.view.addSubview(self.tabbarTableView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tabbar]-0-|", options:.alignAllLastBaseline, metrics: nil, views: ["tabbar":self.tabbarTableView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tabbar(==height)]", options:.alignAllLastBaseline, metrics:["height":PbSystem.sizeTopMenuBarHeight], views: ["tabbar":self.tabbarTableView]))
        
        let backImageView=UIImageView(image: UIImage(named:"main_bg"))
        backImageView.contentMode = .scaleAspectFill
        self.tabbarTableView.backgroundView=backImageView
        
        //设置PageView
        self.dataSource=self
        self.delegate=self
        self.setViewControllers([self.viewControllerAtIndex(0)!], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
    }
}
